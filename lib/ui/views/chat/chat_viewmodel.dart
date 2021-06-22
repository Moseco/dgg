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
  final _dialogService = locator<DialogService>();

  late WebViewController webViewController;
  YoutubePlayerController? youtubePlayerController;
  final chatInputController = TextEditingController();

  bool get isLoading => isAuthenticating || !isAssetsLoaded;
  bool get isAuthenticating => _dggService.sessionInfo == null;
  bool get isAssetsLoaded => _dggService.assetsLoaded;
  bool get isSignedIn => _dggService.isSignedIn;

  StreamSubscription? _chatSubscription;
  List<Message> _messages = [];
  List<Message> get messages => _isListAtBottom ? _messages : _pausedMessages;
  List<User> _users = [];
  bool _isChatConnected = false;
  bool get isChatConnected => _isChatConnected;
  bool _isListAtBottom = true;
  bool get isListAtBottom => _isListAtBottom;
  List<Message> _pausedMessages = [];
  bool _showReconnectButton = false;
  bool get showReconnectButton => _showReconnectButton;

  String _draft = '';
  String get draft => _draft;
  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;
  String _previousLastWord = '';

  static const String twitchStreamUrlBase =
      r'https://player.twitch.tv/?parent=dev.moseco.dgg&muted=false&channel=';
  static const String twitchVodUrlBase =
      r'https://player.twitch.tv/?parent=dev.moseco.dgg&muted=false&video=';
  static const String twitchClipUrlBase =
      r'https://clips.twitch.tv/embed?parent=dev.moseco.dgg&autoplay=true&muted=false&clip=';
  String _currentEmbedId = 'destiny';
  bool _showStreamPrompt = false;
  bool get showStreamPrompt => _showStreamPrompt;
  bool _showEmbed = false;
  bool get showEmbed => _showEmbed;
  EmbedType _embedType = EmbedType.TWITCH_STREAM;
  EmbedType get embedType => _embedType;

  DggVote? _currentVote;
  DggVote? get currentVote => _currentVote;
  Timer? _voteTimer;
  int get voteTimePassed => _voteTimer!.tick;
  bool _isVoteCollapsed = false;
  bool get isVoteCollapsed => _isVoteCollapsed;

  int _appBarTheme = 0;
  int get appBarTheme => _appBarTheme;

  double _textFontSize = 16;
  double get textFontSize => _textFontSize;
  double _iconSize = 20;
  double get iconSize => _iconSize;
  double _emoteHeight = 30;
  double get emoteHeight => _emoteHeight;

  Future<void> initialize() async {
    await _sharedPreferencesService.initialize();
    await _checkOnboarding();
    if (_sharedPreferencesService.getWakelockEnabled()) {
      Wakelock.enable();
    }
    _appBarTheme = _sharedPreferencesService.getAppBarTheme();
    _setChatSize();
    notifyListeners();
    await _getSessionInfo();
    _getStreamStatus();
    await _dggService.getAssets();
    await _getChatHistory();
    _connectChat();
    _showChangelog();
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

  Future<void> _getChatHistory() async {
    List<dynamic> rawHistoryMessages = await _dggService.getChatHistory();

    for (int i = 100; i < rawHistoryMessages.length; i++) {
      _processMessage(rawHistoryMessages[i].toString());
    }
  }

  void _connectChat() {
    _showReconnectButton = false;
    _messages.add(StatusMessage(data: "Connecting..."));
    notifyListeners();
    _chatSubscription?.cancel();
    _chatSubscription = _dggService.openWebSocketConnection().stream.listen(
          (data) => _processMessage(data),
          onDone: () => _disconnectChat(),
          onError: (error) => print("STREAM REPORTED ERROR"),
        );
  }

  void _processMessage(String? data) {
    Message? currentMessage = _dggService.parseWebSocketData(data);

    switch (currentMessage.runtimeType) {
      case NamesMessage:
        _isChatConnected = true;
        _users = (currentMessage as NamesMessage).users;
        _messages
            .add(StatusMessage(data: "Connected with ${_users.length} users"));
        break;
      case UserMessage:
        UserMessage userMessage = currentMessage as UserMessage;
        //for each emote, check if needs to be loaded
        userMessage.elements.forEach((element) {
          if (element is EmoteElement) {
            if (!element.emote.loading && element.emote.image == null) {
              _loadEmote(element.emote);
            }
          }
        });
        //Check if new message is part of a combo
        if (_messages.length > 0 &&
            userMessage.elements.length == 1 &&
            userMessage.elements[0] is EmoteElement) {
          //Current message only has one emote in it
          EmoteElement currentEmote = userMessage.elements[0] as EmoteElement;
          Message recentMessage = _messages[_messages.length - 1];
          if (recentMessage is ComboMessage) {
            //Most recent is combo
            if (recentMessage.emote.name == currentEmote.emote.name) {
              //Same emote, increment combo
              _messages[_messages.length - 1] = recentMessage.incrementCombo();
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
            DggVote? dggVote = DggVote.fromString(userMessage.data);
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
        if (_currentVote != null && _currentVote!.time > voteTimePassed) {
          String temp =
              userMessage.data.replaceFirst(DggVote.voteValidRegex, '');
          //Check if message is a vote and restrict length to prevent max int error
          if (temp.isEmpty && userMessage.data.length < 3) {
            int vote = int.parse(userMessage.data);
            if (vote > 0 && vote <= _currentVote!.options.length) {
              _currentVote!.castVote(
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
        _messages.add(currentMessage!);
        break;
      case MuteMessage:
        //Go through up to previous 10 messages and censor messages from muted user
        MuteMessage muteMessage = currentMessage as MuteMessage;
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
        UnmuteMessage unmuteMessage = currentMessage as UnmuteMessage;
        _messages.add(StatusMessage(
            data: "${unmuteMessage.data} unmuted by ${unmuteMessage.nick}"));
        break;
      case BanMessage:
        BanMessage banMessage = currentMessage as BanMessage;
        _messages.add(StatusMessage(
            data: "${banMessage.data} banned by ${banMessage.nick}"));
        break;
      case UnbanMessage:
        UnbanMessage unbanMessage = currentMessage as UnbanMessage;
        _messages.add(StatusMessage(
            data: "${unbanMessage.data} unbanned by ${unbanMessage.nick}"));
        break;
      case StatusMessage:
        _messages.add(currentMessage!);
        break;
      case SubOnlyMessage:
        SubOnlyMessage subOnlyMessage = currentMessage as SubOnlyMessage;
        String subMode = subOnlyMessage.data == 'on' ? 'enabled' : 'disabled';
        _messages.add(StatusMessage(
            data: "Subscriber only mode $subMode by ${subOnlyMessage.nick}"));
        break;
      case ErrorMessage:
        ErrorMessage errorMessage = currentMessage as ErrorMessage;
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
        } else if (errorMessage.description == "needlogin") {
          // Server thinks user is not logged in
          //    Can try reconnecting to fix it
          _messages.add(StatusMessage(
            data:
                "Message failed to send due to an authentication failure.\nAutomatically reconnecting...",
            isError: true,
          ));
          _delayedReconnect();
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
  }

  Future<void> _disconnectChat() async {
    if (_isChatConnected) {
      _messages.add(StatusMessage(data: "Disconnected"));
    }
    _isChatConnected = false;
    _showReconnectButton = true;
    notifyListeners();
    _chatSubscription?.cancel();
    _chatSubscription = null;
    await _dggService.closeWebSocketConnection();
  }

  Future<void> _delayedReconnect() async {
    await _disconnectChat();
    await Future.delayed(Duration(seconds: 3));
    await _getSessionInfo();
    _connectChat();
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
        // Navigate to settings
        //    Disconnect chat/turn off wakelock while in settings
        if (_sharedPreferencesService.getWakelockEnabled()) {
          Wakelock.disable();
        }
        _disconnectChat();
        await _navigationService.navigateTo(Routes.settingsView);
        _appBarTheme = _sharedPreferencesService.getAppBarTheme();
        _setChatSize();
        if (_sharedPreferencesService.getWakelockEnabled()) {
          Wakelock.enable();
        }
        _connectChat();
        break;
      case 1:
        // Disconnect or reconnect
        if (_isChatConnected) {
          _disconnectChat();
        } else if (_showReconnectButton) {
          _connectChat();
        }
        break;
      case 2:
        // Refresh assets
        // First disconnect from chat
        await _disconnectChat();
        // Then clear assets
        await _dggService.clearAssets();
        // Finally fetch assets
        await _dggService.getAssets();
        notifyListeners();
        // Re-open chat
        _connectChat();
        break;
      case 3:
        _openDestinyStream();
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
    //Find last occurrence of whitespace
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
        RegExp lastWordRegex = RegExp(
          RegExp.escape(lastWord),
          caseSensitive: false,
        );

        _suggestions.forEach((element) {
          if (element.startsWith(lastWordRegex)) {
            newSuggestions.add(element);
          }
        });
      } else {
        //Current last word does not start with previous last word
        //  Backspace, new word, or something similar happened
        //  Start suggestion generation from beginning
        RegExp lastWordRegex = RegExp(
          RegExp.escape(lastWord),
          caseSensitive: false,
        );

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
    if (_sharedPreferencesService.getDefaultStream() == 0) {
      // Twitch is default
      _getTwitchStreamStatus();
    } else {
      // YouTube is default
      _getYouTubeStreamStatus();
    }
  }

  Future<void> _getTwitchStreamStatus() async {
    String twitchClientId = await _remoteConfigService.getTwitchClientId();

    if (twitchClientId.isNotEmpty) {
      // Twitch api to check status of a channel
      //    Hardcoded to Destiny's stream
      final response = await http.get(
        Uri.https("api.twitch.tv", "/kraken/streams/18074328"),
        headers: {
          'Accept': 'application/vnd.twitchtv.v5+json',
          'Client-ID': twitchClientId,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['stream'] != null && !_showEmbed) {
          // Stream is online
          _showStreamPrompt = true;
          _embedType = EmbedType.TWITCH_STREAM;
          notifyListeners();
        }
      }
    }
  }

  Future<void> _getYouTubeStreamStatus() async {
    String? videoId = await _getYouTubeStreamId();

    if (videoId != null && !_showEmbed) {
      // Stream is online
      _currentEmbedId = videoId;
      _showStreamPrompt = true;
      _embedType = EmbedType.YOUTUBE;
      youtubePlayerController?.close();
      youtubePlayerController = YoutubePlayerController(
        initialVideoId: _currentEmbedId,
        params: YoutubePlayerParams(autoPlay: true, showControls: false),
      );
      notifyListeners();
    }
  }

  Future<String?> _getYouTubeStreamId() async {
    String youTubeApiKey = await _remoteConfigService.getYouTubeApiKey();

    if (youTubeApiKey.isNotEmpty) {
      // YouTube api to get channel's live streams
      //    Hardcoded to Destiny's channel
      final response = await http.get(
        Uri.https(
          "youtube.googleapis.com",
          "/youtube/v3/search",
          {
            "part": "snippet",
            "channelId": "UC554eY5jNUfDq3yDOJYirOQ",
            "eventType": "live",
            "maxResults": "25",
            "type": "video",
            "key": youTubeApiKey,
          },
        ),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> json = jsonDecode(response.body);

        if (json['items'] != null && json['items'].length > 0) {
          return json['items'][0]['id']?['videoId'];
        }
      }
    }

    return null;
  }

  void setShowEmbed(bool value) {
    _showStreamPrompt = false;
    _showEmbed = value;
    notifyListeners();
  }

  void setStreamChannelManual(List<String>? channel) {
    if (channel != null && channel[0].trim().isNotEmpty) {
      setEmbed(channel[0], "twitch");
    }
  }

  void setEmbed(String embedId, String embedType) {
    //Set new channel name
    _currentEmbedId = embedId.trim();
    //Set values based on embed type and current embed state
    switch (embedType) {
      case "twitch":
        if (_showEmbed && _embedType != EmbedType.YOUTUBE) {
          //Embed already shown, use controller to load new stream
          webViewController.loadUrl(twitchStreamUrlBase + _currentEmbedId);
        }
        _embedType = EmbedType.TWITCH_STREAM;
        break;
      case "youtube":
        if (_showEmbed && _embedType == EmbedType.YOUTUBE) {
          //Embed already shown, use controller to load new stream
          youtubePlayerController!.load(_currentEmbedId);
        } else {
          _embedType = EmbedType.YOUTUBE;
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
      case "twitch-vod":
        if (_showEmbed && _embedType != EmbedType.YOUTUBE) {
          //Embed already shown, use controller to load new stream
          webViewController.loadUrl(twitchVodUrlBase + _currentEmbedId);
        }
        _embedType = EmbedType.TWITCH_VOD;
        break;
      case "twitch-clip":
        if (_showEmbed && _embedType != EmbedType.YOUTUBE) {
          //Embed already shown, use controller to load new stream
          webViewController.loadUrl(twitchVodUrlBase + _currentEmbedId);
        }
        _embedType = EmbedType.TWITCH_CLIP;
        break;
      default:
        break;
    }
    //Show the stream embed
    setShowEmbed(true);
  }

  String getTwitchEmbedUrl() {
    switch (_embedType) {
      case EmbedType.TWITCH_STREAM:
        return twitchStreamUrlBase + _currentEmbedId;
      case EmbedType.TWITCH_VOD:
        return twitchVodUrlBase + _currentEmbedId;
      case EmbedType.TWITCH_CLIP:
        return twitchClipUrlBase + _currentEmbedId;
      default:
        return 'https://destiny.gg';
    }
  }

  void handleVoteTimer(Timer timer) {
    if (timer.tick > _currentVote!.time + 5) {
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
      urlToOpen = "https://" + url;
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

  Future<void> onUserMessageLongPress(UserMessage? message) async {
    var sheetResponse = await _bottomSheetService.showCustomSheet(
      variant: BottomSheetType.messageAction,
      customData: message,
      barrierDismissible: true,
    );

    if (sheetResponse != null) {
      switch (sheetResponse.responseData) {
        case MessageActionSheetResponse.copy:
          Clipboard.setData(ClipboardData(text: message!.data));
          break;
        case MessageActionSheetResponse.reply:
          String newDraft = "${message!.user.nick} ";
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

  void onReconnectButtonPressed() {
    if (_showReconnectButton) {
      _connectChat();
    }
  }

  Future<void> _openDestinyStream() async {
    // Open default stream platform
    if (_sharedPreferencesService.getDefaultStream() == 0) {
      // Open Destiny's stream on Twitch
      setStreamChannelManual(["destiny"]);
    } else {
      // Open Destiny's stream on YouTube
      String? streamId = await _getYouTubeStreamId();
      if (streamId == null) {
        _snackbarService.showSnackbar(
            message: "Destiny's YouTube stream is offline");
      } else {
        setEmbed(streamId, "youtube");
      }
    }
  }

  Future<void> _showChangelog() async {
    bool showChangelog = await _sharedPreferencesService.shouldShowChangelog();
    if (showChangelog) {
      _dialogService.showDialog(
        title: "What's new",
        description:
            "Bug fixes:\n•Fixed a bug where typing certain special characters would cause the suggestion feature to crash.\n•Fixed a bug where sent messages would be rejected by the server if they contained certain special characters.",
      );
    }
  }

  void _setChatSize() {
    int textSize = _sharedPreferencesService.getChatTextSize();
    int emoteSize = _sharedPreferencesService.getChatEmoteSize();
    // Set text and icon size
    if (textSize == 0) {
      _textFontSize = 12;
      _iconSize = 14;
    } else if (textSize == 1) {
      _textFontSize = 16;
      _iconSize = 20;
    } else if (textSize == 2) {
      _textFontSize = 20;
      _iconSize = 24;
    }
    // Set emote size
    if (emoteSize == 0) {
      _emoteHeight = 20;
    } else if (emoteSize == 1) {
      _emoteHeight = 30;
    } else if (emoteSize == 2) {
      _emoteHeight = 40;
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
  TWITCH_STREAM,
  TWITCH_VOD,
  TWITCH_CLIP,
  YOUTUBE,
}
