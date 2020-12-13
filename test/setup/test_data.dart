class TestData {
  static const String WS_NAMES_STRING =
      '{"connectioncount":3, "users":[{"nick":"NameExample","features":[]},{"nick":"OtherName","features":["subscriber","flair3"]},{"nick":"ThirdPerson","features":["subscriber","flair13","flair16"]}]}';
  static const String WS_MSG_NO_FLAIR_STRING =
      '{"nick":"Name","features":[],"timestamp":1601298692406,"data":"This is the text"}';
  static const String WS_MSG_WITH_FLAIR_STRING =
      '{"nick":"Name","features":[],"timestamp":1601298692406,"data":"This is the text"}';
  static const String WS_JOIN_STRING =
      '{"nick":"ExampleName","features":["subscriber","flair9"],"timestamp":1601349648811,"data":"This is the words"}';
  static const String WS_QUIT_STRING =
      '{"nick":"ExampleName","features":[],"timestamp":1601298690412}';
  static const String WS_MUTE_STRING =
      '{"nick":"Bot","features":["protected","bot"],"timestamp":1601350699134,"data":"ExampleName","duration":21600}';
  static const String WS_BROADCAST_STRING =
      '{"timestamp":1601770450767,"data":"NAME has resubscribed on Twitch!"}';
  static const String WS_BAN_STRING =
      '{"nick":"Bot","features":["protected","bot"],"timestamp":1602119628328,"data":"ExampleName"}';
  static const String WS_UNBAN_STRING =
      '{"nick":"Bot","features":["protected","bot"],"timestamp":1602119995995,"data":"ExampleName"}';
  static const String WS_REFRESH_STRING =
      '{"nick":"ExampleName","features":[],"timestamp":1606624740677}';
  static const String WS_ERR_DUPLICATE = '{"description":"duplicate"}';

  static const String EMOTE_STRING =
      '[{"prefix":"EMOTE","image":[{"url":"example.com/EMOTE"}]},{"prefix":"EMOTE2","image":[{"url":"example.com/EMOTE2"}]},{"prefix":"oooo","image":[{"url":"example.com/oooo"}]}]';
}
