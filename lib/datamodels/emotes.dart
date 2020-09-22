import 'dart:convert';

class Emotes {
  final Map<String, String> emoteMap;
  final RegExp emoteRegex;

  const Emotes({
    this.emoteMap,
    this.emoteRegex,
  });

  static Emotes fromJson(String jsonString) {
    List<dynamic> json = jsonDecode(jsonString);

    Map<String, String> emoteMap = Map();
    StringBuffer stringBuffer = StringBuffer();

    json.forEach((element) {
      if (element['animated'] ?? false) {
        emoteMap[element['prefix']] = element['image'][0]['fallback_url'];
      } else {
        emoteMap[element['prefix']] = element['image'][0]['url'];
      }
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
