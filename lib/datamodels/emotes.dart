import 'dart:convert';

import 'package:flutter/widgets.dart';

class Emotes {
  final Map<String, Emote> emoteMap;
  final RegExp emoteRegex;

  const Emotes({
    required this.emoteMap,
    required this.emoteRegex,
  });

  static Emotes fromJson(String jsonString) {
    List<dynamic> emoteList = jsonDecode(jsonString);

    Map<String, Emote> emoteMap = {};
    StringBuffer stringBuffer = StringBuffer();

    for (var map in emoteList) {
      Emote? emote = Emote.fromMap(map);
      if (emote != null) {
        emoteMap[emote.name] = emote;
      }
    }

    if (emoteMap.isNotEmpty) {
      List<String> keyList = emoteMap.keys.toList();

      for (int i = 0; i < keyList.length - 1; i++) {
        stringBuffer.write("\\b");
        stringBuffer.write(keyList[i]);
        stringBuffer.write("\\b|");
      }

      stringBuffer.write("\\b");
      stringBuffer.write(keyList.last);
      stringBuffer.write("\\b");
    }

    return Emotes(
      emoteMap: emoteMap,
      emoteRegex: RegExp(stringBuffer.toString()),
    );
  }

  factory Emotes.empty() {
    return Emotes(emoteMap: {}, emoteRegex: RegExp(''));
  }
}

class Emote {
  final String name;
  final String url;
  final String mime;
  int width;
  bool needsCutting;
  bool animated;
  bool loading;
  Image? image;
  List<Image>? frames;
  int? duration;
  int? repeatCount;

  Emote({
    required this.name,
    required this.url,
    required this.mime,
    required this.width,
    this.needsCutting = false,
    this.animated = false,
    this.loading = false,
    this.image,
    this.frames,
    this.duration,
    this.repeatCount,
  });

  static Emote? fromMap(Map<String, dynamic> map) {
    if (map.containsKey("prefix") && map.containsKey("image")) {
      Map<String, dynamic> imageMap = map["image"][0];
      if (imageMap.containsKey("url") &&
          imageMap.containsKey("mime") &&
          imageMap.containsKey("width")) {
        return Emote(
          name: map['prefix'],
          url: imageMap['url'],
          mime: imageMap['mime'],
          width: imageMap['width'],
        );
      }
    }
    return null;
  }
}
