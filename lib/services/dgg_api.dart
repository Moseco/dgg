import 'dart:async';
import 'dart:io';

import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:dgg/datamodels/user.dart';
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

  final _sharedPreferencesService = locator<SharedPreferencesService>();

  AuthInfo _authInfo;

  WebSocketChannel _channel;
  StreamSubscription _chatSubscription;

  List<Message> _messages = [StatusMessage(data: "Connecting...")];
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

  openWebSocketConnection(Function notifyCallback) {
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
            break;
          case "MSG":
            _messages.add(UserMessage.fromJson(
              jsonString,
            ));
            break;
          case "JOIN":
            _users.add(JoinMessage.fromJson(jsonString).user);
            break;
          case "QUIT":
            _users.remove(QuitMessage.fromJson(jsonString).user);
            break;
          // case "BROADCAST":
          //   break;
          // case "MUTE":
          //   break;
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
            return null;
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

  closeWebSocket() {
    _chatSubscription?.cancel();
    _channel?.sink?.close();
  }
}
