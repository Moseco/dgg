import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static const String KEY_TWITCH_CLIENT_ID = "twitch_client_id";
  static const String KEY_YOUTUBE_API_KEY = "youtube_api_key";

  RemoteConfig? _remoteConfig;

  Future<void> _initialize() async {
    _remoteConfig = RemoteConfig.instance;
    _remoteConfig!.setDefaults(<String, dynamic>{
      KEY_TWITCH_CLIENT_ID: '',
      KEY_YOUTUBE_API_KEY: '',
    });
    await _remoteConfig!.fetchAndActivate();
  }

  Future<String> getTwitchClientId() async {
    if (_remoteConfig == null) {
      await _initialize();
    }
    return _remoteConfig!.getString(KEY_TWITCH_CLIENT_ID);
  }

  Future<String> getYouTubeApiKey() async {
    if (_remoteConfig == null) {
      await _initialize();
    }
    return _remoteConfig!.getString(KEY_YOUTUBE_API_KEY);
  }
}
