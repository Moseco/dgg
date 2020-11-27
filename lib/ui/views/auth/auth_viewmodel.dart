import 'package:dgg/services/shared_preferences_service.dart';
import 'package:stacked/stacked.dart';
import 'package:dgg/app/locator.dart';
import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/services/cookie_manager_service.dart';
import 'package:stacked_services/stacked_services.dart';

class AuthViewModel extends BaseViewModel {
  final _cookieManagerService = locator<CookieManagerService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _navigationService = locator<NavigationService>();

  bool _isAuthStarted = false;
  bool get isAuthStarted => _isAuthStarted;

  void startAuthentication() {
    _isAuthStarted = true;
    _cookieManagerService.clearCookies();
    notifyListeners();
  }

  Future<void> readCookies(String currentUrl) async {
    AuthInfo authInfo = await _cookieManagerService.readCookies(currentUrl);

    if (authInfo != null) {
      await _sharedPreferencesService.storeAuthInfo(authInfo);
      _navigationService.back();
    }
  }
}
