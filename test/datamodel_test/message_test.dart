import 'package:dgg/datamodels/emotes.dart';
import 'package:dgg/datamodels/message.dart';
import 'package:dgg/datamodels/user.dart';
import 'package:dgg/datamodels/user_message_element.dart';
import 'package:flutter_test/flutter_test.dart';

import '../setup/test_data.dart';

void main() {
  // Tests for messages in general
  group('MessageTest', () {
    test('Names message', () {
      NamesMessage namesMessage =
          NamesMessage.fromJson(TestData.WS_NAMES_STRING);

      expect(namesMessage.users.length, 3);

      expect(namesMessage.users[0].nick, "NameExample");
      expect(namesMessage.users[0].features, []);

      expect(namesMessage.users[1].nick, "OtherName");
      expect(namesMessage.users[1].features, ["subscriber", "flair3"]);

      expect(namesMessage.users[2].nick, "ThirdPerson");
      expect(
          namesMessage.users[2].features, ["subscriber", "flair13", "flair16"]);
    });

    test('User message no flair', () {
      //TODO will need some mock here

      // UserMessage userMessage = UserMessage.fromJson(TestData.WS_USER_MESSAGE_NO_FLAIR_STRING, [], [], (, ) => null,);
    });

    test('User message with flair', () {
      //TODO will need some mock here
    });

    test('Status message', () {
      String text = "This is simple";
      StatusMessage statusMessage = StatusMessage(data: text);

      expect(statusMessage.data, text);
    });

    test('Join message', () {
      JoinMessage joinMessage = JoinMessage.fromJson(TestData.WS_JOIN_STRING);

      expect(joinMessage.user.nick, "ExampleName");
      expect(joinMessage.user.features, ["subscriber", "flair9"]);
    });

    test('Quit message', () {
      QuitMessage quitMessage = QuitMessage.fromJson(TestData.WS_QUIT_STRING);

      expect(quitMessage.user.nick, "ExampleName");
      expect(quitMessage.user.features, []);
    });

    test('Broadcast message', () {
      BroadcastMessage broadcastMessage =
          BroadcastMessage.fromJson(TestData.WS_BROADCAST_STRING);

      expect(broadcastMessage.data, "NAME has resubscribed on Twitch!");
    });

    test('Mute message', () {
      MuteMessage muteMessage = MuteMessage.fromJson(TestData.WS_MUTE_STRING);

      expect(muteMessage.nick, "Bot");
      expect(muteMessage.data, "ExampleName");
    });

    test('Unmute message', () {
      UnmuteMessage unmuteMessage =
          UnmuteMessage.fromJson(TestData.WS_UNMUTE_STRING);

      expect(unmuteMessage.nick, "Bot");
      expect(unmuteMessage.data, "ExampleName");
    });

    test('Ban message', () {
      BanMessage banMessage = BanMessage.fromJson(TestData.WS_BAN_STRING);

      expect(banMessage.nick, "Bot");
      expect(banMessage.data, "ExampleName");
    });

    test('Unban message', () {
      UnbanMessage unbanMessage =
          UnbanMessage.fromJson(TestData.WS_UNBAN_STRING);

      expect(unbanMessage.nick, "Bot");
      expect(unbanMessage.data, "ExampleName");
    });

    test('Error message dusplicate', () {
      ErrorMessage errorMessage =
          ErrorMessage.fromJson(TestData.WS_ERR_DUPLICATE_STRING);

      expect(errorMessage.description, "duplicate");
    });
  });

  // Tests for message elements
  group('MessageElementTest', () {
    Emotes exampleEmotes = Emotes.fromJson(TestData.EMOTE_STRING);
    Map<String, User> userMap = {
      'potatO123': User(features: [], nick: 'potatO123'),
      '_asdlol': User(features: [], nick: '_asdlol'),
      'a_aEE': User(features: [], nick: 'a_aEE'),
      'BoB': User(features: [], nick: 'BoB')
    };

    test('Empty string', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 0);
    });

    test('Text only', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "Hello world! This is a test",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "Hello world! This is a test");
    });

    test('Proper url only', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "http://www.example.com",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, UrlElement);
      expect(elements[0].text, "http://www.example.com");
    });

    test('Multiple proper url only', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "http://www.example.com http://www.example.com/other",
        exampleEmotes,
        userMap,
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
      List<UserMessageElement> elements = UserMessage.createElements(
        "Hello http://www.example.com world",
        exampleEmotes,
        userMap,
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
      List<UserMessageElement> elements = UserMessage.createElements(
        "Hello world http://www.example.com other words http://www.example.com/other",
        exampleEmotes,
        userMap,
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
      List<UserMessageElement> elements = UserMessage.createElements(
        "Hello world http://www.example.com other words http://www.example.com/other ending words.",
        exampleEmotes,
        userMap,
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
      List<UserMessageElement> elements = UserMessage.createElements(
        "  Hello     multiple  space  https://example.com     ",
        exampleEmotes,
        userMap,
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
      List<UserMessageElement> elements = UserMessage.createElements(
        "example.com",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, UrlElement);
      expect(elements[0].text, "example.com");
    });

    test('Multiple punctuation', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "This is a... multiple thing test!!!",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is a... multiple thing test!!!");
    });

    test('Only emote', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "EMOTE",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, EmoteElement);
      expect(elements[0].text, "EMOTE");
    });

    test('Only emote multiple', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "EMOTE2 EMOTE",
        exampleEmotes,
        userMap,
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
      List<UserMessageElement> elements = UserMessage.createElements(
        "This is a test with the emote EMOTE",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 2);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is a test with the emote ");
      expect(elements[1].runtimeType, EmoteElement);
      expect(elements[1].text, "EMOTE");
    });

    test('Emote name within word', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "This is so goooooood",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is so goooooood");
    });

    test('Text with emote 2', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "This is a test with the emote EMOTE following text",
        exampleEmotes,
        userMap,
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
      List<UserMessageElement> elements = UserMessage.createElements(
        "This is a EMOTE2 test with the emote EMOTE EMOTE and another emote following text",
        exampleEmotes,
        userMap,
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
      List<UserMessageElement> elements = UserMessage.createElements(
        "This is a EMOTE2 test with exmaple.com and the emotes EMOTE EMOTE and another emote following text",
        exampleEmotes,
        userMap,
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

    test('Text with no emotes loaded', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "This is example text",
        Emotes(emoteMap: {}, emoteRegex: RegExp("")),
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is example text");
    });

    test('Only stream embed', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "#twitch/name",
        Emotes(emoteMap: {}, emoteRegex: RegExp("")),
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, EmbedUrlElement);
      expect(elements[0].text, "#twitch/name");
      expect((elements[0] as EmbedUrlElement).embedId, "name");
      expect((elements[0] as EmbedUrlElement).embedType, "twitch");
    });

    test('Stream embed and text', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "Watching #twitch/name now",
        Emotes(emoteMap: {}, emoteRegex: RegExp("")),
        userMap,
      );

      expect(elements.length, 3);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "Watching ");
      expect(elements[1].runtimeType, EmbedUrlElement);
      expect(elements[1].text, "#twitch/name");
      expect((elements[1] as EmbedUrlElement).embedId, "name");
      expect((elements[1] as EmbedUrlElement).embedType, "twitch");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, " now");
    });

    test('Invalid embed', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "#twitc/name",
        Emotes(emoteMap: {}, emoteRegex: RegExp("")),
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
    });

    test('Invalid embed 2', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "#twitch",
        Emotes(emoteMap: {}, emoteRegex: RegExp("")),
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, TextElement);
    });

    test('Stream embed with period', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "#youtube/name.",
        Emotes(emoteMap: {}, emoteRegex: RegExp("")),
        userMap,
      );

      expect(elements.length, 2);
      expect(elements[0].runtimeType, EmbedUrlElement);
      expect(elements[0].text, "#youtube/name");
      expect((elements[0] as EmbedUrlElement).embedId, "name");
      expect((elements[0] as EmbedUrlElement).embedType, "youtube");
    });

    test('Only mention', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "_asdlol",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 1);
      expect(elements[0].runtimeType, MentionElement);
      expect(elements[0].text, "_asdlol");
    });

    test('Only mention with @', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "@_asdlol",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 2);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "@");
      expect(elements[1].runtimeType, MentionElement);
      expect(elements[1].text, "_asdlol");
    });

    test('Only mention with leading and trailing', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "@_asdlol!",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 3);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "@");
      expect(elements[1].runtimeType, MentionElement);
      expect(elements[1].text, "_asdlol");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, "!");
    });

    test('Multiple mentions', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "potatO123 _asdlol @a_aEE",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 5);
      expect(elements[0].runtimeType, MentionElement);
      expect(elements[0].text, "potatO123");
      expect(elements[1].runtimeType, TextElement);
      expect(elements[1].text, " ");
      expect(elements[2].runtimeType, MentionElement);
      expect(elements[2].text, "_asdlol");
      expect(elements[3].runtimeType, TextElement);
      expect(elements[3].text, " @");
      expect(elements[4].runtimeType, MentionElement);
      expect(elements[4].text, "a_aEE");
    });

    test('Text with mentions', () {
      List<UserMessageElement> elements = UserMessage.createElements(
        "This is a test with the users BoB and potatO123 in it",
        exampleEmotes,
        userMap,
      );

      expect(elements.length, 5);
      expect(elements[0].runtimeType, TextElement);
      expect(elements[0].text, "This is a test with the users ");
      expect(elements[1].runtimeType, MentionElement);
      expect(elements[1].text, "BoB");
      expect(elements[2].runtimeType, TextElement);
      expect(elements[2].text, " and ");
      expect(elements[3].runtimeType, MentionElement);
      expect(elements[3].text, "potatO123");
      expect(elements[4].runtimeType, TextElement);
      expect(elements[4].text, " in it");
    });
  });
}
