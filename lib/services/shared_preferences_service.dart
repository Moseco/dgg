import 'package:dgg/datamodels/auth_info.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

@lazySingleton
class SharedPreferencesService {
  static const KEY_SID = "KEY_SID";
  static const KEY_REMEMBER_ME = "KEY_REMEMBER_ME";

  SharedPreferences _sharedPreferences;

  Future<AuthInfo> getAuthInfo() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    String sid = _sharedPreferences.getString(KEY_SID);
    String rememberMe = _sharedPreferences.getString(KEY_REMEMBER_ME);

    if (sid == null) {
      return null;
    } else {
      return AuthInfo(
        sid,
        rememberMe,
      );
    }
  }

  Future<void> storeAuthInfo(AuthInfo authInfo) async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    _sharedPreferences.setString(KEY_SID, authInfo.sid);
    _sharedPreferences.setString(KEY_REMEMBER_ME, authInfo.rememberMe);
  }

  Future<void> clearAuthInfo() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }

    _sharedPreferences.remove(KEY_SID);
    _sharedPreferences.remove(KEY_REMEMBER_ME);
  }
}
