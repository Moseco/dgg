import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:dgg/datamodels/user_message_element.dart';
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
class DggApi {
  static const String sessionInfoUrl = "https://www.destiny.gg/api/chat/me";
  static const String webSocketUrl = "wss://www.destiny.gg/ws";
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

  //Assets
  String _dggCacheKey;
  bool get isAssetsLoaded => flairs != null && emotes != null;
  Flairs flairs;
  Emotes emotes;

  //For chat messages
  WebSocketChannel _channel;
  StreamSubscription _chatSubscription;

  List<Message> _messages = List();
  List<Message> get messages => _messages;
  List<User> _users = List();
  List<User> get users => _users;
  bool _isChatConnected = false;
  bool get isChatConnected => _isChatConnected;

  Future<void> getSessionInfo() async {
    _sessionInfo = null;
    _authInfo = await _sharedPreferencesService.getAuthInfo();

    if (_authInfo == null) {
      _sessionInfo = Unavailable();
      return;
    }

    final response = await http.get(
      sessionInfoUrl,
      headers: _authInfo != null
          ? {HttpHeaders.cookieHeader: _authInfo.toHeaderString()}
          : null,
    );

    if (response.statusCode == 200) {
      _sessionInfo = Available.fromJson(response.body);
      _currentNick = (_sessionInfo as Available).nick;
    } else {
      _sessionInfo = Unavailable(httpStatusCode: response.statusCode);
    }
  }

  void openWebSocketConnection(Function notifyCallback) {
    _messages.add(StatusMessage(data: "Connecting..."));
    notifyCallback();
    _channel = IOWebSocketChannel.connect(
      webSocketUrl,
      headers: _authInfo != null
          ? {HttpHeaders.cookieHeader: _authInfo.toHeaderString()}
          : null,
    );
    _chatSubscription = _channel.stream.listen(
      (data) {
        String dataString = data.toString();
        int spaceIndex = dataString.indexOf(' ');
        String key = dataString.substring(0, spaceIndex);
        String jsonString = dataString.substring(spaceIndex + 1);

        switch (key) {
          case "NAMES":
            _isChatConnected = true;
            _users = NamesMessage.fromJson(jsonString).users;
            _messages.add(
                StatusMessage(data: "Connected with ${_users.length} users"));
            break;
          case "MSG":
            UserMessage userMessage = UserMessage.fromJson(
              jsonString,
              flairs,
              emotes,
              _userMessageElementsService.createMessageElements,
              currentNick: _currentNick,
            );
            //for each emote, check if needs to be loaded
            userMessage.elements.forEach((element) {
              if (element is EmoteElement) {
                if (!element.emote.loading && element.emote.image == null) {
                  _loadEmote(element.emote, notifyCallback);
                }
              }
            });
            //Check if new message is part of a combo
            if (userMessage.elements.length == 1 &&
                userMessage.elements[0] is EmoteElement) {
              //Current message only has one emote in it
              EmoteElement currentEmote = userMessage.elements[0];
              Message recentMessage = _messages[_messages.length - 1];
              if (recentMessage is ComboMessage) {
                //Most recent is combo
                if (recentMessage.emote.name == currentEmote.emote.name) {
                  //Same emote, increment combo
                  _messages[_messages.length - 1] =
                      recentMessage.incrementCombo();
                  break;
                }
              } else {
                //Most recent is not combo
                if (recentMessage is UserMessage &&
                    recentMessage.elements.length == 1 &&
                    recentMessage.elements[0] is EmoteElement &&
                    (recentMessage.elements[0] as EmoteElement).emote.name ==
                        currentEmote.emote.name) {
                  //Most recent is UserMessage and only has the same emote
                  //  Replace recent message with combo
                  _messages[_messages.length - 1] =
                      ComboMessage(emote: currentEmote.emote);
                  break;
                }
              }
            }
            //Add message normally
            _messages.add(userMessage);
            break;
          case "JOIN":
            _users.add(JoinMessage.fromJson(jsonString).user);
            break;
          case "QUIT":
            _users.remove(QuitMessage.fromJson(jsonString).user);
            break;
          case "BROADCAST":
            BroadcastMessage broadcastMessage =
                BroadcastMessage.fromJson(jsonString);
            _messages.add(broadcastMessage);
            break;
          case "MUTE":
            MuteMessage muteMessage = MuteMessage.fromJson(jsonString);
            //Go through up to previous 10 messages and censor messages from muted user
            int lengthToCheck = _messages.length >= 11 ? 11 : _messages.length;
            for (int i = 1; i < lengthToCheck; i++) {
              Message msg = _messages[_messages.length - i];
              if (msg is UserMessage) {
                if (msg.user.nick == muteMessage.data) {
                  _messages[_messages.length - i] = msg.censor(true);
                }
              }
            }
            _messages.add(StatusMessage(
                data: "${muteMessage.data} muted by ${muteMessage.nick}"));
            break;
          // case "UNMUTE":
          //   break;
          case "BAN":
            BanMessage banMessage = BanMessage.fromJson(jsonString);
            _messages.add(StatusMessage(
                data: "${banMessage.data} banned by ${banMessage.nick}"));
            break;
          case "UNBAN":
            UnbanMessage unbanMessage = UnbanMessage.fromJson(jsonString);
            _messages.add(StatusMessage(
                data: "${unbanMessage.data} unbanned by ${unbanMessage.nick}"));
            break;
          case "REFRESH":
            _messages
                .add(StatusMessage(data: "Being disconnected by server..."));
            break;
          // // Other possible types
          // case "SUBONLY":
          //   break;
          // case "PING":
          //   break;
          // case "PONG":
          //   break;
          // case "PRIVMSG":
          //   break;
          // case "ERR":
          //   break;
          default:
            print(data);
            break;
        }
        //When messages length grows to 300, shrink to 150
        if (_messages.length > 300) {
          _messages.removeRange(0, 150);
        }
        notifyCallback();
      },
      onDone: () {
        _messages.add(StatusMessage(data: "Disconneced"));
        _isChatConnected = false;
      },
      onError: (error) {
        print("STREAM REPORTED ERROR");
      },
    );
  }

  Future<void> closeWebSocket() async {
    _isChatConnected = false;
    await _chatSubscription?.cancel();
    await _channel?.sink?.close(status.goingAway);
  }

  Future<void> disconnect() async {
    await closeWebSocket();
    _messages.add(StatusMessage(data: "Disconneced"));
  }

  Future<void> reconnect(Function notifyCallback) async {
    await closeWebSocket();
    openWebSocketConnection(notifyCallback);
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
    await closeWebSocket();
    _messages.add(StatusMessage(data: "Disconneced"));
    flairs = null;
    emotes = null;
  }

  void uncensorMessage(int messageIndex) {
    _messages[messageIndex] =
        (_messages[messageIndex] as UserMessage).censor(false);
  }

  Future<void> _loadEmote(Emote emote, Function notifyCallback) async {
    //TODO do some kind of caching
    //Download emote
    emote.loading = true;
    emote.image = await _imageService.downloadAndProcessEmote(emote);
    emote.loading = false;
    //Update UI
    notifyCallback();
  }

  void sendChatMessage(String message) {
    try {
      _channel.sink.add('MSG {"data": "$message"}');
    } catch (_) {
      print("Message failed to send");
    }
  }
}
