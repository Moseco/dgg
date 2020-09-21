import 'dart:convert';

import 'package:dgg/datamodels/user.dart';

abstract class Message {
  const Message();
}

class UserMessage extends Message {
  final User user;
  final String data;

  const UserMessage({
    this.user,
    this.data,
  });

  static UserMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    String data = json['data'] as String;
    List<String> features = json['features'].cast<String>();
    return UserMessage(
      user: User(
        nick: json['nick'] as String,
        features: features,
      ),
      data: data,
    );
  }
}

class NamesMessage extends Message {
  final List<User> users;

  const NamesMessage({
    this.users,
  });

  static NamesMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    List<User> chatUsers = List();
    json['users']
        .cast<dynamic>()
        .forEach((item) => chatUsers.add(User.fromJson(item)));

    return NamesMessage(
      users: chatUsers,
    );
  }
}

class StatusMessage extends Message {
  final String data;

  const StatusMessage({
    this.data,
  });
}

class JoinMessage extends Message {
  final User user;

  const JoinMessage({
    this.user,
  });

  static JoinMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    User user = User.fromJson(json);

    return JoinMessage(
      user: user,
    );
  }
}

class QuitMessage extends Message {
  final User user;

  const QuitMessage({
    this.user,
  });

  static QuitMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    User user = User.fromJson(json);

    return QuitMessage(
      user: user,
    );
  }
}
