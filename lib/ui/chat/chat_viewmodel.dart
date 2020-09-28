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

  initialize() async {
    await _dggApi.getFlairs();
    await _dggApi.getEmotes();
    notifyListeners();
    openChat();
  }

  openChat() {
    _dggApi.openWebSocketConnection(() => notifyListeners());
  }

  uncensorMessage(int messageIndex) {
    _dggApi.uncensorMessage(messageIndex);
    notifyListeners();
  }

  @override
  dispose() {
    _dggApi.closeWebSocket();
    super.dispose();
  }
}
