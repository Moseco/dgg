import 'dart:async';
import 'dart:convert';

import 'package:dgg/app/app.locator.dart';
import 'package:dgg/app/app.router.dart';
import 'package:dgg/datamodels/dgg_vote.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:dgg/services/remote_config_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:dgg/ui/widgets/setup_bottom_sheet_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ChatViewModel extends BaseViewModel {
  final _dggService = locator<DggService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _remoteConfigService = locator<RemoteConfigService>();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _snackbarService = locator<SnackbarService>();

  WebViewController webViewController;
  YoutubePlayerController youtubePlayerController;
  final chatInputController = TextEditingController();

  bool get isLoading => isAuthenticating || !isAssetsLoaded;
  bool get isAuthenticating => _dggService.sessionInfo == null;
  bool get isAssetsLoaded => _dggService.isAssetsLoaded;
  bool get isSignedIn => _dggService.isSignedIn;

  StreamSubscription _chatSubscription;
  List<Message> _messages = [];
  List<Message> get messages => _isListAtBottom ? _messages : _pausedMessages;
  List<User> _users = [];
  bool _isChatConnected = false;
  bool get isChatConnected => _isChatConnected;
  bool _isListAtBottom = true;
  bool get isListAtBottom => _isListAtBottom;
  List<Message> _pausedMessages = [];

  String _draft = '';
  String get draft => _draft;
  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;
  String _previousLastWord = '';

  String get twitchUrlBase =>
      'https://player.twitch.tv/?parent=dev.moseco.dgg&muted=false&channel=';
  String _currentEmbedId = 'destiny';
  String get currentEmbedId => _currentEmbedId;
  bool _showStreamPrompt = false;
  bool get showStreamPrompt => _showStreamPrompt;
  bool _showStreamEmbed = false;
  bool get showStreamEmbed => _showStreamEmbed;
  EmbedType _streamEmbedType = EmbedType.twitch;
  EmbedType get streamEmbedType => _streamEmbedType;

  DggVote _currentVote;
  DggVote get currentVote => _currentVote;
  Timer _voteTimer;
  int get voteTimePassed => _voteTimer.tick;
  bool _isVoteCollapsed = false;
  bool get isVoteCollapsed => _isVoteCollapsed;

  Future<void> initialize() async {
    await _sharedPreferencesService.initialize();
    await _checkOnboarding();
    if (_sharedPreferencesService.getWakelockEnabled()) {
      Wakelock.enable();
    }
    await _getSessionInfo();
    _getStreamStatus();
    await _dggService.getAssets();
    notifyListeners();
    _connectChat();
  }

  Future<void> _checkOnboarding() async {
    bool onboardingFinished = _sharedPreferencesService.getOnboarding();

    if (!onboardingFinished) {
      await _navigationService.navigateTo(Routes.onboardingView);
    }
  }

  Future<void> _getSessionInfo() async {
    await _dggService.getSessionInfo();
    notifyListeners();
  }

  void _connectChat() {
    _messages.add(StatusMessage(data: "Connecting..."));
    notifyListeners();
    _chatSubscription = _dggService.openWebSocketConnection().stream.listen(
      (data) {
        Message currentMessage = _dggService.parseWebSocketData(data);

        switch (currentMessage.runtimeType) {
          case NamesMessage:
            _isChatConnected = true;
            _users = (currentMessage as NamesMessage).users;
            _messages.add(
                StatusMessage(data: "Connected with ${_users.length} users"));
            break;
          case UserMessage:
            UserMessage userMessage = currentMessage;
            //for each emote, check if needs to be loaded
            userMessage.elements.forEach((element) {
              if (element is EmoteElement) {
                if (!element.emote.loading && element.emote.image == null) {
                  _loadEmote(element.emote);
                }
              }
            });
            //Check if new message is part of a combo
            if (userMessage.elements.length == 1 &&
                userMessage.elements[0] is EmoteElement) {
              //Current message only has one emote in it
              EmoteElement currentEmote = userMessage.elements[0];
              Message recentMessage = _messages[_messages.length - 1];
              if (recentMessage is ComboMessage) {
                //Most recent is combo
                if (recentMessage.emote.name == currentEmote.emote.name) {
                  //Same emote, increment combo
                  _messages[_messages.length - 1] =
                      recentMessage.incrementCombo();
                  break;
                }
              } else {
                //Most recent is not combo
                if (recentMessage is UserMessage &&
                    recentMessage.elements.length == 1 &&
                    recentMessage.elements[0] is EmoteElement &&
                    (recentMessage.elements[0] as EmoteElement).emote.name ==
                        currentEmote.emote.name) {
                  //Most recent is UserMessage and only has the same emote
                  //  Replace recent message with combo
                  _messages[_messages.length - 1] =
                      ComboMessage(emote: currentEmote.emote);
                  break;
                }
              }
            }
            //Check if message is starting a vote
            if (userMessage.data.startsWith(DggVote.voteStartRegex)) {
              if (_dggService.hasVotePermission(userMessage.user.features)) {
                DggVote dggVote = DggVote.fromString(userMessage.data);
                if (dggVote != null) {
                  _currentVote = dggVote;
                  _voteTimer?.cancel();
                  _voteTimer =
                      Timer.periodic(Duration(seconds: 1), handleVoteTimer);
                }
              }
            }
            //Check if message is stoping a vote
            if (userMessage.data.startsWith(DggVote.voteStopRegex)) {
              if (_dggService.hasVotePermission(userMessage.user.features)) {
                _currentVote = null;
                _voteTimer?.cancel();
              }
            }
            //Check if message is a vote
            if (_currentVote != null && _currentVote.time > voteTimePassed) {
              String temp =
                  userMessage.data.replaceFirst(DggVote.voteValidRegex, '');
              //Check if message is a vote and restrict length to prevent max int error
              if (temp.isEmpty && userMessage.data.length < 3) {
                int vote = int.parse(userMessage.data);
                if (vote > 0 && vote <= _currentVote.options.length) {
                  _currentVote.castVote(
                      userMessage.user.nick, vote, userMessage.user.features);
                }
              }
            }

            //Add message normally
            _messages.add(userMessage);
            break;
          case JoinMessage:
            _users.add((currentMessage as JoinMessage).user);
            break;
          case QuitMessage:
            _users.remove((currentMessage as QuitMessage).user);
            break;
          case BroadcastMessage:
            _messages.add(currentMessage);
            break;
          case MuteMessage:
            //Go through up to previous 10 messages and censor messages from muted user
            MuteMessage muteMessage = currentMessage;
            int lengthToCheck = _messages.length >= 11 ? 11 : _messages.length;
            for (int i = 1; i < lengthToCheck; i++) {
              Message msg = _messages[_messages.length - i];
              if (msg is UserMessage) {
                if (msg.user.nick == muteMessage.data) {
                  msg.isCensored = true;
                }
              }
            }
            _messages.add(StatusMessage(
                data: "${muteMessage.data} muted by ${muteMessage.nick}"));
            break;
          case UnmuteMessage:
            UnmuteMessage unmuteMessage = currentMessage;
            _messages.add(StatusMessage(
                data:
                    "${unmuteMessage.data} unmuted by ${unmuteMessage.nick}"));
            break;
          case BanMessage:
            BanMessage banMessage = currentMessage;
            _messages.add(StatusMessage(
                data: "${banMessage.data} banned by ${banMessage.nick}"));
            break;
          case UnbanMessage:
            UnbanMessage unbanMessage = currentMessage;
            _messages.add(StatusMessage(
                data: "${unbanMessage.data} unbanned by ${unbanMessage.nick}"));
            break;
          case StatusMessage:
            _messages.add(currentMessage);
            break;
          case SubOnlyMessage:
            SubOnlyMessage subOnlyMessage = currentMessage;
            String subMode =
                subOnlyMessage.data == 'on' ? 'enabled' : 'disabled';
            _messages.add(StatusMessage(
                data:
                    "Subscriber only mode $subMode by ${subOnlyMessage.nick}"));
            break;
          case ErrorMessage:
            ErrorMessage errorMessage = currentMessage;
            if (errorMessage.description == "banned") {
              _messages.add(StatusMessage(
                data:
                    "You have been banned! Check your profile on destiny.gg for more information.",
                isError: true,
              ));
            } else if (errorMessage.description == "muted") {
              _messages.add(StatusMessage(
                data: "You are temporarily muted!",
                isError: true,
              ));
            } else {
              _messages.add(StatusMessage(
                data: errorMessage.description,
                isError: true,
              ));
            }
            break;
          default:
            break;
        }

        //When messages length grows to 300, shrink to 150
        if (_messages.length > 300) {
          _messages.removeRange(0, 150);
        }

        notifyListeners();
      },
      onDone: () => _disconnectChat(),
      onError: (error) => print("STREAM REPORTED ERROR"),
    );
  }

  Future<void> _disconnectChat() async {
    if (_isChatConnected) {
      _messages.add(StatusMessage(data: "Disconnected"));
    }
    _isChatConnected = false;
    notifyListeners();
    _chatSubscription?.cancel();
    _chatSubscription = null;
    await _dggService.closeWebSocketConnection();
  }

  Future<void> _loadEmote(Emote emote) async {
    await _dggService.loadEmote(emote);
    notifyListeners();
  }

  void uncensorMessage(UserMessage message) {
    message.isCensored = false;
    notifyListeners();
  }

  Future<void> menuItemClick(int selected) async {
    switch (selected) {
      case 0:
        //Disconnect
        _disconnectChat();
        break;
      case 1:
        //Reconnect
        await _disconnectChat();
        _connectChat();
        break;
      case 2:
        //Refresh assets
        //First disconnect from chat
        await _disconnectChat();
        //Then clear assets
        await _dggService.clearAssets();
        //Finally fetch assets
        await _dggService.getAssets();
        notifyListeners();
        //Re-open chat
        _connectChat();
        break;
      case 4:
        //Navigate to settings
        //  Disconnect chat/turn off wakelock while in settings
        if (_sharedPreferencesService.getWakelockEnabled()) {
          Wakelock.disable();
        }
        _disconnectChat();
        await _navigationService.navigateTo(Routes.settingsView);
        if (_sharedPreferencesService.getWakelockEnabled()) {
          Wakelock.enable();
        }
        _connectChat();
        break;
      default:
        print("ERROR: Invalid chat menu item");
    }
  }

  void updateChatDraft(String value) {
    _draft = value;
    _updateSuggestions();
  }

  void sendChatMessage() {
    String draftTrim = _draft.trim();
    if (draftTrim.isNotEmpty && isChatConnected) {
      _dggService.sendChatMessage(draftTrim);
      updateChatDraft('');
      chatInputController.clear();
    }
  }

  void completeSuggestion(int suggestionIndex) {
    String newDraft;
    int lastWhiteSpace = _draft.lastIndexOf(RegExp(r'\s'));
    if (lastWhiteSpace == -1) {
      //No whitespace, replace whole thing with suggestion
      newDraft = _suggestions[suggestionIndex] + ' ';
    } else {
      //At least one whitespace, replace last word with suggestion
      newDraft = _draft.substring(0, lastWhiteSpace + 1) +
          _suggestions[suggestionIndex] +
          ' ';
    }

    updateChatDraft(newDraft);
    chatInputController.text = newDraft;
    chatInputController.selection =
        TextSelection.fromPosition(TextPosition(offset: newDraft.length));
  }

  void _updateSuggestions() {
    String lastWord;
    //Find last occurance of whitespace
    int lastWhiteSpace = _draft.lastIndexOf(RegExp(r'\s'));
    if (lastWhiteSpace != -1) {
      //Draft contains at least one whitespace
      lastWord = _draft.substring(lastWhiteSpace + 1);
    } else {
      //No whitespace in draft
      lastWord = _draft;
    }

    List<String> newSuggestions = [];

    //If last word is not empty then generate autocomplete suggestions
    if (lastWord.isNotEmpty) {
      if (lastWord.startsWith(_previousLastWord) &&
          _previousLastWord.isNotEmpty) {
        //Continued typing of previous last word
        //  Base new suggestions on current suggestion list
        RegExp lastWordRegex = RegExp(lastWord, caseSensitive: false);

        _suggestions.forEach((element) {
          if (element.startsWith(lastWordRegex)) {
            newSuggestions.add(element);
          }
        });
      } else {
        //Current last word does not start with previous last word
        //  Backspace, new word, or something similar happaned
        //  Start suggestion generation from beginning
        RegExp lastWordRegex = RegExp(lastWord, caseSensitive: false);

        //check emotes
        _dggService.emotes.emoteMap.forEach((k, v) {
          if (k.startsWith(lastWordRegex)) {
            newSuggestions.add(k);
          }
        });

        //check user names
        _users.forEach((user) {
          if (user.nick.startsWith(lastWordRegex)) {
            newSuggestions.add(user.nick);
          }
        });
      }
    }

    _suggestions = newSuggestions;
    _previousLastWord = lastWord;
    notifyListeners();
  }

  void toggleChat(bool isListAtBottom) {
    if (_isListAtBottom != isListAtBottom) {
      if (!isListAtBottom) {
        _pausedMessages = List.from(messages);
      }
      _isListAtBottom = isListAtBottom;
      notifyListeners();
    } else {
      _isListAtBottom = isListAtBottom;
    }
  }

  Future<void> _getStreamStatus() async {
    String twitchClientId = await _remoteConfigService.getTwitchClientId();

    if (twitchClientId != null && twitchClientId.isNotEmpty) {
      //Twitch api to check status of a channel
      //  Hardcoded to Destiny's stream
      final response = await http.get(
        Uri.https("api.twitch.tv", "/kraken/streams/18074328"),
        headers: {
          'Accept': 'application/vnd.twitchtv.v5+json',
          'Client-ID': twitchClientId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['stream'] != null) {
          //Stream is online
          _showStreamPrompt = true;
          notifyListeners();
        }
      }
    }
  }

  void setShowStreamEmbed(bool value) {
    _showStreamPrompt = false;
    _showStreamEmbed = value;
    notifyListeners();
  }

  void setStreamChannelManual(List<String> channel) {
    if (channel != null && channel[0].trim().isNotEmpty) {
      setStreamChannel(channel[0], "twitch");
    }
  }

  void setStreamChannel(String embedId, String embedType) {
    if (embedId != null && embedId.trim().isNotEmpty) {
      //Set new channel name
      _currentEmbedId = embedId.trim();
      //Set values based on embed type and current embed state
      switch (embedType) {
        case "twitch":
          if (_showStreamEmbed && _streamEmbedType == EmbedType.twitch) {
            //Embed already shown, use controller to load new stream
            webViewController.loadUrl(twitchUrlBase + _currentEmbedId);
          } else {
            _streamEmbedType = EmbedType.twitch;
          }
          break;
        case "youtube":
          if (_showStreamEmbed && _streamEmbedType == EmbedType.youtube) {
            //Embed already shown, use controller to load new stream
            youtubePlayerController.load(_currentEmbedId);
          } else {
            _streamEmbedType = EmbedType.youtube;
            youtubePlayerController?.close();
            youtubePlayerController = YoutubePlayerController(
              initialVideoId: _currentEmbedId,
              params: YoutubePlayerParams(
                autoPlay: true,
                showControls: false,
              ),
            );
          }
          break;
        default:
          break;
      }
      //Show the stream embed
      setShowStreamEmbed(true);
    }
  }

  void handleVoteTimer(Timer timer) {
    if (timer.tick > _currentVote.time + 5) {
      timer.cancel();
      _currentVote = null;
    }
    notifyListeners();
  }

  void toggleVoteCollapse() {
    _isVoteCollapsed = !_isVoteCollapsed;
    notifyListeners();
  }

  Future<void> openUrl(String url) async {
    String urlToOpen = url;
    if (!url.startsWith("http")) {
      urlToOpen = "http://" + url;
    }

    if (await canLaunch(urlToOpen)) {
      launch(urlToOpen);
    } else {
      _snackbarService.showSnackbar(
        message: "Could not open url. Copied to clipboard",
        duration: const Duration(seconds: 2),
      );
      Clipboard.setData(ClipboardData(text: url));
    }
  }

  Future<void> onUserMessageLongPress(UserMessage message) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.messageAction,
      customData: message,
      barrierDismissible: true,
    );

    if (sheetResponse != null) {
      switch (sheetResponse.responseData) {
        case MessageActionSheetResponse.copy:
          Clipboard.setData(ClipboardData(text: message.data));
          break;
        case MessageActionSheetResponse.reply:
          String newDraft = "${message.user.nick} ";
          updateChatDraft(newDraft);
          chatInputController.text = newDraft;
          chatInputController.selection =
              TextSelection.fromPosition(TextPosition(offset: newDraft.length));
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    if (_sharedPreferencesService.getWakelockEnabled()) {
      Wakelock.disable();
    }
    _disconnectChat();
    _voteTimer?.cancel();
    youtubePlayerController?.close();
    chatInputController.dispose();
    super.dispose();
  }
}

enum EmbedType {
  twitch,
  youtube,
}
