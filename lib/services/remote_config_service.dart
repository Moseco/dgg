import 'package:firebase_remote_config/firebase_remote_config.dart';

class RemoteConfigService {
  static const String KEY_TWITCH_CLIENT_ID = "twitch_client_id";
  static const String KEY_YOUTUBE_API_KEY = "youtube_api_key";

  late RemoteConfig _remoteConfig;

  Future<void> initialize() async {
    _remoteConfig = RemoteConfig.instance;
    _remoteConfig.setDefaults(<String, dynamic>{
      KEY_TWITCH_CLIENT_ID: '',
      KEY_YOUTUBE_API_KEY: '',
    });
    await _remoteConfig.fetchAndActivate();
  }

  String getTwitchClientId() {
    return _remoteConfig.getString(KEY_TWITCH_CLIENT_ID);
  }

  String getYouTubeApiKey() {
    return _remoteConfig.getString(KEY_YOUTUBE_API_KEY);
  }
}
