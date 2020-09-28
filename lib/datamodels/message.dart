import 'dart:convert';

import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:dgg/datamodels/user_message_element.dart';

abstract class Message {
  const Message();
}

class UserMessage extends Message {
  final User user;
  final String data;
  final int color;
  final List<UserMessageElement> elements;
  final bool censored;

  const UserMessage({
    this.user,
    this.data,
    this.color,
    this.elements,
    this.censored = false,
  });

  static UserMessage fromJson(
    String jsonString,
    Flairs flairs,
    Emotes emotes,
    Function(String, Emotes) createElements,
  ) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    String data = json['data'] as String;
    List<String> features = json['features'].cast<String>();
    return UserMessage(
      user: User(
        nick: json['nick'] as String,
        features: features,
      ),
      data: data,
      color: getColor(features, flairs),
      elements: createElements(data, emotes),
    );
  }

  static int getColor(List<String> features, Flairs flairs) {
    for (int i = 0; i < flairs.flairs.length; i++) {
      for (int j = 0; j < features.length; j++) {
        if (flairs.flairs[i].name == features[j]) {
          return flairs.flairs[i].color;
        }
      }
    }
    return null;
  }

  UserMessage censor(bool censor) {
    return UserMessage(
      user: this.user,
      data: this.data,
      color: this.color,
      elements: this.elements,
      censored: censor,
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

class BroadcastMessage extends Message {
  final String data;

  const BroadcastMessage({this.data});

  static BroadcastMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return BroadcastMessage(
      data: json['data'] as String,
    );
  }
}

class MuteMessage extends Message {
  final String data;

  const MuteMessage({this.data});

  static MuteMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return MuteMessage(
      data: json['data'] as String,
    );
  }
}
