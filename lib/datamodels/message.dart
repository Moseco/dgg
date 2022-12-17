import 'dart:convert';

import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/flairs.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:dgg/utils/constants.dart';
import 'package:flutter/material.dart' show visibleForTesting;

abstract class Message {
  const Message();
}

class UserMessage extends Message {
  final User user;
  final String data;
  final List<UserMessageElement> elements;
  final List<Flair> visibleFlairs;
  final int? color;
  final bool rainbowColor;
  final bool isMentioned;
  final bool isOwn;
  final bool isGreenText;
  final bool isNsfw;
  final bool isNsfl;
  final DateTime timestamp;
  bool isCensored;

  UserMessage({
    required this.user,
    required this.data,
    required this.elements,
    required this.visibleFlairs,
    this.color,
    this.rainbowColor = false,
    this.isMentioned = false,
    this.isOwn = false,
    this.isGreenText = false,
    this.isNsfw = false,
    this.isNsfl = false,
    required this.timestamp,
    this.isCensored = false,
  });

  static UserMessage fromJson(
    String jsonString,
    Flairs flairs,
    Emotes emotes,
    Map<String, User> userMap,
    String? currentNick,
  ) {
    Map<String, dynamic> map = jsonDecode(jsonString);

    String data = map['data'] as String;
    User user = User.fromJson(map);

    // Check message contents for how message is displayed
    bool isMentioned = currentNick != null
        ? data.contains(RegExp("(\\@?)\\b$currentNick\\b"))
        : false;
    bool isOwn = user.nick == currentNick;
    bool isGreenText = data.startsWith('>');
    bool isNsfw = data.contains(RegExp("\\bnsfw\\b", caseSensitive: false));
    bool isNsfl = data.contains(RegExp("\\bnsfl\\b", caseSensitive: false));

    return UserMessage(
      user: user,
      data: data,
      elements: createElements(data, emotes, userMap),
      visibleFlairs: getVisibleFlairs(user.features, flairs),
      color: getColor(user.features, flairs),
      rainbowColor: user.features.contains('flair42'),
      isMentioned: isMentioned,
      isOwn: isOwn,
      isGreenText: isGreenText,
      isNsfw: isNsfw,
      isNsfl: isNsfl,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
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

  static List<Flair> getVisibleFlairs(List<String> features, Flairs flairs) {
    List<Flair> visibleFlairs = [];
    for (int i = 0; i < features.length; i++) {
      Flair? current = flairs.flairMap[features[i]];
      if (current != null && !current.hidden) {
        visibleFlairs.add(current);
      }
    }

    return visibleFlairs;
  }

  @visibleForTesting
  static List<UserMessageElement> createElements(
    String text,
    Emotes emotes,
    Map<String, User> userMap,
  ) {
    if (text.isEmpty) {
      return [];
    }

    List<UserMessageElement> elements = [TextElement(text)];

    // Parse urls
    for (var i = 0; i < elements.length; i++) {
      if (elements[i] is TextElement) {
        RegExpMatch? match = Constants.urlRegex.firstMatch(elements[i].text);
        if (match != null) {
          String currentText = elements[i].text;
          String url = currentText.substring(match.start, match.end);
          int insertIndex = i + 1;
          if (match.start > 0) {
            elements[i] = TextElement(currentText.substring(0, match.start));
            elements.insert(insertIndex++, UrlElement(url));
          } else {
            elements[i] = UrlElement(url);
          }

          if (match.end < currentText.length) {
            elements.insert(
              insertIndex,
              TextElement(currentText.substring(match.end)),
            );
          }
        }
      }
    }

    // Parse emotes if available
    if (emotes.emoteMap.isNotEmpty) {
      for (var i = 0; i < elements.length; i++) {
        if (elements[i] is TextElement) {
          RegExpMatch? match = emotes.emoteRegex.firstMatch(elements[i].text);
          if (match != null) {
            String currentText = elements[i].text;
            String emoteName = currentText.substring(match.start, match.end);
            int insertIndex = i + 1;
            if (match.start > 0) {
              elements[i] = TextElement(currentText.substring(0, match.start));
              elements.insert(insertIndex++,
                  EmoteElement(emoteName, emotes.emoteMap[emoteName]!));
            } else {
              elements[i] =
                  EmoteElement(emoteName, emotes.emoteMap[emoteName]!);
            }

            if (match.end < currentText.length) {
              elements.insert(
                insertIndex,
                TextElement(currentText.substring(match.end)),
              );
            }
          }
        }
      }
    }

    // Parse embed urls
    for (var i = 0; i < elements.length; i++) {
      if (elements[i] is TextElement) {
        RegExpMatch? match =
            Constants.embedUrlRegex.firstMatch(elements[i].text);
        if (match != null) {
          String currentText = elements[i].text;
          String embedUrl = currentText.substring(match.start, match.end);
          int insertIndex = i + 1;
          String channel = embedUrl.substring(embedUrl.indexOf('/') + 1);
          String embedType = embedUrl.substring(1, embedUrl.indexOf('/'));
          if (match.start > 0) {
            elements[i] = TextElement(currentText.substring(0, match.start));
            elements.insert(
                insertIndex++, EmbedUrlElement(embedUrl, channel, embedType));
          } else {
            elements[i] = EmbedUrlElement(embedUrl, channel, embedType);
          }

          if (match.end < currentText.length) {
            elements.insert(
              insertIndex,
              TextElement(currentText.substring(match.end)),
            );
          }
        }
      }
    }

    // Parse mentions
    for (var i = 0; i < elements.length; i++) {
      if (elements[i] is TextElement) {
        Iterator<RegExpMatch> matches =
            Constants.mentionRegex.allMatches(elements[i].text).iterator;
        String currentText = elements[i].text;

        while (matches.moveNext()) {
          RegExpMatch match = matches.current;
          RegExpMatch? nickMatch = Constants.nickRegex.firstMatch(
            match.input.substring(match.start, match.end),
          );
          if (nickMatch == null) {
            continue;
          }
          String mentionedNick = nickMatch.input.substring(
            nickMatch.start,
            nickMatch.end,
          );
          User? user = userMap[mentionedNick];
          if (user != null) {
            int insertIndex = i + 1;
            if (nickMatch.start > 0) {
              elements[i] = TextElement(
                  currentText.substring(0, match.start + nickMatch.start));
              elements.insert(insertIndex++,
                  MentionElement(mentionedNick, userMap[mentionedNick]!));
            } else {
              elements[i] =
                  MentionElement(mentionedNick, userMap[mentionedNick]!);
            }

            if (match.end < currentText.length) {
              elements.insert(
                insertIndex,
                TextElement(currentText.substring(match.end)),
              );
            }
            break;
          }
        }
      }
    }

    return elements;
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
