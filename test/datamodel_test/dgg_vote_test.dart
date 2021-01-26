import 'package:flutter_test/flutter_test.dart';
import 'package:dgg/datamodels/dgg_vote.dart';

void main() {
  group('MessageTest', () {
    test('Valid vote with time in seconds', () {
      DggVote dggVote =
          DggVote.fromString("/vote 45s Question here? option1 or option2");

      expect(dggVote == null, false);
      expect(dggVote.question, 'Question here?');
      expect(dggVote.options[0], 'option1');
      expect(dggVote.options[1], 'option2');
      expect(dggVote.voteCount.length, 2);
      expect(dggVote.time, 45);
      expect(dggVote.isSubVote, false);
    });

    test('Valid vote with time in minutes', () {
      DggVote dggVote = DggVote.fromString(
          "/vote 1m Question here? option1 is here or option2 is over here");

      expect(dggVote == null, false);
      expect(dggVote.question, 'Question here?');
      expect(dggVote.options[0], 'option1 is here');
      expect(dggVote.options[1], 'option2 is over here');
      expect(dggVote.voteCount.length, 2);
      expect(dggVote.time, 60);
      expect(dggVote.isSubVote, false);
    });

    test('Valid vote without time', () {
      DggVote dggVote =
          DggVote.fromString("/vote Question? option1 or option2");

      expect(dggVote == null, false);
      expect(dggVote.question, 'Question?');
      expect(dggVote.options[0], 'option1');
      expect(dggVote.options[1], 'option2');
      expect(dggVote.voteCount.length, 2);
      expect(dggVote.time, 30);
      expect(dggVote.isSubVote, false);
    });

    test('Valid subvote', () {
      DggVote dggVote =
          DggVote.fromString("/svote Question? option1 or option2");

      expect(dggVote == null, false);
      expect(dggVote.question, 'Question?');
      expect(dggVote.options[0], 'option1');
      expect(dggVote.options[1], 'option2');
      expect(dggVote.voteCount.length, 2);
      expect(dggVote.time, 30);
      expect(dggVote.isSubVote, true);
    });

    test('Valid vote, default options', () {
      DggVote dggVote = DggVote.fromString("/vote Question?");

      expect(dggVote == null, false);
      expect(dggVote.question, 'Question?');
      expect(dggVote.options[0], 'Yes');
      expect(dggVote.options[1], 'No');
      expect(dggVote.voteCount.length, 2);
      expect(dggVote.time, 30);
      expect(dggVote.isSubVote, false);
    });

    test('Invalid vote, no question', () {
      DggVote dggVote =
          DggVote.fromString("/vote invalid thing or invalid other thing");

      expect(dggVote == null, true);
    });

    test('Invalid vote, not enough options', () {
      DggVote dggVote = DggVote.fromString("/vote Invalid? optionsor");

      expect(dggVote == null, true);
    });

    test('Invalid vote, empty last option', () {
      DggVote dggVote = DggVote.fromString("/vote Invalid? options or");

      expect(dggVote == null, true);
    });

    test('Cast valid votes', () {
      DggVote dggVote =
          DggVote.fromString("/vote 45s Question here? option1 or option2");

      expect(dggVote.voteCount[0], 0);
      expect(dggVote.voteCount[1], 0);

      dggVote.castVote("Name", 1, []);

      expect(dggVote.voteCount[0], 1);
      expect(dggVote.voteCount[1], 0);

      dggVote.castVote("Other", 2, []);

      expect(dggVote.voteCount[0], 1);
      expect(dggVote.voteCount[1], 1);

      dggVote.castVote("Another", 1, []);

      expect(dggVote.voteCount[0], 2);
      expect(dggVote.voteCount[1], 1);
    });

    test('Cast multiple votes', () {
      DggVote dggVote =
          DggVote.fromString("/vote 45s Question here? option1 or option2");

      expect(dggVote.voteCount[0], 0);
      expect(dggVote.voteCount[1], 0);

      dggVote.castVote("Name", 1, []);

      expect(dggVote.voteCount[0], 1);
      expect(dggVote.voteCount[1], 0);

      dggVote.castVote("Other", 2, []);

      expect(dggVote.voteCount[0], 1);
      expect(dggVote.voteCount[1], 1);

      dggVote.castVote("Name", 1, []);

      expect(dggVote.voteCount[0], 1);
      expect(dggVote.voteCount[1], 1);
    });

    test('Cast vote in subvote', () {
      DggVote dggVote = DggVote.fromString(
          "/svote Question here? option1 or option2 or option3 or option4 or option5");

      expect(dggVote.voteCount[0], 0);
      expect(dggVote.voteCount[1], 0);
      expect(dggVote.voteCount[2], 0);
      expect(dggVote.voteCount[3], 0);
      expect(dggVote.voteCount[4], 0);

      dggVote.castVote("Name1", 1, []);
      dggVote.castVote("Name2", 2, ['flair8']);
      dggVote.castVote("Name3", 3, ['flair3']);
      dggVote.castVote("Name4", 4, ['flair1']);
      dggVote.castVote("Name5", 5, ['flair13']);

      expect(dggVote.voteCount[0], 1);
      expect(dggVote.voteCount[1], 16);
      expect(dggVote.voteCount[2], 8);
      expect(dggVote.voteCount[3], 4);
      expect(dggVote.voteCount[4], 2);
    });

    test('Vote total', () {
      DggVote dggVote =
          DggVote.fromString("/vote Question here? option1 or option2");

      expect(dggVote.getTotalVotes(), 0);

      dggVote.castVote("Name1", 1, []);

      expect(dggVote.getTotalVotes(), 1);

      dggVote.castVote("Name2", 2, []);

      expect(dggVote.getTotalVotes(), 2);
    });

    test('Get winning option', () {
      DggVote dggVote =
          DggVote.fromString("/vote Question here? option1 or option2");

      dggVote.castVote("Name1", 1, []);

      expect(dggVote.getWinningOption(), "option1");
    });
  });
}
