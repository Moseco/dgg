import 'dart:async';

import 'package:dgg/app/app.bottomsheets.dart';
import 'package:dgg/app/app.dialogs.dart';
import 'package:dgg/app/app.locator.dart';
import 'package:dgg/app/app.router.dart';
import 'package:dgg/datamodels/dgg_vote.dart';
import 'package:dgg/datamodels/embeds.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/stream_status.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:dgg/services/image_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:stacked/stacked.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart'
    as flutter_custom_tabs;

class ChatViewModel extends BaseViewModel {
  final _dggService = locator<DggService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _navigationService = locator<NavigationService>();
  final _bottomSheetService = locator<BottomSheetService>();
  final _snackbarService = locator<SnackbarService>();
  final _dialogService = locator<DialogService>();
  final _imageService = locator<ImageService>();

  late WebViewController webViewController;
  YoutubePlayerController? youtubePlayerController;
  final chatInputController = TextEditingController();

  bool get isLoading => isAuthenticating || !_assetsLoaded;
  bool get isAuthenticating => _dggService.sessionInfo == null;
  bool get isSignedIn => _dggService.isSignedIn;

  bool _assetsLoaded = false;
  bool get assetsLoaded => _assetsLoaded;
  late Flairs _flairs;
  late Emotes _emotes;
  bool _loadingEmote = false;
  final List<Emote> _emoteLoadQueue = [];
  bool _loadingFlair = false;
  final List<Flair> _flairLoadQueue = [];

  StreamSubscription? _chatSubscription;
  final List<Message> _messages = [];
  List<Message> get messages => _isListAtBottom ? _messages : _pausedMessages;
  final Map<String, User> _userMap = {};
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
  static const String rumbleUrlBase = r'https://rumble.com/embed/';
  static const String kickUrlBase = r'https://player.kick.com/';
  String? _currentEmbedId;
  bool _showStreamPrompt = false;
  bool get showStreamPrompt => _showStreamPrompt;
  bool _showEmbed = false;
  bool get showEmbed => _showEmbed;
  EmbedType? _currentEmbedType;
  EmbedType? get currentEmbedType => _currentEmbedType;

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
  bool _flairEnabled = true;
  bool get flairEnabled => _flairEnabled;
  double _flairHeight = 20;
  double get flairHeight => _flairHeight;
  bool _timestampEnabled = false;
  bool get timestampEnabled => _timestampEnabled;

  late List<String> _ignoreList;

  bool _showEmoteSelector = false;
  bool get showEmoteSelector => _showEmoteSelector;
  List<Emote>? emoteSelectorList;

  User? _userHighlighted;
  User? get userHighlighted => _userHighlighted;
  bool get isHighlightOn => _userHighlighted != null;

  Future<void> initialize() async {
    if (!_sharedPreferencesService.getOnboarding()) {
      SchedulerBinding.instance.addPostFrameCallback(
          (_) => _navigationService.clearStackAndShow(Routes.onboardingView));
      return;
    }
    if (_sharedPreferencesService.getWakelockEnabled()) {
      Wakelock.enable();
    }
    _appBarTheme = _sharedPreferencesService.getAppBarTheme();
    _setChatSize();
    _ignoreList = _sharedPreferencesService.getIgnoreList();
    notifyListeners();
    await _getSessionInfo();
    _getInitialStreamStatus();
    await _loadAssets();
    await _getChatHistory();
    _connectChat();
    _showChangelog();
  }

  Future<void> _getSessionInfo() async {
    await _dggService.getSessionInfo();
    notifyListeners();
  }

  Future<void> _loadAssets() async {
    String? cacheKey = await _dggService.fetchDggCacheKey();

    _flairs = await _dggService.fetchFlairs(cacheKey);
    _emotes = await _dggService.fetchEmotes(cacheKey);
    await _imageService.validateCache(cacheKey);
    _assetsLoaded = true;
  }

  Future<void> _getChatHistory() async {
    List<dynamic> rawHistoryMessages = await _dggService.getChatHistory();

    for (int i = 100; i < rawHistoryMessages.length; i++) {
      _processMessage(rawHistoryMessages[i].toString());
    }
  }

  Future<List<Embed>> _getEmbeds() async {
    return _dggService.getEmbeds();
  }

  void _connectChat() {
    _showReconnectButton = false;
    _userMap.clear();
    _messages.add(const StatusMessage(data: "Connecting..."));
    notifyListeners();
    _chatSubscription?.cancel();
    _chatSubscription = _dggService.openWebSocketConnection().stream.listen(
          (data) => _processMessage(data),
          onDone: () => _disconnectChat(),
          onError: (error) => print("STREAM REPORTED ERROR"),
        );
  }

  void _processMessage(String? data) {
    String dataString = data.toString();
    int spaceIndex = dataString.indexOf(' ');
    String key = dataString.substring(0, spaceIndex);
    String jsonString = dataString.substring(spaceIndex + 1);

    switch (key) {
      case "NAMES":
        final namesMessage = NamesMessage.fromJson(jsonString);
        _isChatConnected = true;
        for (var user in namesMessage.users) {
          _userMap[user.nick] = user;
        }
        _messages.add(
          StatusMessage(data: "Connected with ${_userMap.length} users"),
        );
        break;
      case "MSG":
        final userMessage = UserMessage.fromJson(
          jsonString,
          _flairs,
          _emotes,
          _userMap,
          _dggService.currentNick,
        );
        if (_flairEnabled) {
          //for each flair, check if it needs to be loaded
          for (var flair in userMessage.visibleFlairs) {
            if (!flair.loading && flair.image == null) {
              _loadFlair(flair);
            }
          }
        }
        //for each emote, check if needs to be loaded
        for (var element in userMessage.elements) {
          if (element is EmoteElement) {
            if (!element.emote.loading && element.emote.image == null) {
              _loadEmote(element.emote);
            }
          }
        }
        //Check if new message is part of a combo
        if (_messages.isNotEmpty &&
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
                  Timer.periodic(const Duration(seconds: 1), handleVoteTimer);
            }
          }
        }
        //Check if message is stopping a vote
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
              // Cast vote and if it counted break so message is not shown
              if (_currentVote!.castVote(
                userMessage.user.nick,
                vote,
                userMessage.user.features,
              )) {
                break;
              }
            }
          }
        }

        // Check if user is in ignore list before adding
        if (!_ignoreList.contains(userMessage.user.nick)) {
          _messages.add(userMessage);
        }
        break;
      case "JOIN":
        final joinMessage = JoinMessage.fromJson(jsonString);
        _userMap[joinMessage.user.nick] = joinMessage.user;
        break;
      case "QUIT":
        final quitMessage = QuitMessage.fromJson(jsonString);
        _userMap.remove(quitMessage.user.nick);
        break;
      case "BROADCAST":
        final broadcastMessage = BroadcastMessage.fromJson(jsonString);
        _messages.add(broadcastMessage);
        break;
      case "MUTE":
        //Go through up to previous 10 messages and censor messages from muted user
        final muteMessage = MuteMessage.fromJson(jsonString);
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
      case "UNMUTE":
        final unmuteMessage = UnmuteMessage.fromJson(jsonString);
        _messages.add(StatusMessage(
            data: "${unmuteMessage.data} unmuted by ${unmuteMessage.nick}"));
        break;
      case "BAN":
        final banMessage = BanMessage.fromJson(jsonString);
        _messages.add(StatusMessage(
            data: "${banMessage.data} banned by ${banMessage.nick}"));
        break;
      case "UNBAN":
        final unbanMessage = UnbanMessage.fromJson(jsonString);
        _messages.add(StatusMessage(
            data: "${unbanMessage.data} unbanned by ${unbanMessage.nick}"));
        break;
      case "REFRESH":
        _messages.add(
          const StatusMessage(data: "Being disconnected by server..."),
        );
        break;
      case "SUBONLY":
        final subOnlyMessage = SubOnlyMessage.fromJson(jsonString);
        String subMode = subOnlyMessage.data == 'on' ? 'enabled' : 'disabled';
        _messages.add(StatusMessage(
            data: "Subscriber only mode $subMode by ${subOnlyMessage.nick}"));
        break;
      case "ERR":
        final errorMessage = ErrorMessage.fromJson(jsonString);
        if (errorMessage.description == "banned") {
          _messages.add(const StatusMessage(
            data:
                "You have been banned! Check your profile on destiny.gg for more information.",
            isError: true,
          ));
        } else if (errorMessage.description == "muted") {
          _messages.add(const StatusMessage(
            data: "You are temporarily muted!",
            isError: true,
          ));
        } else if (errorMessage.description == "needlogin") {
          // Server thinks user is not logged in
          //    Can try reconnecting to fix it
          _messages.add(const StatusMessage(
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
      case "PIN":
        final pinnedMessage = PinnedMessage.fromJson(jsonString);
        _snackbarService.showSnackbar(
          message:
              'Pinned message from ${pinnedMessage.nick}: ${pinnedMessage.data}',
          duration: const Duration(seconds: 5),
        );
        break;
      default:
        print(data);
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
      _messages.add(const StatusMessage(data: "Disconnected"));
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
    await Future.delayed(const Duration(seconds: 3));
    await _getSessionInfo();
    _connectChat();
  }

  Future<void> _loadEmote(Emote emote, {bool fromQueue = false}) async {
    bool loaded = false;
    // Check if emote has already been loaded before trying to load it
    if (emote.image == null) {
      // Set loading to true for current emote so additional copies are not put in the queue
      emote.loading = true;
      if (_loadingEmote) {
        // Another emote is already being loaded, add current to the queue
        _emoteLoadQueue.add(emote);
      } else {
        // Load emote
        _loadingEmote = true;
        emote.image = await _imageService.loadAndProcessEmote(emote);

        emote.loading = false;
        _loadingEmote = false;
        loaded = true;
        notifyListeners();
      }
    }

    // If load request came from queue and emote is loaded, remove it
    if (fromQueue && emote.image != null) {
      _emoteLoadQueue.removeAt(0);
    }

    // If loaded emote and still have emotes in the queue, start loading the next one
    if (loaded && _emoteLoadQueue.isNotEmpty) {
      _loadEmote(_emoteLoadQueue.first, fromQueue: true);
    }
  }

  Future<void> _loadFlair(Flair flair, {bool fromQueue = false}) async {
    bool loaded = false;
    // Check if flair has already been loaded before trying to load it
    if (flair.image == null) {
      // Set loading to true for current flair so additional copies are not put in the queue
      flair.loading = true;
      if (_loadingFlair) {
        // Another flair is already being loaded, add current to the queue
        _flairLoadQueue.add(flair);
      } else {
        // Load flair
        _loadingFlair = true;
        flair.image = await _imageService.loadAndProcessFlair(flair);

        flair.loading = false;
        _loadingFlair = false;
        loaded = true;
        notifyListeners();
      }
    }

    // If load request came from queue and flair is loaded, remove it
    if (fromQueue && flair.image != null) {
      _flairLoadQueue.removeAt(0);
    }

    // If loaded flair and still have flairs in the queue, start loading the next one
    if (loaded && _flairLoadQueue.isNotEmpty) {
      _loadFlair(_flairLoadQueue.first, fromQueue: true);
    }
  }

  void uncensorMessage(UserMessage message) {
    message.isCensored = false;
    notifyListeners();
  }

  Future<void> menuItemClick(AppBarActions selected) async {
    switch (selected) {
      case AppBarActions.SETTINGS:
        // Navigate to settings
        // Disconnect chat/turn off wakelock while in settings
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
        _ignoreList = _sharedPreferencesService.getIgnoreList();
        _connectChat();
        break;
      case AppBarActions.CONNECTION:
        // Disconnect or reconnect
        if (_isChatConnected) {
          _disconnectChat();
        } else if (_showReconnectButton) {
          _connectChat();
        }
        break;
      case AppBarActions.REFRESH:
        // Refresh assets
        // First disconnect from chat
        await _disconnectChat();
        // Then clear assets
        _assetsLoaded = false;
        // Finally fetch assets
        await _loadAssets();
        notifyListeners();
        // Re-open chat
        _connectChat();
        break;
      case AppBarActions.OPEN_DESTINY_STREAM:
        _openDestinyStream();
        break;
      case AppBarActions.OPEN_TWITCH_STREAM:
        // Prompt user to enter a Twitch channel name and try to open it
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.textInput,
          title: 'Open Twitch stream',
          data: 'Twitch channel name',
          mainButtonTitle: 'Open',
          barrierDismissible: true,
        );
        if (response != null && response.data != null) {
          String channel = response.data.trim();
          if (channel.isNotEmpty) {
            setEmbed(channel, EmbedType.TWITCH_STREAM);
          }
        }
        break;
      case AppBarActions.OPEN_KICK_STREAM:
        // Prompt user to enter a Kick channel name and try to open it
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.textInput,
          title: 'Open Kick stream',
          data: 'Kick channel name',
          mainButtonTitle: 'Open',
          barrierDismissible: true,
        );
        if (response != null && response.data != null) {
          String channel = response.data.trim();
          if (channel.isNotEmpty) {
            setEmbed(channel, EmbedType.KICK);
          }
        }
        break;
      case AppBarActions.GET_RECENT_EMBEDS:
        // Get top embeds from past 30 minutes and allow user to select one
        final response = await _dialogService.showCustomDialog(
          variant: DialogType.selectEmbed,
          title: 'Recent embeds',
          data: _getEmbeds(),
          barrierDismissible: true,
        );
        if (response != null && response.data != null) {
          if (response.data.platform == "youtube") {
            var link = response.data.link as String;
            setEmbedFromStringType(link.split("/")[1], response.data.platform);
          } else {
            setEmbedFromStringType(
                response.data.channel, response.data.platform);
          }
        }
        break;
      default:
        print("ERROR: Invalid chat menu item");
    }
  }

  void updateChatDraft(String value) {
    _draft = value;
    _updateSuggestions();
  }

  void sendChatMessage({bool commandCheck = true}) {
    String draftTrim = _draft.trim();
    if (draftTrim.isNotEmpty && isChatConnected) {
      if (commandCheck && draftTrim.startsWith("/")) {
        // Message is probably a command, verify with user before sending
        verifyMessageBeforeSending();
      } else {
        // Send message normally
        _dggService.sendChatMessage(draftTrim);
        updateChatDraft('');
        chatInputController.clear();
      }
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

        for (var element in _suggestions) {
          if (element.startsWith(lastWordRegex)) {
            newSuggestions.add(element);
          }
        }
      } else {
        //Current last word does not start with previous last word
        //  Backspace, new word, or something similar happened
        //  Start suggestion generation from beginning
        RegExp lastWordRegex = RegExp(
          RegExp.escape(lastWord),
          caseSensitive: false,
        );

        //check emotes
        _emotes.emoteMap.forEach((k, v) {
          if (k.startsWith(lastWordRegex)) {
            newSuggestions.add(k);
          }
        });

        //check user names
        for (var user in _userMap.values) {
          if (user.nick.startsWith(lastWordRegex)) {
            newSuggestions.add(user.nick);
          }
        }
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

  void enableHighlightUser(User user) {
    _userHighlighted = user;
    notifyListeners();
  }

  void disableHighlightUser() {
    _userHighlighted = null;
    notifyListeners();
  }

  Future<void> _getInitialStreamStatus() async {
    StreamStatus streamStatus = await _dggService.getStreamStatus();
    // If any of the platforms are live, show stream prompt
    if (streamStatus.twitchLive ||
        streamStatus.youtubeLive ||
        streamStatus.rumbleLive ||
        streamStatus.kickLive) {
      _showStreamPrompt = true;
      notifyListeners();
    }
  }

  void answerInitialStreamPrompt(bool value) {
    _showStreamPrompt = false;
    notifyListeners();
    if (value) {
      _openDestinyStream();
    }
  }

  void toggleEmbed() {
    // If turning off embed, stop any ongoing videos
    if (_showEmbed) {
      youtubePlayerController?.close();
      youtubePlayerController = null;

      _showStreamPrompt = false;
      _showEmbed = !_showEmbed;
      notifyListeners();
    } else if (_currentEmbedId != null && _currentEmbedType != null) {
      // Otherwise, set embed with current id and type
      setEmbed(_currentEmbedId!, _currentEmbedType!);
    }
  }

  void setEmbedFromStringType(String embedId, String embedTypeString) {
    // Convert string embed type to enum and call actual setEmbed
    late EmbedType embedType;
    switch (embedTypeString) {
      case 'twitch':
        embedType = EmbedType.TWITCH_STREAM;
        break;
      case 'youtube':
        embedType = EmbedType.YOUTUBE;
        break;
      case 'twitch-vod':
        embedType = EmbedType.TWITCH_VOD;
        break;
      case 'twitch-clip':
        embedType = EmbedType.TWITCH_CLIP;
        break;
      case 'rumble':
        embedType = EmbedType.RUMBLE;
        break;
      case 'kick':
        embedType = EmbedType.KICK;
        break;
      default:
        embedType = EmbedType.UNSUPPORTED;
        break;
    }

    setEmbed(embedId, embedType);
  }

  void setEmbed(String embedId, EmbedType embedType) {
    // Stop other ongoing embeds
    if (embedType != EmbedType.YOUTUBE) {
      youtubePlayerController?.close();
      youtubePlayerController = null;
    }
    // Set new embed id
    _currentEmbedId = embedId.trim();
    switch (embedType) {
      case EmbedType.TWITCH_STREAM:
        // If webview embed already shown, use controller
        if (_showEmbed && _isUsingWebViewEmbed()) {
          webViewController.loadUrl(twitchStreamUrlBase + _currentEmbedId!);
        }
        _currentEmbedType = EmbedType.TWITCH_STREAM;
        break;
      case EmbedType.YOUTUBE:
        // If embed already shown, use controller to load new stream
        if (_showEmbed && _currentEmbedType == EmbedType.YOUTUBE) {
          youtubePlayerController!.load(_currentEmbedId!);
        } else {
          youtubePlayerController?.close();
          youtubePlayerController = YoutubePlayerController(
            initialVideoId: _currentEmbedId!,
            params: const YoutubePlayerParams(
              autoPlay: true,
              showControls: true,
            ),
          );
        }
        _currentEmbedType = EmbedType.YOUTUBE;
        break;
      case EmbedType.TWITCH_VOD:
        // If webview embed already shown, use controller
        if (_showEmbed && _isUsingWebViewEmbed()) {
          webViewController.loadUrl(twitchVodUrlBase + _currentEmbedId!);
        }
        _currentEmbedType = EmbedType.TWITCH_VOD;
        break;
      case EmbedType.TWITCH_CLIP:
        // If webview embed already shown, use controller
        if (_showEmbed && _isUsingWebViewEmbed()) {
          webViewController.loadUrl(twitchClipUrlBase + _currentEmbedId!);
        }
        _currentEmbedType = EmbedType.TWITCH_CLIP;
        break;
      case EmbedType.RUMBLE:
        // If webview embed already shown, use controller
        if (_showEmbed && _isUsingWebViewEmbed()) {
          webViewController.loadUrl(rumbleUrlBase + _currentEmbedId!);
        }
        _currentEmbedType = EmbedType.RUMBLE;
        break;
      case EmbedType.KICK:
        // If webview embed already shown, use controller
        if (_showEmbed && _isUsingWebViewEmbed()) {
          webViewController
              .loadUrl(kickUrlBase + _currentEmbedId! + '?muted=false');
        }
        _currentEmbedType = EmbedType.KICK;
        break;
      default:
        _snackbarService.showSnackbar(
          message: "$embedType is not currently supported",
          duration: const Duration(seconds: 2),
        );
        return;
    }

    //Show the stream embed
    _showStreamPrompt = false;
    _showEmbed = true;
    notifyListeners();
  }

  Future<void> _openDestinyStream() async {
    _showEmbed = true;
    _currentEmbedType = null;
    _showStreamPrompt = false;
    notifyListeners();
    StreamStatus streamStatus = await _dggService.getStreamStatus();

    int liveCount = (streamStatus.twitchLive ? 1 : 0) +
        (streamStatus.youtubeLive && streamStatus.youtubeId != null ? 1 : 0) +
        (streamStatus.rumbleLive && streamStatus.rumbleId != null ? 1 : 0) +
        (streamStatus.kickLive && streamStatus.kickId != null ? 1 : 0);

    if (liveCount == 0) {
      // Not live
      _snackbarService.showSnackbar(
        message: "Destiny is offline",
        duration: const Duration(seconds: 2),
      );
      _showEmbed = false;
      notifyListeners();
    } else if (liveCount == 1) {
      // Live on one platform
      if (streamStatus.youtubeLive && streamStatus.youtubeId != null) {
        setEmbed(streamStatus.youtubeId!, EmbedType.YOUTUBE);
      } else if (streamStatus.rumbleLive && streamStatus.rumbleId != null) {
        setEmbed(streamStatus.rumbleId!, EmbedType.RUMBLE);
      } else if (streamStatus.kickLive) {
        setEmbed("destiny", EmbedType.KICK);
      } else if (streamStatus.twitchLive) {
        setEmbed("destiny", EmbedType.TWITCH_STREAM);
      }
    } else {
      // Live on multiple platforms, ask user for preference
      final response = await _dialogService.showCustomDialog(
        variant: DialogType.selectPlatform,
        data: streamStatus,
        barrierDismissible: true,
      );

      if (response?.data != null) {
        if (response!.data == EmbedType.YOUTUBE) {
          setEmbed(streamStatus.youtubeId!, EmbedType.YOUTUBE);
        } else if (response.data == EmbedType.RUMBLE) {
          setEmbed(streamStatus.rumbleId!, EmbedType.RUMBLE);
        } else if (response.data == EmbedType.KICK) {
          setEmbed("destiny", EmbedType.KICK);
        } else if (response.data == EmbedType.TWITCH_STREAM) {
          setEmbed("destiny", EmbedType.TWITCH_STREAM);
        }
      }

      notifyListeners();
    }
  }

  bool _isUsingWebViewEmbed() =>
      currentEmbedType == EmbedType.TWITCH_STREAM ||
      currentEmbedType == EmbedType.TWITCH_VOD ||
      currentEmbedType == EmbedType.TWITCH_CLIP ||
      currentEmbedType == EmbedType.RUMBLE ||
      currentEmbedType == EmbedType.KICK;

  String getEmbedUrl() {
    if (_currentEmbedId == null) return 'https://destiny.gg';

    switch (_currentEmbedType) {
      case EmbedType.TWITCH_STREAM:
        return twitchStreamUrlBase + _currentEmbedId!;
      case EmbedType.TWITCH_VOD:
        return twitchVodUrlBase + _currentEmbedId!;
      case EmbedType.TWITCH_CLIP:
        return twitchClipUrlBase + _currentEmbedId!;
      case EmbedType.RUMBLE:
        return rumbleUrlBase + _currentEmbedId!;
      case EmbedType.KICK:
        return kickUrlBase + _currentEmbedId! + '?muted=false';
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

    if (await url_launcher.canLaunch(urlToOpen)) {
      // Check if in-app browser option enabled
      if (_sharedPreferencesService.getInAppBrowserEnabled()) {
        flutter_custom_tabs.launch(urlToOpen);
      } else {
        url_launcher.launch(urlToOpen);
      }
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
      variant: BottomSheetType.messageActionBottom,
      data: message,
      barrierDismissible: true,
    );

    if (sheetResponse != null) {
      switch (sheetResponse.data) {
        case MessageAction.copy:
          Clipboard.setData(ClipboardData(text: message!.data));
          break;
        case MessageAction.reply:
          String newDraft = '${message!.user.nick} ';
          updateChatDraft(newDraft);
          chatInputController.text = newDraft;
          chatInputController.selection =
              TextSelection.fromPosition(TextPosition(offset: newDraft.length));
          break;
        case MessageAction.ignore:
          // Make sure user is not already in the list
          if (!_ignoreList.contains(message!.user.nick)) {
            // Add to ignore list
            _ignoreList.add(message.user.nick);
            _sharedPreferencesService.setIgnoreList(_ignoreList);
            // Remove newly ignored user's messages from the chat
            for (int i = 0; i < _messages.length; i++) {
              if (_messages[i] is UserMessage &&
                  (_messages[i] as UserMessage).user.nick ==
                      message.user.nick) {
                _messages.removeAt(i);
                i--;
              }
            }
            notifyListeners();
          }

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

  Future<void> _showChangelog() async {
    bool showChangelog = await _sharedPreferencesService.shouldShowChangelog();
    if (showChangelog) {
      _dialogService.showDialog(
        title: "What's new",
        description:
            "• Rotating the screen no longer causes embeds to refresh (thanks to Ricky434).\n• Framework upgrade should improve performance.",
      );
    }
  }

  void _setChatSize() {
    int textSize = _sharedPreferencesService.getChatTextSize();
    int emoteSize = _sharedPreferencesService.getChatEmoteSize();
    _flairEnabled = _sharedPreferencesService.getFlairEnabled();
    int flairSize = _sharedPreferencesService.getChatFlairSize();
    _timestampEnabled = _sharedPreferencesService.getTimestampEnabled();
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
    // Set flair size
    if (flairSize == 0) {
      _flairHeight = 15;
    } else if (flairSize == 1) {
      _flairHeight = 20;
    } else if (flairSize == 2) {
      _flairHeight = 25;
    }
  }

  Future<void> verifyMessageBeforeSending() async {
    DialogResponse? response = await _dialogService.showConfirmationDialog(
      title: "Confirm message",
      description:
          "Looks like you are sending a message with a command.\n\nNot all commands are implemented in the app, for example private messages do not work and are sent as a normal chat message.\n\nIf you want to send the message anyway, make sure it is something you are okay with being sent as a regular message just in case.",
      confirmationTitle: "Send",
      cancelTitle: "Cancel",
    );

    if (response != null && response.confirmed) {
      // User wants to send the message anyway
      sendChatMessage(commandCheck: false);
    }
  }

  void toggleEmoteSelector() {
    _showEmoteSelector = !_showEmoteSelector;
    notifyListeners();
    // Load all emotes if not all already loaded
    if (emoteSelectorList == null) {
      emoteSelectorList = _emotes.emoteMap.values.toList();
      for (var emote in emoteSelectorList!) {
        if (!emote.loading && emote.image == null) {
          _loadEmote(emote);
        }
      }
    }
  }

  void emoteSelected(int index) {
    late String newDraft;
    if (_draft.endsWith(" ") || _draft.isEmpty) {
      // Draft ends with space or is empty, just append emote name
      newDraft = _draft + emoteSelectorList![index].name + " ";
    } else {
      // Draft does not end with a space and is not empty, add emote name with spaces
      newDraft = _draft + " " + emoteSelectorList![index].name + " ";
    }

    updateChatDraft(newDraft);
    chatInputController.text = newDraft;
    chatInputController.selection =
        TextSelection.fromPosition(TextPosition(offset: newDraft.length));
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
  RUMBLE,
  KICK,
  UNSUPPORTED,
}

enum AppBarActions {
  SETTINGS,
  CONNECTION,
  REFRESH,
  OPEN_DESTINY_STREAM,
  OPEN_TWITCH_STREAM,
  GET_RECENT_EMBEDS,
  OPEN_KICK_STREAM,
}

enum MessageAction {
  copy,
  reply,
  ignore,
}
