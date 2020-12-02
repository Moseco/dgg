import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:stacked/stacked.dart';
import 'package:dgg/app/locator.dart';
import 'package:dgg/services/dgg_api.dart';

class ChatViewModel extends BaseViewModel {
  final _dggApi = locator<DggApi>();

  bool get isAssetsLoaded => _dggApi.isAssetsLoaded;
  bool get isSignedIn => _dggApi.sessionInfo is Available;
  bool get isChatConnected => _dggApi.isChatConnected;

  List<Message> get messages => _dggApi.messages;
  List<User> get users => _dggApi.users;

  String _draft = '';
  String get draft => _draft;
  List<String> _suggestions = [];
  List<String> get suggestions => _suggestions;
  String _previousLastWord = '';

  bool _isListAtBottom = true;
  bool get isListAtBottom => _isListAtBottom;

  void initialize() async {
    await _dggApi.getAssets();
    notifyListeners();
    _openChat();
  }

  void _openChat() {
    _dggApi.openWebSocketConnection(_updateChat);
  }

  void uncensorMessage(int messageIndex) {
    _dggApi.uncensorMessage(messageIndex);
    notifyListeners();
  }

  void menuItemClick(String selected) async {
    switch (selected) {
      case "Disconnect":
        await _dggApi.disconnect();
        notifyListeners();
        break;
      case "Reconnect":
        _dggApi.reconnect(() => notifyListeners());
        break;
      case "Refresh assets":
        //First clear assets
        await _dggApi.clearAssets();
        notifyListeners();
        //Fetch assets
        await _dggApi.getAssets();
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
      _dggApi.sendChatMessage(draftTrim);
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
        _dggApi.emotes.emoteMap.forEach((k, v) {
          if (k.startsWith(lastWordRegex)) {
            newSuggestions.add(k);
          }
        });

        //check user names
        _dggApi.users.forEach((user) {
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
      _isListAtBottom = isListAtBottom;
      notifyListeners();
    } else {
      _isListAtBottom = isListAtBottom;
    }
  }

  @override
  void dispose() {
    _dggApi.closeWebSocket();
    super.dispose();
  }
}
