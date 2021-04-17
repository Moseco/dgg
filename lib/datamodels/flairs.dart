import 'dart:convert';

class Flairs {
  final List<Flair> flairs;

  const Flairs(this.flairs);

  static Flairs fromJson(String jsonString) {
    List<dynamic> json = jsonDecode(jsonString);

    List<Flair> flairs = [];
    json.forEach((map) {
      Flair? flair = Flair.fromJson(map);
      if (flair != null) {
        flairs.add(flair);
      }
    });
    return Flairs(flairs);
  }
}

class Flair {
  final String name;
  final int priority;
  final int? color;
  final String? url;

  const Flair(
    this.name,
    this.priority,
    this.color,
    this.url,
  );

  static Flair? fromJson(Map<String, dynamic> map) {
    if (map.containsKey('name') && map.containsKey('priority')) {
      return Flair(
        map['name'],
        map["priority"],
        (map['color']?.length ?? 0) == 0
            ? null
            : int.parse('FF' + map['color']?.substring(1), radix: 16),
        (map['hidden'] ?? true) ? null : map['image'][0]['url'],
      );
    } else {
      return null;
    }
  }
}
