import 'package:dgg/datamodels/auth_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String KEY_SID = "KEY_SID";
  static const String KEY_REMEMBER_ME = "KEY_REMEMBER_ME";
  static const String KEY_LOGIN_KEY = "KEY_LOGIN_KEY";
  static const String KEY_ANALYTICS_ENABLED = "KEY_ANALYTICS_ENABLED";
  static const String KEY_WAKELOCK_ENABLED = "KEY_WAKELOCK_ENABLED";
  static const String KEY_ONBOARDING = "KEY_ONBOARDING";

  SharedPreferences? _sharedPreferences;

  Future<void> initialize() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
  }

  AuthInfo? getAuthInfo() {
    String? sid = _sharedPreferences!.getString(KEY_SID);
    String? rememberMe = _sharedPreferences!.getString(KEY_REMEMBER_ME);
    String? loginKey = _sharedPreferences!.getString(KEY_LOGIN_KEY);

    if (sid != null) {
      return AuthInfo(
        sid: sid,
        rememberMe: rememberMe,
      );
    } else if (loginKey != null) {
      return AuthInfo(loginKey: loginKey);
    } else {
      return null;
    }
  }

  Future<void> storeAuthInfo(AuthInfo authInfo) async {
    // Check and store sid
    if (authInfo.sid != null) {
      await _sharedPreferences!.setString(KEY_SID, authInfo.sid!);
    }
    // Check and store rememberme
    if (authInfo.rememberMe != null) {
      await _sharedPreferences!.setString(KEY_REMEMBER_ME, authInfo.rememberMe!);
    }
    // Check and store loginKey
    if (authInfo.loginKey != null) {
      await _sharedPreferences!.setString(KEY_LOGIN_KEY, authInfo.loginKey!);
    }
  }

  Future<void> clearAuthInfo() async {
    await Future.wait([
      _sharedPreferences!.remove(KEY_SID),
      _sharedPreferences!.remove(KEY_REMEMBER_ME),
      _sharedPreferences!.remove(KEY_LOGIN_KEY),
    ]);
  }

  bool getAnalyticsEnabled() {
    return _sharedPreferences!.getBool(KEY_ANALYTICS_ENABLED) ?? true;
  }

  Future<void> setAnalyticsEnabled(bool value) async {
    await _sharedPreferences!.setBool(KEY_ANALYTICS_ENABLED, value);
  }

  bool getWakelockEnabled() {
    return _sharedPreferences!.getBool(KEY_WAKELOCK_ENABLED) ?? true;
  }

  Future<void> setWakelockEnabled(bool value) async {
    await _sharedPreferences!.setBool(KEY_WAKELOCK_ENABLED, value);
  }

  bool getOnboarding() {
    return _sharedPreferences!.getBool(KEY_ONBOARDING) ?? false;
  }

  Future<void> setOnboarding() async {
    await _sharedPreferences!.setBool(KEY_ONBOARDING, true);
  }

  int getThemeIndex() {
    //This will potentially break in the future
    //The key is taken from stacked_themes source code
    return _sharedPreferences!.getInt("user_key") ?? 0;
  }
}
