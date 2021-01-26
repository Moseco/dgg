import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/image_service.dart';
import 'package:dgg/services/user_message_elements_service.dart';
import 'package:injectable/injectable.dart';
import 'package:dgg/app/locator.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

@lazySingleton
class DggService {
  static const String sessionInfoUrl = "https://www.destiny.gg/api/chat/me";
  static const String userInfoUrl = "https://www.destiny.gg/api/userinfo";
  static const String webSocketUrl = "wss://chat.destiny.gg/ws";
  static const String chatUrl = "https://www.destiny.gg/embed/chat";
  static const String cdnBaseUrl = "https://cdn.destiny.gg";
  static const String flairsPath = "/flairs/flairs.json";
  static const String emotesPath = "/emotes/emotes.json";
  static const String emotesCssPath = "/emotes/emotes.css";

  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _userMessageElementsService = locator<UserMessageElementsService>();
  final _imageService = locator<ImageService>();

  //Authentication information
  AuthInfo _authInfo;
  SessionInfo _sessionInfo;
  SessionInfo get sessionInfo => _sessionInfo;
  String _currentNick;
  bool get isSignedIn => _sessionInfo is Available;

  //Assets
  String _dggCacheKey;
  bool get isAssetsLoaded => flairs != null && emotes != null;
  Flairs flairs;
  Emotes emotes;

  //Dgg chat websocket
  WebSocketChannel _webSocketChannel;

  Future<void> getSessionInfo() async {
    _sessionInfo = null;
    _authInfo = await _sharedPreferencesService.getAuthInfo();

    if (_authInfo == null) {
      _sessionInfo = Unauthenticated();
      return;
    }

    String urlToUse;
    if (_authInfo.loginKey != null) {
      urlToUse = "$userInfoUrl?token=${_authInfo.loginKey}";
    } else {
      urlToUse = sessionInfoUrl;
    }

    final response = await http.get(
      urlToUse,
      headers: _authInfo.sid != null
          ? {HttpHeaders.cookieHeader: _authInfo.toHeaderString()}
          : null,
    );

    if (response.statusCode == 200) {
      if (response.body.startsWith('{"error"')) {
        //Token is not valid, or some other error
        _sessionInfo = Unavailable();
      } else {
        //token or sid is valid
        _sessionInfo = Available.fromJson(response.body);
        _currentNick = (_sessionInfo as Available).nick;
      }
    } else {
      _sessionInfo = Unavailable(httpStatusCode: response.statusCode);
    }
  }

  WebSocketChannel openWebSocketConnection() {
    _webSocketChannel = IOWebSocketChannel.connect(
      webSocketUrl,
      headers: _sessionInfo is Available
          ? {HttpHeaders.cookieHeader: _authInfo.toHeaderString()}
          : null,
    );

    return _webSocketChannel;
  }

  Future<void> closeWebSocketConnection() async {
    await _webSocketChannel?.sink?.close(status.goingAway);
    _webSocketChannel = null;
  }

  Message parseWebSocketData(String data) {
    String dataString = data.toString();
    int spaceIndex = dataString.indexOf(' ');
    String key = dataString.substring(0, spaceIndex);
    String jsonString = dataString.substring(spaceIndex + 1);

    switch (key) {
      case "NAMES":
        return NamesMessage.fromJson(jsonString);
      case "MSG":
        return UserMessage.fromJson(
          jsonString,
          flairs,
          emotes,
          _userMessageElementsService.createMessageElements,
          currentNick: _currentNick,
        );
      case "JOIN":
        return JoinMessage.fromJson(jsonString);
      case "QUIT":
        return QuitMessage.fromJson(jsonString);
      case "BROADCAST":
        return BroadcastMessage.fromJson(jsonString);
      case "MUTE":
        return MuteMessage.fromJson(jsonString);
      case "UNMUTE":
        return UnmuteMessage.fromJson(jsonString);
      case "BAN":
        return BanMessage.fromJson(jsonString);
      case "UNBAN":
        return UnbanMessage.fromJson(jsonString);
      case "REFRESH":
        return StatusMessage(data: "Being disconnected by server...");
      case "SUBONLY":
        return SubOnlyMessage.fromJson(jsonString);
      case "ERR":
        return ErrorMessage.fromJson(jsonString);
      // // Other possible types
      // case "PING":
      //   break;
      // case "PONG":
      //   break;
      // case "PRIVMSG":
      //   break;
      default:
        print(data);
        return null;
    }
  }

  Future<void> getAssets() async {
    //First get cache key
    if (_dggCacheKey == null) {
      final response = await http.get(chatUrl);

      if (response.statusCode == 200) {
        int cacheIndexStart = response.body.indexOf("data-cache-key=\"") + 16;
        int cacheIndexEnd = response.body.indexOf('\"', cacheIndexStart);
        _dggCacheKey = response.body.substring(cacheIndexStart, cacheIndexEnd);
      }
    }

    String flairsUrl = cdnBaseUrl + flairsPath;
    String emotesUrl = cdnBaseUrl + emotesPath;
    String emotesCssUrl = cdnBaseUrl + emotesCssPath;

    if (_dggCacheKey != null) {
      flairsUrl = flairsUrl + "?_=" + _dggCacheKey;
      emotesUrl = emotesUrl + "?_=" + _dggCacheKey;
      emotesCssUrl = emotesCssUrl + "?_=" + _dggCacheKey;
    }

    //Get assets based on url
    await getFlairs(flairsUrl);
    await getEmotes(emotesUrl, emotesCssUrl);
  }

  Future<void> getFlairs(String flairsUrl) async {
    if (flairs == null) {
      final response = await http.get(flairsUrl);

      if (response.statusCode == 200) {
        flairs = Flairs.fromJson(response.body);
      } else {
        flairs = Flairs([]);
      }
    }
  }

  Future<void> getEmotes(String emotesUrl, String emotesCssUrl) async {
    if (emotes == null) {
      final response = await http.get(emotesUrl);

      if (response.statusCode == 200) {
        Emotes emoteList = Emotes.fromJson(response.body);
        await _getEmoteCss(emotesCssUrl, emoteList);
      } else {
        emotes = Emotes();
      }
    }
  }

  Future<void> _getEmoteCss(String emotesCssUrl, Emotes emoteList) async {
    final response = await http.get(emotesCssUrl);

    if (response.statusCode == 200) {
      parseCss(response.body, emoteList);
      emotes = emoteList;
    } else {
      emotes = emoteList;
    }
  }

  void parseCss(String source, Emotes emoteList) {
    //Split css file by lines
    List<String> lines = LineSplitter().convert(source);

    //Regex to match the following: .emote.EMOTE {
    RegExp emoteStart = RegExp(r'\.emote\.\w+ ?\{');

    for (int i = 0; i < lines.length; i++) {
      //Check if starts with emote
      if (lines[i].startsWith(emoteStart)) {
        //get emote name
        String trimmed = lines[i].trim();
        String emoteName = trimmed.substring(7, trimmed.indexOf('{')).trim();
        //go through attributes
        String currentLineTrimmed = lines[++i].trim();
        while (!currentLineTrimmed.startsWith("}")) {
          // //Check if body has animation attribute
          if (currentLineTrimmed.startsWith("animation:")) {
            emoteList.emoteMap[emoteName].animated = true;
          } else if (currentLineTrimmed.startsWith("width:")) {
            //Get width
            int startIndex = currentLineTrimmed.indexOf(":");
            int endIndex = currentLineTrimmed.indexOf("px");
            int width = int.parse(
                currentLineTrimmed.substring(startIndex + 1, endIndex).trim());

            //Check if width is already found
            //  If it has, keep the lower value
            //  Otherwise, just store it
            if ((emoteList.emoteMap[emoteName].width ?? 99999) > width) {
              emoteList.emoteMap[emoteName].width = width;
            }
          }
          currentLineTrimmed = lines[++i].trim();
        }
      }
    }
  }

  Future<void> clearAssets() async {
    await closeWebSocketConnection();
    flairs = null;
    emotes = null;
  }

  Future<void> loadEmote(Emote emote) async {
    //TODO do some kind of caching
    emote.loading = true;
    emote.image = await _imageService.downloadAndProcessEmote(emote);
    emote.loading = false;
  }

  void sendChatMessage(String message) {
    try {
      _webSocketChannel.sink.add('MSG {"data": "$message"}');
    } catch (_) {
      print("Message failed to send");
    }
  }

  bool hasVotePermission(List<String> features) {
    for (int i = 0; i < features.length; i++) {
      if (features[i] == 'admin' ||
          features[i] == 'bot' ||
          features[i] == 'moderator') {
        return true;
      }
    }
    return false;
  }

  void signOut() {
    _authInfo = null;
    _sessionInfo = Unauthenticated();
    _currentNick = null;
    _sharedPreferencesService.clearAuthInfo();
  }
}
