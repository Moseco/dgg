import 'package:dgg/app/locator.dart';
import 'package:dgg/app/router.gr.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/dgg_api.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dggApi = locator<DggApi>();

  SessionInfo get sessionInfo => _dggApi.sessionInfo;

  void initialize() {
    _getSessionInfo();
  }

  Future<void> navigateToAuth() async {
    await _navigationService.navigateTo(Routes.authView);
    notifyListeners();
    _getSessionInfo();
  }

  void navigateToChat() {
    _navigationService.navigateTo(Routes.chatView);
  }

  Future<void> _getSessionInfo() async {
    await _dggApi.getSessionInfo();
    notifyListeners();
  }
}
