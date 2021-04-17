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
  final List<UserMessageElement> elements;
  final int? color;
  final bool isMentioned;
  final bool isOwn;
  bool isCensored;

  UserMessage({
    required this.user,
    required this.data,
    required this.elements,
    this.color,
    this.isMentioned = false,
    this.isOwn = false,
    this.isCensored = false,
  });

  static UserMessage fromJson(
    String jsonString,
    Flairs flairs,
    Emotes? emotes,
    Function(String, Emotes?) createElements, {
    String? currentNick,
  }) {
    Map<String, dynamic> map = jsonDecode(jsonString);

    String data = map['data'] as String;
    User user = User.fromJson(map);

    //Check if current user is mentioned in message
    bool isMentioned = data.contains(RegExp("(\\@?)\\b$currentNick\\b"));
    bool isOwn = user.nick == currentNick;

    return UserMessage(
      user: user,
      data: data,
      color: getColor(user.features, flairs),
      elements: createElements(data, emotes),
      isMentioned: isMentioned,
      isOwn: isOwn,
    );
  }

  static int? getColor(List<String> features, Flairs flairs) {
    for (int i = 0; i < flairs.flairs.length; i++) {
      for (int j = 0; j < features.length; j++) {
        if (flairs.flairs[i].name == features[j]) {
          return flairs.flairs[i].color;
        }
      }
    }
    return null;
  }
}

class NamesMessage extends Message {
  final List<User> users;

  const NamesMessage(this.users);

  static NamesMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    List<User> chatUsers = [];
    json['users']
        .cast<dynamic>()
        .forEach((item) => chatUsers.add(User.fromJson(item)));

    return NamesMessage(chatUsers);
  }
}

class StatusMessage extends Message {
  final String data;
  final bool isError;

  const StatusMessage({required this.data, this.isError = false});
}

class JoinMessage extends Message {
  final User user;

  const JoinMessage(this.user);

  static JoinMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    User user = User.fromJson(json);

    return JoinMessage(user);
  }
}

class QuitMessage extends Message {
  final User user;

  const QuitMessage(this.user);

  static QuitMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);
    User user = User.fromJson(json);

    return QuitMessage(user);
  }
}

class BroadcastMessage extends Message {
  final String data;

  const BroadcastMessage(this.data);

  static BroadcastMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return BroadcastMessage(json['data'] as String);
  }
}

class MuteMessage extends Message {
  final String nick;
  final String data;

  const MuteMessage({required this.nick, required this.data});

  static MuteMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return MuteMessage(
      nick: json['nick'] as String,
      data: json['data'] as String,
    );
  }
}

class UnmuteMessage extends Message {
  final String nick;
  final String data;

  const UnmuteMessage({required this.nick, required this.data});

  static UnmuteMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return UnmuteMessage(
      nick: json['nick'] as String,
      data: json['data'] as String,
    );
  }
}

class BanMessage extends Message {
  final String nick;
  final String data;

  const BanMessage({required this.nick, required this.data});

  static BanMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return BanMessage(
      nick: json['nick'] as String,
      data: json['data'] as String,
    );
  }
}

class UnbanMessage extends Message {
  final String nick;
  final String data;

  const UnbanMessage({required this.nick, required this.data});

  static UnbanMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return UnbanMessage(
      nick: json['nick'] as String,
      data: json['data'] as String,
    );
  }
}

class ComboMessage extends Message {
  final int comboCount;
  final Emote emote;

  const ComboMessage({this.comboCount = 2, required this.emote});

  ComboMessage incrementCombo() {
    return ComboMessage(comboCount: comboCount + 1, emote: emote);
  }
}

class SubOnlyMessage extends Message {
  final String? nick;
  final String? data;

  const SubOnlyMessage({this.nick, this.data});

  static SubOnlyMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return SubOnlyMessage(
      nick: json['nick'] as String?,
      data: json['data'] as String?,
    );
  }
}

class ErrorMessage extends Message {
  final String description;

  const ErrorMessage(this.description);

  static ErrorMessage fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return ErrorMessage(json['description'] as String);
  }
}
