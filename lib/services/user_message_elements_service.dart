import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/user_message_element.dart';

import '../datamodels/user.dart';

class UserMessageElementsService {
  final RegExp _urlRegex = RegExp(
    r"(http://|ftp://|https://)?([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?",
    caseSensitive: false,
  );
  final RegExp _embedUrlRegex = RegExp(
    r"#(twitch|twitch-vod|twitch-clip|youtube)\/(?:[A-z0-9_\-]{3,64})",
    caseSensitive: false,
  );

  final RegExp _mentionRegex = RegExp(
    r"(?:(?:^|\s)@?)([a-zA-Z0-9_]{3,20})(?=$|\s|[.?!,])",
    caseSensitive: false,
  );

  List<UserMessageElement> createMessageElements(String text, Emotes emotes, List<User> users) {
    if (text.isEmpty) {
      return [];
    }

    List<UserMessageElement> elements = parseUrls([TextElement(text)]);
    if (emotes.emoteMap.isNotEmpty) {
      elements = parseEmotes(elements, emotes);
    }
    elements = parseEmbedUrls(elements);
    elements = parseMentions(elements, users);

    return elements;
  }

  List<UserMessageElement> parseUrls(List<UserMessageElement> elements) {
    List<UserMessageElement> list = List<UserMessageElement>.from(elements);
    for (var i = 0; i < list.length; i++) {
      if (list[i] is TextElement) {
        RegExpMatch? match = _urlRegex.firstMatch(list[i].text);
        if (match != null) {
          String currentText = list[i].text;
          String url = currentText.substring(match.start, match.end);
          int insertIndex = i + 1;
          if (match.start > 0) {
            list[i] = TextElement(currentText.substring(0, match.start));
            list.insert(insertIndex++, UrlElement(url));
          } else {
            list[i] = UrlElement(url);
          }

          if (match.end < currentText.length) {
            list.insert(
                insertIndex, TextElement(currentText.substring(match.end)));
          }
        }
      }
    }

    return list;
  }

  List<UserMessageElement> parseEmotes(
      List<UserMessageElement> elements, Emotes emotes) {
    List<UserMessageElement> list = List<UserMessageElement>.from(elements);
    for (var i = 0; i < list.length; i++) {
      if (list[i] is TextElement) {
        RegExpMatch? match = emotes.emoteRegex.firstMatch(list[i].text);
        if (match != null) {
          String currentText = list[i].text;
          String emoteName = currentText.substring(match.start, match.end);
          int insertIndex = i + 1;
          if (match.start > 0) {
            list[i] = TextElement(currentText.substring(0, match.start));
            list.insert(insertIndex++,
                EmoteElement(emoteName, emotes.emoteMap[emoteName]!));
          } else {
            list[i] = EmoteElement(emoteName, emotes.emoteMap[emoteName]!);
          }

          if (match.end < currentText.length) {
            list.insert(
                insertIndex, TextElement(currentText.substring(match.end)));
          }
        }
      }
    }

    return list;
  }

  List<UserMessageElement> parseEmbedUrls(List<UserMessageElement> elements) {
    List<UserMessageElement> list = List<UserMessageElement>.from(elements);
    for (var i = 0; i < list.length; i++) {
      if (list[i] is TextElement) {
        RegExpMatch? match = _embedUrlRegex.firstMatch(list[i].text);
        if (match != null) {
          String currentText = list[i].text;
          String embedUrl = currentText.substring(match.start, match.end);
          int insertIndex = i + 1;
          String channel = embedUrl.substring(embedUrl.indexOf('/') + 1);
          String embedType = embedUrl.substring(1, embedUrl.indexOf('/'));
          if (match.start > 0) {
            list[i] = TextElement(currentText.substring(0, match.start));
            list.insert(
                insertIndex++, EmbedUrlElement(embedUrl, channel, embedType));
          } else {
            list[i] = EmbedUrlElement(embedUrl, channel, embedType);
          }

          if (match.end < currentText.length) {
            list.insert(
                insertIndex, TextElement(currentText.substring(match.end)));
          }
        }
      }
    }

    return list;
  }

  List<UserMessageElement> parseMentions(
      List<UserMessageElement> elements, List<User> users) {
    List<UserMessageElement> list = List<UserMessageElement>.from(elements);
    for (var i = 0; i < list.length; i++) {
      if (list[i] is TextElement) {
        RegExpMatch? match = _mentionRegex.firstMatch(list[i].text);
        if (match != null) {
          String currentText = list[i].text;
          String mentionedNick = currentText.substring(match.start, match.end);
          int userIndex = users.indexWhere((element) => element.nick == mentionedNick);
          if (userIndex != -1){
            int insertIndex = i + 1;
            if (match.start > 0) {
              list[i] = TextElement(currentText.substring(0, match.start));
              list.insert(insertIndex++,
                  MentionElement(mentionedNick, users[userIndex]));
            } else {
              list[i] = MentionElement(mentionedNick, users[userIndex]);
            }

            if (match.end < currentText.length) {
              list.insert(
                  insertIndex, TextElement(currentText.substring(match.end)));
            }
          }
        }
      }
    }

    return list;
  }
}
