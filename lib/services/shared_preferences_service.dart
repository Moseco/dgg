import 'package:dgg/datamodels/auth_info.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SharedPreferencesService {
  static const String KEY_SID = "KEY_SID";
  static const String KEY_REMEMBER_ME = "KEY_REMEMBER_ME";
  static const String KEY_LOGIN_KEY = "KEY_LOGIN_KEY";
  static const String KEY_ANALYTICS_ENABLED = "KEY_ANALYTICS_ENABLED";
  static const String KEY_WAKELOCK_ENABLED = "KEY_WAKELOCK_ENABLED";

  SharedPreferences _sharedPreferences;

  Future<AuthInfo> getAuthInfo() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    String sid = _sharedPreferences.getString(KEY_SID);
    String rememberMe = _sharedPreferences.getString(KEY_REMEMBER_ME);
    String loginKey = _sharedPreferences.getString(KEY_LOGIN_KEY);

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
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    _sharedPreferences.setString(KEY_SID, authInfo.sid);
    _sharedPreferences.setString(KEY_REMEMBER_ME, authInfo.rememberMe);
    _sharedPreferences.setString(KEY_LOGIN_KEY, authInfo.loginKey);
  }

  Future<void> clearAuthInfo() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    _sharedPreferences.remove(KEY_SID);
    _sharedPreferences.remove(KEY_REMEMBER_ME);
    _sharedPreferences.remove(KEY_LOGIN_KEY);
  }

  Future<bool> getAnalyticsEnabled() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    return _sharedPreferences.getBool(KEY_ANALYTICS_ENABLED) ?? true;
  }

  Future<void> setAnalyticsEnabled(bool value) async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    return _sharedPreferences.setBool(KEY_ANALYTICS_ENABLED, value);
  }

  Future<bool> getWakelockEnabled() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    return _sharedPreferences.getBool(KEY_WAKELOCK_ENABLED) ?? true;
  }

  Future<void> setWakelockEnabled(bool value) async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    return _sharedPreferences.setBool(KEY_WAKELOCK_ENABLED, value);
  }
}
