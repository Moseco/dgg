import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UserMessageElementsService {
  final RegExp _urlRegex = RegExp(
    r"(http://|ftp://|https://)?([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?",
    caseSensitive: false,
  );

  List<UserMessageElement> createMessageElements(String text, Emotes emotes) {
    if (text.isEmpty) {
      return [];
    }

    List<UserMessageElement> elements = parseUrls([TextElement(text)]);
    if (emotes.emoteMap.length > 0) {
      elements = parseEmotes(elements, emotes);
    }

    return elements;
  }

  List<UserMessageElement> parseUrls(List<UserMessageElement> elements) {
    List<UserMessageElement> list = List<UserMessageElement>.from(elements);
    for (var i = 0; i < list.length; i++) {
      if (list[i] is TextElement) {
        RegExpMatch match = _urlRegex.firstMatch(list[i].text);
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
        RegExpMatch match = emotes.emoteRegex.firstMatch(list[i].text);
        if (match != null) {
          String currentText = list[i].text;
          String emoteName = currentText.substring(match.start, match.end);
          int insertIndex = i + 1;
          if (match.start > 0) {
            list[i] = TextElement(currentText.substring(0, match.start));
            list.insert(insertIndex++,
                EmoteElement(emoteName, emotes.emoteMap[emoteName]));
          } else {
            list[i] = EmoteElement(emoteName, emotes.emoteMap[emoteName]);
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
}
