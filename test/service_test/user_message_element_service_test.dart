import 'package:dgg/services/user_message_elements_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/user_message_element.dart';

void main() {
  group('UserMessageElementsServiceTest', () {
    final _userMessageElementsService = UserMessageElementsService();

    test('Empty string', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 0);
    });

    test('Text only', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "Hello world! This is a test",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "Hello world! This is a test");
    });

    test('Proper url only', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "http://www.example.com",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, UrlElement);
      expect(elements[0].text, "http://www.example.com");
    });

    test('Multiple proper url only', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "http://www.example.com http://www.example.com/other",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 3);
      expect(elements[0].runtimeType, UrlElement);
      expect(elements[0].text, "http://www.example.com");
      expect(elements[1].runtimeType, TextElement);
      expect(elements[1].text, " ");
      expect(elements[2].runtimeType, UrlElement);
      expect(elements[2].text, "http://www.example.com/other");
    });

    test('Test with proper url', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "Hello http://www.example.com world",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 3);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "Hello ");
      expect(elements[1].runtimeType, UrlElement);
      expect(elements[1].text, "http://www.example.com");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, " world");
    });

    test('Text with multiple proper urls 1', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "Hello world http://www.example.com other words http://www.example.com/other",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 4);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "Hello world ");
      expect(elements[1].runtimeType, UrlElement);
      expect(elements[1].text, "http://www.example.com");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, " other words ");
      expect(elements[3].runtimeType, UrlElement);
      expect(elements[3].text, "http://www.example.com/other");
    });

    test('Text with multiple proper urls 2', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "Hello world http://www.example.com other words http://www.example.com/other ending words.",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 5);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "Hello world ");
      expect(elements[1].runtimeType, UrlElement);
      expect(elements[1].text, "http://www.example.com");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, " other words ");
      expect(elements[3].runtimeType, UrlElement);
      expect(elements[3].text, "http://www.example.com/other");
      expect(elements[4].runtimeType, TextElement);
      expect(elements[4].text, " ending words.");
    });

    test('Text and url with unusual spacing', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "  Hello     multiple  space  https://example.com     ",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 3);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "  Hello     multiple  space  ");
      expect(elements[1].runtimeType, UrlElement);
      expect(elements[1].text, "https://example.com");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, "     ");
    });

    test('Basic url', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "example.com",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, UrlElement);
      expect(elements[0].text, "example.com");
    });

    test('Multiple punctuation', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "This is a... multiple thing test!!!",
        Emotes(emoteMap: {}),
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is a... multiple thing test!!!");
    });

    test('Only emote', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "EMOTE",
        Emotes(
          emoteMap: {"EMOTE": ""},
          emoteRegex: RegExp("\\bEMOTE\\b"),
        ),
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, EmoteElement);
      expect(elements[0].text, "EMOTE");
    });

    test('Only emote multiple', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "EMOTE2 EMOTE",
        Emotes(
          emoteMap: {"EMOTE": "", "EMOTE2": ""},
          emoteRegex: RegExp("\\bEMOTE\\b|\\bEMOTE2\\b"),
        ),
      );

      expect(elements.length, 3);
      expect(elements[0].runtimeType, EmoteElement);
      expect(elements[0].text, "EMOTE2");
      expect(elements[1].runtimeType, TextElement);
      expect(elements[1].text, " ");
      expect(elements[2].runtimeType, EmoteElement);
      expect(elements[2].text, "EMOTE");
    });

    test('Text with emote', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "This is a test with the emote EMOTE",
        Emotes(
          emoteMap: {"EMOTE": ""},
          emoteRegex: RegExp("\\bEMOTE\\b"),
        ),
      );

      expect(elements.length, 2);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is a test with the emote ");
      expect(elements[1].runtimeType, EmoteElement);
      expect(elements[1].text, "EMOTE");
    });

    test('Emote name within word', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "This is so goooooood",
        Emotes(
          emoteMap: {"oooo": ""},
          emoteRegex: RegExp("\\boooo\\b"),
        ),
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is so goooooood");
    });

    test('Text with emote 2', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "This is a test with the emote EMOTE following text",
        Emotes(
          emoteMap: {"EMOTE": ""},
          emoteRegex: RegExp("\\bEMOTE\\b"),
        ),
      );

      expect(elements.length, 3);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is a test with the emote ");
      expect(elements[1].runtimeType, EmoteElement);
      expect(elements[1].text, "EMOTE");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, " following text");
    });

    test('Text with multiple emotes', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "This is a EMOTE2 test with the emote EMOTE EMOTE and another emote following text",
        Emotes(
          emoteMap: {"EMOTE": "", "EMOTE2": ""},
          emoteRegex: RegExp("\\bEMOTE\\b|\\bEMOTE2\\b"),
        ),
      );

      expect(elements.length, 7);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is a ");
      expect(elements[1].runtimeType, EmoteElement);
      expect(elements[1].text, "EMOTE2");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, " test with the emote ");
      expect(elements[3].runtimeType, EmoteElement);
      expect(elements[3].text, "EMOTE");
      expect(elements[4].runtimeType, TextElement);
      expect(elements[4].text, " ");
      expect(elements[5].runtimeType, EmoteElement);
      expect(elements[5].text, "EMOTE");
      expect(elements[6].runtimeType, TextElement);
      expect(elements[6].text, " and another emote following text");
    });

    test('Text with urls and emotes', () {
      List<UserMessageElement> elements =
          _userMessageElementsService.createMessageElements(
        "This is a EMOTE2 test with exmaple.com and the emotes EMOTE EMOTE and another emote following text",
        Emotes(
          emoteMap: {"EMOTE": "", "EMOTE2": ""},
          emoteRegex: RegExp("\\bEMOTE\\b|\\bEMOTE2\\b"),
        ),
      );

      expect(elements.length, 9);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is a ");
      expect(elements[1].runtimeType, EmoteElement);
      expect(elements[1].text, "EMOTE2");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, " test with ");
      expect(elements[3].runtimeType, UrlElement);
      expect(elements[3].text, "exmaple.com");
      expect(elements[4].runtimeType, TextElement);
      expect(elements[4].text, " and the emotes ");
      expect(elements[5].runtimeType, EmoteElement);
      expect(elements[5].text, "EMOTE");
      expect(elements[6].runtimeType, TextElement);
      expect(elements[6].text, " ");
      expect(elements[7].runtimeType, EmoteElement);
      expect(elements[7].text, "EMOTE");
      expect(elements[8].runtimeType, TextElement);
      expect(elements[8].text, " and another emote following text");
    });
  });
}
