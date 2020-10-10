import 'dart:async';
import 'dart:io';

import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/datamodels/user.dart';
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
  static const String flaisrUrl = "https://cdn.destiny.gg/flairs/flairs.json";
  static const String emotesUrl = "https://cdn.destiny.gg/emotes/emotes.json";
  static const String emotesUrl2 = "https://polecat.me/api/dgg_emotes";

  final _sharedPreferencesService = locator<SharedPreferencesService>();
  final _userMessageElementsService = locator<UserMessageElementsService>();

  AuthInfo _authInfo;

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

  Future<SessionInfo> getSessionInfo() async {
    _authInfo = await _sharedPreferencesService.getAuthInfo();

    if (_authInfo == null) {
      return Unavailable();
    }

    final response = await http.get(
      sessionInfoUrl,
      headers: _authInfo != null
          ? {HttpHeaders.cookieHeader: _authInfo.toHeaderString()}
          : null,
    );

    if (response.statusCode == 200) {
      return Available.fromJson(response.body);
    } else {
      return Unavailable(httpStatusCode: response.statusCode);
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
            _messages.add(UserMessage.fromJson(
              jsonString,
              flairs,
              emotes,
              _userMessageElementsService.createMessageElements,
            ));
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
      final response = await http.get(emotesUrl2);

      if (response.statusCode == 200) {
        emotes = Emotes.fromJson(response.body);
      } else {
        emotes = Emotes();
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
}
