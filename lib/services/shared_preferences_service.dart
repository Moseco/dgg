import 'package:dgg/datamodels/auth_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static const String KEY_SID = "KEY_SID";
  static const String KEY_REMEMBER_ME = "KEY_REMEMBER_ME";
  static const String KEY_LOGIN_KEY = "KEY_LOGIN_KEY";
  static const String KEY_ANALYTICS_ENABLED = "KEY_ANALYTICS_ENABLED";
  static const String KEY_WAKELOCK_ENABLED = "KEY_WAKELOCK_ENABLED";
  static const String KEY_ONBOARDING = "KEY_ONBOARDING";
  static const String KEY_APP_BAR_THEME = "KEY_APP_BAR_THEME";
  static const String KEY_DEFAULT_STREAM = "KEY_DEFAULT_STREAM";
  static const String KEY_CHANGELOG = "KEY_CHANGELOG";
  static const String KEY_CHAT_TEXT_SIZE = "KEY_CHAT_TEXT_SIZE";
  static const String KEY_CHAT_EMOTE_SIZE = "KEY_CHAT_EMOTE_SIZE";
  static const String KEY_CACHE_VERSION = "KEY_CACHE_VERSION";
  static const String KEY_CHAT_FLAIR_ENABLED = "KEY_CHAT_FLAIR_ENABLED";
  static const String KEY_CHAT_FLAIR_SIZE = "KEY_CHAT_FLAIR_SIZE";
  static const String KEY_IN_APP_BROWSER_ENABLED = "KEY_IN_APP_BROWSER_ENABLED";
  static const String KEY_CHAT_TIMESTAMP_ENABLED = "KEY_CHAT_TIMESTAMP_ENABLED";
  static const String KEY_IGNORE_LIST = "KEY_IGNORE_LIST";

  SharedPreferences? _sharedPreferences;

  Future<void> initialize() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
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
      await _sharedPreferences!
          .setString(KEY_REMEMBER_ME, authInfo.rememberMe!);
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

  int getAppBarTheme() {
    return _sharedPreferences!.getInt(KEY_APP_BAR_THEME) ?? 0;
  }

  Future<void> setAppBarTheme(int value) async {
    await _sharedPreferences!.setInt(KEY_APP_BAR_THEME, value);
  }

  int getDefaultStream() {
    return _sharedPreferences!.getInt(KEY_DEFAULT_STREAM) ?? 1;
  }

  Future<void> setDefaultStream(int value) async {
    await _sharedPreferences!.setInt(KEY_DEFAULT_STREAM, value);
  }

  Future<bool> shouldShowChangelog() async {
    int value = _sharedPreferences!.getInt(KEY_CHANGELOG) ?? 0;
    if (value != 23) {
      await _sharedPreferences!.setInt(KEY_CHANGELOG, 23);
      return true;
    } else {
      return false;
    }
  }

  int getChatTextSize() {
    return _sharedPreferences!.getInt(KEY_CHAT_TEXT_SIZE) ?? 1;
  }

  Future<void> setChatTextSize(int value) async {
    await _sharedPreferences!.setInt(KEY_CHAT_TEXT_SIZE, value);
  }

  int getChatEmoteSize() {
    return _sharedPreferences!.getInt(KEY_CHAT_EMOTE_SIZE) ?? 1;
  }

  Future<void> setChatEmoteSize(int value) async {
    await _sharedPreferences!.setInt(KEY_CHAT_EMOTE_SIZE, value);
  }

  String? getCacheVersion() {
    return _sharedPreferences!.getString(KEY_CACHE_VERSION);
  }

  Future<void> setCacheVersion(String value) async {
    await _sharedPreferences!.setString(KEY_CACHE_VERSION, value);
  }

  bool getFlairEnabled() {
    return _sharedPreferences!.getBool(KEY_CHAT_FLAIR_ENABLED) ?? true;
  }

  Future<void> setFlairEnabled(bool value) async {
    await _sharedPreferences!.setBool(KEY_CHAT_FLAIR_ENABLED, value);
  }

  int getChatFlairSize() {
    return _sharedPreferences!.getInt(KEY_CHAT_FLAIR_SIZE) ?? 1;
  }

  Future<void> setChatFlairSize(int value) async {
    await _sharedPreferences!.setInt(KEY_CHAT_FLAIR_SIZE, value);
  }

  bool getInAppBrowserEnabled() {
    return _sharedPreferences!.getBool(KEY_IN_APP_BROWSER_ENABLED) ?? true;
  }

  Future<void> setInAppBrowserEnabled(bool value) async {
    await _sharedPreferences!.setBool(KEY_IN_APP_BROWSER_ENABLED, value);
  }

  bool getTimestampEnabled() {
    return _sharedPreferences!.getBool(KEY_CHAT_TIMESTAMP_ENABLED) ?? false;
  }

  Future<void> setTimestampEnabled(bool value) async {
    await _sharedPreferences!.setBool(KEY_CHAT_TIMESTAMP_ENABLED, value);
  }

  List<String> getIgnoreList() {
    return _sharedPreferences!.getStringList(KEY_IGNORE_LIST) ?? [];
  }

  Future<void> setIgnoreList(List<String> ignoreList) async {
    await _sharedPreferences!.setStringList(KEY_IGNORE_LIST, ignoreList);
  }

  int getThemeIndex() {
    //This will potentially break in the future
    //The key is taken from stacked_themes source code
    return _sharedPreferences!.getInt("user_key") ?? 0;
  }
}
