import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static const String KEY_TWITCH_CLIENT_ID = "twitch_client_id";

  RemoteConfig? _remoteConfig;

  Future<void> _initialize() async {
    _remoteConfig = RemoteConfig.instance;
    _remoteConfig!.setDefaults(<String, dynamic>{
      KEY_TWITCH_CLIENT_ID: 'th7yn70vi8cmio3j0qs2df17oxmors',
    });
    await _remoteConfig!.fetchAndActivate();
  }

  Future<String> getTwitchClientId() async {
    if (_remoteConfig == null) {
      await _initialize();
    }
    return _remoteConfig!.getString(KEY_TWITCH_CLIENT_ID);
  }
}
