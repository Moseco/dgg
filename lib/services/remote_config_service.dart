import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class RemoteConfigService {
  static const String KEY_APP_NEWEST_VERSION = "app_newest_version";
  static const String KEY_APP_DOWNLOAD_URL = "app_download_url";

  RemoteConfig _remoteConfig;

  Future<void> _initialize() async {
    _remoteConfig = await RemoteConfig.instance;
    _remoteConfig.setDefaults(<String, dynamic>{
      KEY_APP_NEWEST_VERSION: '0.1',
      KEY_APP_DOWNLOAD_URL: 'http://www.example.com',
    });
    try {
      await _remoteConfig.fetch(expiration: const Duration(days: 7));
      await _remoteConfig.activateFetched();
    } catch (_) {
      //Throttle or fetch error occured
      //Default values should be used
    }
  }

  Future<String> getAppNewestVersion() async {
    if (_remoteConfig == null) {
      await _initialize();
    }
    return _remoteConfig.getString(KEY_APP_NEWEST_VERSION);
  }

  Future<String> getAppDownloadUrl() async {
    if (_remoteConfig == null) {
      await _initialize();
    }
    return _remoteConfig.getString(KEY_APP_DOWNLOAD_URL);
  }
}