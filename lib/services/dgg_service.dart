import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dgg/app/app.locator.dart';
import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/datamodels/embeds.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/datamodels/stream_status.dart';
import 'package:dgg/services/shared_preferences_service.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class DggService {
  // Base urls
  static const String dggBase = r"destiny.gg";
  static const String dggCdnBase = r"cdn.destiny.gg";
  static const String vyneerBase = r"vyneer.me";
  // Url endpoints
  static const String sessionInfoPath = r"/api/chat/me";
  static const String userInfoPath = r"/api/userinfo";
  static const String chatPath = r"/embed/chat";
  static const String flairsPath = r"/flairs/flairs.json";
  static const String emotesPath = r"/emotes/emotes.json";
  static const String emotesCssPath = r"/emotes/emotes.css";
  static const String historyPath = r"/api/chat/history";
  static const String streamStatusPath = r"/api/info/stream";
  static const String embedsPath = r"/tools/embeds";

  // Dgg websocket url
  static const String webSocketUrl = r"wss://chat.destiny.gg/ws";

  final _sharedPreferencesService = locator<SharedPreferencesService>();

  //Authentication information
  AuthInfo? _authInfo;
  SessionInfo? _sessionInfo;
  SessionInfo? get sessionInfo => _sessionInfo;
  String? _currentNick;
  String? get currentNick => _currentNick;
  bool get isSignedIn => _sessionInfo is Available;

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

    Map<String, dynamic> json = jsonDecode(response.body);
    if (response.statusCode == 200) {
      // We can get status code 200 but still have an error, confirm first
      if (json.containsKey("code") && json["code"] != 200) {
        _sessionInfo = Unavailable(
          httpStatusCode: json["code"],
          usedToken: _authInfo!.loginKey != null,
        );
      } else if (json.containsKey("error")) {
        _sessionInfo = Unavailable(usedToken: _authInfo!.loginKey != null);
      } else {
        // Token or sid is valid
        _sessionInfo = Available.fromJson(response.body);
        _currentNick = (_sessionInfo as Available).nick;
      }
    } else {
      _sessionInfo = Unavailable(
        httpStatusCode: json["code"],
        usedToken: _authInfo!.loginKey != null,
      );
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

  Future<String?> fetchDggCacheKey() async {
    final response = await http.get(Uri.https(dggBase, chatPath));

    if (response.statusCode == 200) {
      int cacheIndexStart = response.body.indexOf("data-cache-key=\"") + 16;
      if (cacheIndexStart == -1) {
        return null;
      }

      int cacheIndexEnd = response.body.indexOf('"', cacheIndexStart);
      if (cacheIndexEnd == -1) {
        return null;
      }

      return response.body.substring(cacheIndexStart, cacheIndexEnd);
    }

    return null;
  }

  Future<Flairs> fetchFlairs(String? cacheKey) async {
    late Uri flairsUri;

    if (cacheKey != null) {
      flairsUri = Uri.https(dggCdnBase, flairsPath, {"_": cacheKey});
    } else {
      flairsUri = Uri.https(dggCdnBase, flairsPath);
    }

    final response = await http.get(flairsUri);

    if (response.statusCode == 200) {
      return Flairs.fromJson(response.body);
    } else {
      return Flairs.empty();
    }
  }

  Future<Emotes> fetchEmotes(String? cacheKey) async {
    late Uri emotesUri;
    late Uri emotesCssUri;

    if (cacheKey != null) {
      emotesUri = Uri.https(dggCdnBase, emotesPath, {"_": cacheKey});
      emotesCssUri = Uri.https(dggCdnBase, emotesCssPath, {"_": cacheKey});
    } else {
      emotesUri = Uri.https(dggCdnBase, emotesPath);
      emotesCssUri = Uri.https(dggCdnBase, emotesCssPath);
    }

    final response = await http.get(emotesUri);

    if (response.statusCode == 200) {
      Emotes emotes = Emotes.fromJson(response.body);

      await _fetchEmoteCss(emotesCssUri, emotes);

      return emotes;
    } else {
      return Emotes.empty();
    }
  }

  Future<void> _fetchEmoteCss(Uri emotesCssUri, Emotes emotes) async {
    if (emotes.emoteMap.isNotEmpty) {
      final response = await http.get(emotesCssUri);

      if (response.statusCode == 200) {
        _parseCss(response.body, emotes);
      }
    }
  }

  void _parseCss(String source, Emotes emotes) {
    //Split css file by lines
    List<String> lines = const LineSplitter().convert(source);

    //Regex to match the following: .emote.EMOTE {
    RegExp emoteStart = RegExp(r'\.emote\.\w+ ?\{');

    for (int i = 0; i < lines.length; i++) {
      //Check if starts with emote
      String trimmed = lines[i].trim();
      if (trimmed.startsWith(emoteStart)) {
        //get emote name
        String emoteName = trimmed.substring(7, trimmed.indexOf('{')).trim();
        //go through attributes
        String currentLineTrimmed = trimmed;
        while (!currentLineTrimmed.endsWith("}")) {
          //Check if body has animation attribute
          if (currentLineTrimmed.startsWith("animation:")) {
            // If defined on multiple lines merge into one
            if (!currentLineTrimmed.endsWith(';')) {
              currentLineTrimmed = '$currentLineTrimmed ${lines[++i].trim()}';
            }
            if (currentLineTrimmed.contains("steps(")) {
              //If animation has steps, parse the duration and number of repeats
              _parseEmoteSteps(
                emotes.emoteMap[emoteName]!,
                currentLineTrimmed,
              );
            }
          } else if (currentLineTrimmed.startsWith("width:")) {
            // If defined on multiple lines merge into one
            if (!currentLineTrimmed.endsWith(';')) {
              currentLineTrimmed = '$currentLineTrimmed ${lines[++i].trim()}';
            }
            //Get width
            int startIndex = currentLineTrimmed.indexOf(":");
            int endIndex = currentLineTrimmed.indexOf("px");
            int width = int.parse(
                currentLineTrimmed.substring(startIndex + 1, endIndex).trim());

            //Keep lowest width found
            //  If we find a lower width, then it needs cutting and is probably step animated
            if (emotes.emoteMap[emoteName]!.width > width) {
              emotes.emoteMap[emoteName]!.width = width;
              emotes.emoteMap[emoteName]!.needsCutting = true;
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

    // Remove the last character which will be ';'
    //    Makes things easier later
    List<String> words = line.substring(0, line.length - 1).split(' ');
    for (int i = 0; i < words.length; i++) {
      if (words[i].startsWith("steps(")) {
        // Found steps
        // Check before: i-1
        _stepParam1 = _parseStepParam(words[i - 1]);
        if (_stepParam1 == null && words.length > i + 2) {
          // All params come after, do i+2 here
          _stepParam1 = _parseStepParam(words[i + 2]);
        }

        // Make sure there is an after, if there is check it: i+1
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

    // Some emotes have duration in a different line, force 1 second in this case
    emote.duration ??= 1000;

    // Set animated to true if repeatCount also found correctly
    if (emote.repeatCount != null) {
      emote.animated = true;
    }
  }

  _StepParam? _parseStepParam(String param) {
    try {
      RegExpMatch? match = numberRegex.firstMatch(param);
      if (param.endsWith("ms") || param.endsWith("ms,")) {
        //Duration in milliseconds
        return _StepParam(
          double.parse(param.substring(0, match!.end)).toInt(),
          _StepParamType.duration,
        );
      } else if (param.endsWith("s") || param.endsWith("s,")) {
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
    } catch (_) {
      // Most likely encountered a double or int parse error
      return null;
    }
  }

  void sendChatMessage(String message) {
    try {
      String dataString = jsonEncode({"data": message});
      _webSocketChannel?.sink.add('MSG $dataString');
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

  Future<List<dynamic>> getChatHistory() async {
    final response = await http.get(Uri.https(dggBase, historyPath));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return [];
    }
  }

  Future<List<Embed>> getEmbeds() async {
    final response = await http.get(Uri.https(
      vyneerBase,
      embedsPath,
      {"t": "30"},
    ));

    if (response.statusCode == 200) {
      return Embeds.fromJson(response.body).embedList;
    } else {
      return const [];
    }
  }

  Future<StreamStatus> getStreamStatus() async {
    final response = await http.get(Uri.https(dggBase, streamStatusPath));

    if (response.statusCode == 200) {
      Map<String, dynamic> json = jsonDecode(response.body);

      return StreamStatus(
        twitchLive: json["data"]?["streams"]?["twitch"]?["live"] ?? false,
        youtubeLive: json["data"]?["streams"]?["youtube"]?["live"] ?? false,
        youtubeId: json["data"]?["streams"]?["youtube"]?["id"],
        rumbleLive: json["data"]?["streams"]?["rumble"]?["live"] ?? false,
        rumbleId: json["data"]?["streams"]?["rumble"]?["id"],
        kickLive: json["data"]?["streams"]?["kick"]?["live"] ?? false,
        kickId: json["data"]?["streams"]?["kick"]?["id"],
      );
    } else {
      return const StreamStatus(
        twitchLive: false,
        youtubeLive: false,
        rumbleLive: false,
        kickLive: false,
      );
    }
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
