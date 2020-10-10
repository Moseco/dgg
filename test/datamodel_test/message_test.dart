import 'package:dgg/datamodels/message.dart';
import 'package:flutter_test/flutter_test.dart';

import '../setup/test_data.dart';

void main() {
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

      expect(muteMessage.data, "ExampleName");
    });
  });
}