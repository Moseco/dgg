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

@lazySingleton
class DggApi {
  static const String sessionInfoUrl = "https://www.destiny.gg/api/chat/me";
  static const String webSocketUrl = "wss://www.destiny.gg/ws";
  static const String flaisrUrl =
      "https://cdn.destiny.gg/2.19.0/flairs/flairs.json";
  static const String emotesUrl =
      "https://cdn.destiny.gg/2.19.0/emotes/emotes.json";
  static const String emotesCssUrl =
      "https://cdn.destiny.gg/2.19.0/emotes/emotes.css";

  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _userMessageElementsService = locator<UserMessageElementsService>();
  final _imageService = locator<ImageService>();

  //Authentication information
  AuthInfo _authInfo;
  SessionInfo _sessionInfo;
  SessionInfo get sessionInfo => _sessionInfo;

  //Assets
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
            );
            _messages.add(userMessage);
            //for each emote, check if needs to be loaded
            userMessage.elements.forEach((element) {
              if (element is EmoteElement) {
                if (!element.emote.loading && element.emote.image == null) {
                  _loadEmote(element.emote, notifyCallback);
                }
              }
            });
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
            _messages
                .add(StatusMessage(data: "${muteMessage.data} muted by Bot"));
            break;
          // case "UNMUTE":
          //   break;
          // case "BAN":
          //   break;
          // case "UNBAN":
          //   break;
          // case "REFRESH":
          //   break;
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
        notifyCallback();
      },
      onDone: () {
        print("STREAM REPORTED DONE");
      },
      onError: (error) {
        print("STREAM REPORTED ERROR");
      },
    );
  }

  Future<void> closeWebSocket() async {
    await _chatSubscription?.cancel();
    await _channel?.sink?.close();
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
    await getFlairs();
    await getEmotes();
  }

  Future<void> getFlairs() async {
    if (flairs == null) {
      final response = await http.get(flaisrUrl);

      if (response.statusCode == 200) {
        flairs = Flairs.fromJson(response.body);
      } else {
        flairs = Flairs([]);
      }
    }
  }

  Future<void> getEmotes() async {
    if (emotes == null) {
      final response = await http.get(emotesUrl);

      if (response.statusCode == 200) {
        Emotes emoteList = Emotes.fromJson(response.body);
        await _getEmoteCss(emoteList);
      } else {
        emotes = Emotes();
      }
    }
  }

  Future<void> _getEmoteCss(Emotes emoteList) async {
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
}
