import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dgg/app/app.locator.dart';
import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/services/image_service.dart';
import 'package:dgg/services/user_message_elements_service.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class DggService {
  // Base urls
  static const String dggBase = r"destiny.gg";
  static const String dggCdnBase = r"cdn.destiny.gg";
  // Url endpoints
  static const String sessionInfoPath = r"/api/chat/me";
  static const String userInfoPath = r"/api/userinfo";
  static const String chatPath = r"/embed/chat";
  static const String flairsPath = r"/flairs/flairs.json";
  static const String emotesPath = r"/emotes/emotes.json";
  static const String emotesCssPath = r"/emotes/emotes.css";

  // Dgg websocket url
  static const String webSocketUrl = r"wss://chat.destiny.gg/ws";

  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _userMessageElementsService = locator<UserMessageElementsService>();
  final _imageService = locator<ImageService>();

  //Authentication information
  AuthInfo? _authInfo;
  SessionInfo? _sessionInfo;
  SessionInfo? get sessionInfo => _sessionInfo;
  String? _currentNick;
  bool get isSignedIn => _sessionInfo is Available;

  //Assets
  String? _dggCacheKey;
  bool _assetsLoaded = false;
  bool get assetsLoaded => _assetsLoaded;
  late Flairs flairs;
  late Emotes emotes;

  //Dgg chat websocket
  WebSocketChannel? _webSocketChannel;

  //RegEx
  final RegExp numberRegex = RegExp(r"\d*\.?\d*");

  Future<void> getSessionInfo() async {
    _sessionInfo = null;
    _authInfo = _sharedPreferencesService.getAuthInfo();

    if (_authInfo == null) {
      _sessionInfo = Unauthenticated();
      return;
    }

    Uri uri;
    if (_authInfo!.loginKey != null) {
      uri = Uri.https(dggBase, userInfoPath, {
        "token": _authInfo!.loginKey,
      });
    } else {
      uri = Uri.https(dggBase, sessionInfoPath);
    }

    final response = await http.get(
      uri,
      headers: _authInfo!.sid != null
          ? {HttpHeaders.cookieHeader: _authInfo!.toHeaderString()}
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
          ? {HttpHeaders.cookieHeader: _authInfo!.toHeaderString()}
          : null,
    );

    return _webSocketChannel!;
  }

  Future<void> closeWebSocketConnection() async {
    await _webSocketChannel?.sink.close(status.goingAway);
    _webSocketChannel = null;
  }

  Message? parseWebSocketData(String? data) {
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
    final response = await http.get(Uri.https(dggBase, chatPath));

    if (response.statusCode == 200) {
      int cacheIndexStart = response.body.indexOf("data-cache-key=\"") + 16;
      int cacheIndexEnd = response.body.indexOf('\"', cacheIndexStart);
      _dggCacheKey = response.body.substring(cacheIndexStart, cacheIndexEnd);
    }

    Uri flairsUri = Uri.https(dggCdnBase, flairsPath);
    Uri emotesUri = Uri.https(dggCdnBase, emotesPath);
    Uri emotesCssUri = Uri.https(dggCdnBase, emotesCssPath);

    if (_dggCacheKey != null) {
      flairsUri.replace(queryParameters: {"_": _dggCacheKey});
      emotesUri.replace(queryParameters: {"_": _dggCacheKey});
      emotesCssUri.replace(queryParameters: {"_": _dggCacheKey});
    }

    //Get assets based on url
    await getFlairs(flairsUri);
    await getEmotes(emotesUri, emotesCssUri);
    _assetsLoaded = true;
  }

  Future<void> getFlairs(Uri flairsUri) async {
    final response = await http.get(flairsUri);

    if (response.statusCode == 200) {
      flairs = Flairs.fromJson(response.body);
    } else {
      flairs = Flairs.empty();
    }
  }

  Future<void> getEmotes(Uri emotesUri, Uri emotesCssUri) async {
    final response = await http.get(emotesUri);

    if (response.statusCode == 200) {
      emotes = Emotes.fromJson(response.body);

      await _getEmoteCss(emotesCssUri);
    } else {
      emotes = Emotes.empty();
    }
  }

  Future<void> _getEmoteCss(Uri emotesCssUri) async {
    if (emotes.emoteMap.length > 0) {
      final response = await http.get(emotesCssUri);

      if (response.statusCode == 200) {
        _parseCss(response.body);
      }
    }
  }

  void _parseCss(String source) {
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
            if (currentLineTrimmed.contains("steps(")) {
              //If animation has steps, parse the duration and number of repeats
              _parseEmoteSteps(
                emotes.emoteMap[emoteName]!,
                currentLineTrimmed,
              );
            }
          } else if (currentLineTrimmed.startsWith("width:")) {
            //Get width
            int startIndex = currentLineTrimmed.indexOf(":");
            int endIndex = currentLineTrimmed.indexOf("px");
            int width = int.parse(
                currentLineTrimmed.substring(startIndex + 1, endIndex).trim());

            //Keep lowest width found
            //  If we find a lower width, then it is step animated
            if (emotes.emoteMap[emoteName]!.width > width) {
              emotes.emoteMap[emoteName]!.width = width;
              emotes.emoteMap[emoteName]!.animated = true;
            }
          }
          currentLineTrimmed = lines[++i].trim();
        }
      }
    }
  }

  void _parseEmoteSteps(Emote emote, String line) {
    _StepParam? _stepParam1;
    _StepParam? _stepParam2;

    //Remove the last character which will be ';'
    //  Makes things easier later
    List<String> words = line.substring(0, line.length - 1).split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].startsWith("steps(")) {
        //Found steps
        //Check before: i-1
        _stepParam1 = _parseStepParam(words[i - 1]);
        if (_stepParam1 == null && words.length > i + 2) {
          //All params come after, do i+2 here
          _stepParam1 = _parseStepParam(words[i + 2]);
        }

        //Make sure there is an after, if there is check it: i+1
        if (words.length > i + 1) {
          _stepParam2 = _parseStepParam(words[i + 1]);
        }
        break;
      }
    }

    emote.duration = _stepParam1?.type == _StepParamType.duration
        ? _stepParam1?.value
        : _stepParam2?.value;
    emote.repeatCount = _stepParam1?.type == _StepParamType.repeatCount
        ? _stepParam1?.value
        : _stepParam2?.value;

    //Some emotes have duration in a different line, force 1 second in this case
    if (emote.duration == null) {
      emote.duration = 1000;
    }
  }

  _StepParam? _parseStepParam(String param) {
    RegExpMatch? match = numberRegex.firstMatch(param);
    if (param.endsWith("ms")) {
      //Duration in milliseconds
      return _StepParam(
        double.parse(param.substring(0, match!.end)).toInt(),
        _StepParamType.duration,
      );
    } else if (param.endsWith("s")) {
      //Duration in seconds
      return _StepParam(
        (double.parse(param.substring(0, match!.end)) * 1000).toInt(),
        _StepParamType.duration,
      );
    } else {
      if (match!.end != 0) {
        //Number of repeats
        return _StepParam(
          int.parse(param.substring(0, match.end)),
          _StepParamType.repeatCount,
        );
      } else {
        //Some other parameter we do not care about
        return null;
      }
    }
  }

  Future<void> clearAssets() async {
    await closeWebSocketConnection();
    _assetsLoaded = false;
  }

  Future<void> loadEmote(Emote emote) async {
    //TODO do some kind of caching
    emote.loading = true;
    emote.image = await _imageService.downloadAndProcessEmote(emote);
    emote.loading = false;
  }

  void sendChatMessage(String message) {
    try {
      _webSocketChannel?.sink.add('MSG {"data": "$message"}');
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

class _StepParam {
  final int value;
  final _StepParamType type;

  const _StepParam(
    this.value,
    this.type,
  );
}

enum _StepParamType {
  duration,
  repeatCount,
}
