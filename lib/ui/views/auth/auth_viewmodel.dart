import 'package:dgg/services/crypto_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:dgg/app/locator.dart';
import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/services/cookie_manager_service.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class AuthViewModel extends BaseViewModel {
  static const int AUTH_METHOD_WEBVIEW = 0;
  static const int AUTH_METHOD_LOGIN_KEY = 1;

  final _cookieManagerService = locator<CookieManagerService>();
  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _navigationService = locator<NavigationService>();
  final _cryptoService = locator<CryptoService>();

  int _authMethod;
  int get authMethod => _authMethod;
  bool get isAuthMethodSelected => _authMethod != null;

  bool _isAuthStarted = false;
  bool get isAuthStarted => _isAuthStarted;

  bool _isSavingAuth = false;
  bool get isSavingAuth => _isSavingAuth;

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
    AuthInfo authInfo = await _cookieManagerService.readCookies(currentUrl);

    if (authInfo != null) {
      await _sharedPreferencesService.storeAuthInfo(authInfo);
      _navigationService.back();
    }
  }

  void setAuthMethod(int method) {
    _authMethod = method;
    notifyListeners();
  }

  Future<void> getKeyFromClipboard() async {
    _isSavingAuth = true;
    notifyListeners();
    ClipboardData data = await Clipboard.getData('text/plain');
    String loginKey = data.text;
    
    if (loginKey != null) {
      await _sharedPreferencesService
          .storeAuthInfo(AuthInfo(loginKey: loginKey));
      _navigationService.back();
    } else {
      _isSavingAuth = false;
    }
    notifyListeners();
  }

  Future<void> startTokenAuth() async {
    //Things for exchange
    String appId = "***CLIENT ID***";
    String secret = r"***CLIENT SECRET***";

    String state = _cryptoService.generateRandomString(64);
    String codeVerifier = _cryptoService.generateRandomString(64);

    String codeChallenge =
        _cryptoService.generateCodeChallenge(secret, codeVerifier);

    // Start listening
    getUriLinksStream().listen((Uri uri) {
      // Use the uri and warn the user, if it is not correct
      String fetchedCode = uri.queryParameters['code'];
      String fetchedState = uri.queryParameters['state'];
      if (state == fetchedState) {
        _getAuthToken(appId, fetchedCode, codeVerifier);
      } else {
        print("State returned by server did not match");
      }
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
      print("Listening to deep link broke");
    });

    //Make url and send user
    Uri uri = Uri.parse("https://www.destiny.gg/oauth/authorize");
    uri = uri.replace(queryParameters: {
      "response_type": "code",
      "client_id": appId,
      "redirect_uri": "dev.moseco.dgg://auth",
      "state": state,
      "code_challenge": codeChallenge,
    });

    print(uri.toString());
    launch(uri.toString());
  }

  Future<void> _getAuthToken(
      String appId, String code, String codeVerifier) async {
    Uri uri = Uri.parse("https://www.destiny.gg/oauth/token");
    uri = uri.replace(queryParameters: {
      "grant_type": "authorization_code",
      "code": code,
      "client_id": appId,
      "redirect_uri": "dev.moseco.dgg://auth",
      "code_verifier": codeVerifier,
    });

    final response = await http.get(uri.toString());

    if (response.statusCode == 200) {
      print(response.body);
    } else {
      print("Http error ${response.statusCode}");
    }
  }
}
