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

  bool _isStarted = false;
  bool get isStarted => _isStarted;

  startAuthentication() {
    _isStarted = true;
    _cookieManagerService.clearCookies();
    notifyListeners();
  }

  Future readCookies(String currentUrl) async {
    AuthInfo authInfo = await _cookieManagerService.readCookies(currentUrl);

    if (authInfo != null) {
      await _sharedPreferencesService.storeAuthInfo(authInfo);
      _navigationService.back();
    }
  }
}
