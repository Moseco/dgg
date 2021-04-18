import 'package:dgg/app/app.locator.dart';
import 'package:dgg/services/dgg_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/services/cookie_manager_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthViewModel extends BaseViewModel {
  static const int AUTH_METHOD_WEBVIEW = 0;
  static const int AUTH_METHOD_LOGIN_KEY = 1;

  final _cookieManagerService = locator<CookieManagerService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _navigationService = locator<NavigationService>();
  final _dggService = locator<DggService>();

  int? _authMethod;
  int? get authMethod => _authMethod;
  bool get isAuthMethodSelected => _authMethod != null;

  bool _isAuthStarted = false;
  bool get isAuthStarted => _isAuthStarted;

  bool _isSavingAuth = false;
  bool get isSavingAuth => _isSavingAuth;

  bool _isVerifyFailed = false;
  bool get isVerifyFailed => _isVerifyFailed;

  bool _isClipboardError = false;
  bool get isClipboardError => _isClipboardError;

  Future<void> initialize() async {
    await _sharedPreferencesService.initialize();
  }

  void setAuthMethod(int? method) {
    _authMethod = method;
    notifyListeners();
  }

  void startAuthentication() {
    _isAuthStarted = true;
    if (_authMethod == AUTH_METHOD_WEBVIEW) {
      _cookieManagerService.clearCookies();
    } else {
      launch("https://www.destiny.gg/profile/developer");
    }
    notifyListeners();
  }

  Future<void> readCookies(String currentUrl) async {
    AuthInfo? authInfo = await _cookieManagerService.readCookies(currentUrl);

    if (authInfo != null) {
      _isSavingAuth = true;
      notifyListeners();
      _sharedPreferencesService.storeAuthInfo(authInfo);
      _getSessionInfo();
    }
  }

  Future<void> getKeyFromClipboard() async {
    _isSavingAuth = true;
    notifyListeners();
    ClipboardData? data = await Clipboard.getData('text/plain');
    String? loginKey = data?.text;

    if (loginKey != null && loginKey.isNotEmpty) {
      _sharedPreferencesService.storeAuthInfo(AuthInfo(loginKey: loginKey));
      _getSessionInfo();
    } else {
      _isSavingAuth = false;
      _isClipboardError = true;
      notifyListeners();
    }
  }

  Future<void> _getSessionInfo() async {
    await _dggService.getSessionInfo();
    if (_dggService.isSignedIn) {
      //Success
      _navigationService.back();
    } else {
      //Verification failed
      _dggService.signOut();
      _isVerifyFailed = true;
      notifyListeners();
    }
  }

  void goBackToInstructions() {
    _isAuthStarted = false;
    notifyListeners();
  }

  Future<bool> handleOnWillPop() async {
    if (isSavingAuth) {
      return true;
    } else if (isAuthStarted) {
      goBackToInstructions();
      return false;
    } else if (isAuthMethodSelected) {
      setAuthMethod(null);
      return false;
    } else {
      return true;
    }
  }

  void restartAuth() {
    _authMethod = null;
    _isAuthStarted = false;
    _isSavingAuth = false;
    _isVerifyFailed = false;
    _isClipboardError = false;
    notifyListeners();
  }
}
