import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dgg/app/app.locator.dart';
import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/datamodels/embeds.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/datamodels/stream_status.dart';
import 'package:dgg/datamodels/user.dart';
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
  final _userMessageElementsService = locator<UserMessageElementsService>();
  final _imageService = locator<ImageService>();

  //Authentication information
  AuthInfo? _authInfo;
  SessionInfo? _sessionInfo;
  SessionInfo? get sessionInfo => _sessionInfo;
  String? _currentNick;
  bool get isSignedIn => _sessionInfo is Available;

  //Assets
  bool _assetsLoaded = false;
  bool get assetsLoaded => _assetsLoaded;
  late Flairs flairs;
  late Emotes emotes;
  bool _loadingEmote = false;
  final List<Emote> _emoteLoadQueue = [];
  bool _loadingFlair = false;
  final List<Flair> _flairLoadQueue = [];

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

  Message? parseWebSocketData(String? data, List<User> users) {
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
          users,
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
        return const StatusMessage(data: "Being disconnected by server...");
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
    String? dggCacheKey;
    final response = await http.get(Uri.https(dggBase, chatPath));

    if (response.statusCode == 200) {
      int cacheIndexStart = response.body.indexOf("data-cache-key=\"") + 16;
      int cacheIndexEnd = response.body.indexOf('"', cacheIndexStart);
      dggCacheKey = response.body.substring(cacheIndexStart, cacheIndexEnd);
    }

    late Uri flairsUri;
    late Uri emotesUri;
    late Uri emotesCssUri;

    if (dggCacheKey != null) {
      flairsUri = Uri.https(dggCdnBase, flairsPath, {"_": dggCacheKey});
      emotesUri = Uri.https(dggCdnBase, emotesPath, {"_": dggCacheKey});
      emotesCssUri = Uri.https(dggCdnBase, emotesCssPath, {"_": dggCacheKey});
    } else {
      flairsUri = Uri.https(dggCdnBase, flairsPath);
      emotesUri = Uri.https(dggCdnBase, emotesPath);
      emotesCssUri = Uri.https(dggCdnBase, emotesCssPath);
    }

    //Get assets based on url
    await getFlairs(flairsUri);
    await getEmotes(emotesUri, emotesCssUri);
    await _imageService.validateCache(dggCacheKey);
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
    if (emotes.emoteMap.isNotEmpty) {
      final response = await http.get(emotesCssUri);

      if (response.statusCode == 200) {
        _parseCss(response.body);
      }
    }
  }

  void _parseCss(String source) {
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

  Future<void> clearAssets() async {
    await closeWebSocketConnection();
    _assetsLoaded = false;
  }

  Future<void> loadEmote(Emote emote, {bool fromQueue = false}) async {
    bool loaded = false;
    // Check if emote has already been loaded before trying to load it
    if (emote.image == null) {
      // Set loading to true for current emote so additional copies are not put in the queue
      emote.loading = true;
      if (_loadingEmote) {
        // Another emote is already being loaded, add current to the queue
        _emoteLoadQueue.add(emote);
      } else {
        // Load emote
        _loadingEmote = true;
        emote.image = await _imageService.loadAndProcessEmote(emote);

        emote.loading = false;
        _loadingEmote = false;
        loaded = true;
      }
    }

    // If load request came from queue and emote is loaded, remove it
    if (fromQueue && emote.image != null) {
      _emoteLoadQueue.removeAt(0);
    }

    // If loaded emote and still have emotes in the queue, start loading the next one
    if (loaded && _emoteLoadQueue.isNotEmpty) {
      loadEmote(_emoteLoadQueue.first, fromQueue: true);
    }
  }

  Future<void> loadFlair(Flair flair) async {
    // Check if flair has already been loaded before trying to load it
    if (flair.image == null) {
      if (_loadingFlair) {
        // Another flair is already being loaded, add current to the queue
        _flairLoadQueue.add(flair);
      } else {
        // Load flair
        _loadingFlair = true;

        flair.loading = true;
        flair.image = await _imageService.loadAndProcessFlair(flair);
        // Only set loading to false if flair load worked
        //    Allows it to try again next time flair is seen
        if (flair.image != null) {
          flair.loading = false;
        }

        _loadingFlair = false;
        if (_flairLoadQueue.isNotEmpty) {
          // Remove the next flair from the queue and start loading it
          Flair nextToLoad = _flairLoadQueue[0];
          _flairLoadQueue.removeAt(0);
          loadFlair(nextToLoad);
        }
      }
    } else if (_flairLoadQueue.isNotEmpty) {
      if (flair.name == _flairLoadQueue[0].name) {
        // Current flair is already loaded and is next in the queue, remove it
        _flairLoadQueue.removeAt(0);
      }

      if (_flairLoadQueue.isNotEmpty) {
        // Remove the next flair from the queue and start loading it
        Flair nextToLoad = _flairLoadQueue[0];
        _flairLoadQueue.removeAt(0);
        loadFlair(nextToLoad);
      }
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
      );
    } else {
      return const StreamStatus(twitchLive: false, youtubeLive: false);
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
