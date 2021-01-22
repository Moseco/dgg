import 'dart:convert';

import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:dgg/services/remote_config_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:stacked/stacked.dart';
import 'package:dgg/app/locator.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:wakelock/wakelock.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class ChatViewModel extends BaseViewModel {
  final _dggService = locator<DggService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _remoteConfigService = locator<RemoteConfigService>();

  WebViewController webViewController;

  bool get isAssetsLoaded => _dggService.isAssetsLoaded;
  bool get isSignedIn => _dggService.sessionInfo is Available;
  bool get isChatConnected => _dggService.isChatConnected;

  List<Message> get messages =>
      _isListAtBottom ? _dggService.messages : _pausedMessages;
  List<User> get users => _dggService.users;

  String _draft = '';
  String get draft => _draft;
  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;
  String _previousLastWord = '';

  bool _isListAtBottom = true;
  bool get isListAtBottom => _isListAtBottom;
  List<Message> _pausedMessages = [];

  bool _wakelockEnabled;

  String get twitchUrlBase =>
      'https://player.twitch.tv/?parent=dev.moseco.dgg&muted=false&channel=';
  String _currentStreamChannel = 'destiny';
  String get currentStreamChannel => _currentStreamChannel;
  bool _showStreamPrompt = false;
  bool get showStreamPrompt => _showStreamPrompt;
  bool _showStreamEmbed = false;
  bool get showStreamEmbed => _showStreamEmbed;

  Future<void> initialize() async {
    _wakelockEnabled = await _sharedPreferencesService.getWakelockEnabled();
    if (_wakelockEnabled) {
      Wakelock.enable();
    }
    _getStreamStatus();
    await _dggService.getAssets();
    notifyListeners();
    _openChat();
  }

  void _openChat() {
    _dggService.openWebSocketConnection(_updateChat);
  }

  void uncensorMessage(UserMessage message) {
    message.isCensored = false;
    notifyListeners();
  }

  Future<void> menuItemClick(int selected) async {
    switch (selected) {
      case 0:
        await _dggService.disconnect();
        notifyListeners();
        break;
      case 1:
        _dggService.reconnect(() => notifyListeners());
        break;
      case 2:
        //First clear assets
        await _dggService.clearAssets();
        notifyListeners();
        //Fetch assets
        await _dggService.getAssets();
        notifyListeners();
        //Re-open chat
        _openChat();
        break;
      default:
        print("ERROR: Invalid chat menu item");
    }
  }

  void updateChatDraft(String value) {
    _draft = value;
    _updateSuggestions();
  }

  bool sendChatMessage() {
    String draftTrim = _draft.trim();
    if (draftTrim.isNotEmpty && isChatConnected) {
      _dggService.sendChatMessage(draftTrim);
      updateChatDraft('');
      return true;
    } else {
      return false;
    }
  }

  String completeSuggestion(int suggestionIndex) {
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
    return newDraft;
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
        _dggService.users.forEach((user) {
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

  void _updateChat() {
    if (_isListAtBottom) {
      notifyListeners();
    }
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
        'https://api.twitch.tv/kraken/streams/18074328',
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

  void setStreamChannel(List<String> channel) {
    if (channel != null && channel[0].trim().isNotEmpty) {
      //Set new channel name
      _currentStreamChannel = channel[0].trim();
      if (_showStreamEmbed) {
        //Embed already shown, use controller to load new stream
        webViewController.loadUrl(twitchUrlBase + _currentStreamChannel);
      } else {
        //Embed not shown, show embed
        setShowStreamEmbed(true);
      }
    }
  }

  @override
  void dispose() {
    if (_wakelockEnabled) {
      Wakelock.disable();
    }
    _dggService.closeWebSocket();
    super.dispose();
  }
}
