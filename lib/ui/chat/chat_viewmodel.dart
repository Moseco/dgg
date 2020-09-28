import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:stacked/stacked.dart';
import 'package:dgg/app/locator.dart';
import 'package:dgg/services/dgg_api.dart';

class ChatViewModel extends BaseViewModel {
  final _dggApi = locator<DggApi>();

  bool get isAssetsLoaded => _dggApi.isAssetsLoaded;

  List<Message> get messages => _dggApi.messages;
  List<User> get users => _dggApi.users;

  void initialize() async {
    await _dggApi.getAssets();
    notifyListeners();
    openChat();
  }

  void openChat() {
    _dggApi.openWebSocketConnection(() => notifyListeners());
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
        openChat();
        break;
      default:
        print("ERROR: Invalid chat menu item");
    }
  }

  @override
  void dispose() {
    _dggApi.closeWebSocket();
    super.dispose();
  }
}
