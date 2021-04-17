class DggVote {
  static final RegExp voteStartRegex =
      RegExp(r"/(vote|svote) ", caseSensitive: false);
  static final RegExp voteTimeRegex =
      RegExp(r"\b([0-9]+(?:m|s)?)", caseSensitive: false);
  static final RegExp voteOptionSplitRegex =
      RegExp(r"\bor\b", caseSensitive: false);
  static final RegExp voteStopRegex =
      RegExp(r"/votestop", caseSensitive: false);
  static final RegExp voteValidRegex = RegExp(r"\b\d+\b");

  final String question;
  final List<String> options;
  final List<int> voteCount;
  final Map<String, bool> voters;
  final int time;
  final bool isSubVote;

  const DggVote({
    required this.question,
    required this.options,
    required this.voteCount,
    required this.voters,
    this.time = 30,
    this.isSubVote = false,
  });

  static DggVote? fromString(String voteString) {
    int time = 30;
    bool isSubVote = false;

    //Check if subvote
    if (voteString[1] == 's') {
      isSubVote = true;
    }
    //Remove the command '/vote' or '/votes'
    String temp = voteString.replaceFirst(voteStartRegex, '');
    //Check if there is a vote time
    if (temp.startsWith(voteTimeRegex)) {
      String rawTime = temp.substring(0, temp.indexOf(' '));
      if (rawTime[rawTime.length - 1] == 's') {
        //units in seconds
        time = int.parse(rawTime.substring(0, rawTime.length - 1));
      } else {
        //units in minutes
        time = 60 * int.parse(rawTime.substring(0, rawTime.length - 1));
      }
      temp = temp.replaceFirst(voteTimeRegex, '');
    }

    int questionMarkIndex = temp.indexOf('?');
    if (questionMarkIndex == -1) {
      //Invalid vote, no question mark, return null
      return null;
    }
    String question = temp.substring(0, questionMarkIndex + 1).trim();
    temp = temp.substring(questionMarkIndex + 1).trim();
    List<String> options;
    List<int> voteCount;
    if (temp.length == 0) {
      //No options given, use 'yes' and 'no'
      options = ['Yes', 'No'];
      voteCount = [0, 0];
    } else {
      options = temp.split(voteOptionSplitRegex);
      for (int i = 0; i < options.length; i++) {
        options[i] = options[i].trim();
      }
      if (options.length < 2 || options.last.length == 0) {
        //Invalid vote, no 'or' to split options or last option is empty, return null
        return null;
      }
      voteCount = List.filled(options.length, 0);
    }

    return DggVote(
      question: question,
      options: options,
      voteCount: voteCount,
      voters: {},
      time: time,
      isSubVote: isSubVote,
    );
  }

  void castVote(String nick, int option, List<String> features) {
    if (!voters.containsKey(nick)) {
      //Voter has not voted, count it
      voters[nick] = true;
      if (!isSubVote) {
        //Not sub vote, all votes count as 1
        voteCount[option - 1]++;
      } else {
        //Is subvote, multiply accordinly
        voteCount[option - 1] += calculateSubVote(features);
      }
    }
  }

  int calculateSubVote(List<String> features) {
    for (int i = 0; i < features.length; i++) {
      if (features[i] == 'flair8') {
        return 16;
      }
    }
    for (int i = 0; i < features.length; i++) {
      if (features[i] == 'flair3') {
        return 8;
      }
    }
    for (int i = 0; i < features.length; i++) {
      if (features[i] == 'flair1') {
        return 4;
      }
    }
    for (int i = 0; i < features.length; i++) {
      if (features[i] == 'flair13') {
        return 2;
      }
    }
    return 1;
  }

  int getTotalVotes() {
    int total = 0;
    voteCount.forEach((element) {
      total += element;
    });
    return total;
  }

  String getWinningOption() {
    String winningOption = options[0];
    int winningCount = voteCount[0];
    for (int i = 1; i < options.length; i++) {
      if (voteCount[i] > winningCount) {
        winningOption = options[i];
        winningCount = voteCount[i];
      }
    }
    return winningOption;
  }
}
