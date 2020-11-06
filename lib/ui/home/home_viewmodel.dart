import 'package:dgg/app/locator.dart';
import 'package:dgg/app/router.gr.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/dgg_api.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class HomeViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _dggApi = locator<DggApi>();

  SessionInfo _sessionInfo;
  SessionInfo get sessionInfo => _sessionInfo;

  Future<void> initialize() async {
    _sessionInfo = await _dggApi.getSessionInfo();
    notifyListeners();
  }

  Future<void> navigateToAuth() async {
    await _navigationService.navigateTo(Routes.authView);
    _sessionInfo = null;
    notifyListeners();
    initialize();
  }

  Future<void> navigateToChat() async {
    await _navigationService.navigateTo(Routes.chatView);
  }
}
