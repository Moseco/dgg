import 'dart:convert';

import 'package:flutter/widgets.dart';

class Emotes {
  final Map<String, Emote> emoteMap;
  final RegExp emoteRegex;

  const Emotes({
    this.emoteMap,
    this.emoteRegex,
  });

  static Emotes fromJson(String jsonString) {
    List<dynamic> json = jsonDecode(jsonString);

    Map<String, Emote> emoteMap = Map();
    StringBuffer stringBuffer = StringBuffer();

    json.forEach((element) {
      emoteMap[element['prefix']] = Emote(
        name: element['prefix'],
        url: element['image'][0]['url'],
        mime: element['image'][0]['mime'],
      );
    });

    if (emoteMap.length > 0) {
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
}

class Emote {
  final String name;
  final String url;
  final String mime;
  bool animated;
  int width;
  bool loading;
  Image image;

  Emote({
    this.name,
    this.url,
    this.mime,
    this.animated = false,
    this.width,
    this.loading = false,
    this.image,
  });
}
