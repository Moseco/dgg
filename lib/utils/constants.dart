class Constants {
  static final RegExp urlRegex = RegExp(
    r"(http://|ftp://|https://)?([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:/~+#-]*[\w@?^=%&/~+#-])?",
    caseSensitive: false,
  );
  static final RegExp embedUrlRegex = RegExp(
    r"#(twitch|twitch-vod|twitch-clip|youtube)\/(?:[A-z0-9_\-]{3,64})",
    caseSensitive: false,
  );
  static final RegExp mentionRegex = RegExp(
    r"(?:(?:^|\s)@?)([a-zA-Z0-9_]{3,20})(?=$|\s|[.?!,])",
    caseSensitive: false,
  );
  static final RegExp nickRegex = RegExp(
    r"[a-zA-Z0-9_]{3,20}",
    caseSensitive: false,
  );
}
