import 'dart:convert';

import 'package:flutter/widgets.dart';

class Flairs {
  final List<Flair> flairs;
  final Map<String, Flair> flairMap;

  const Flairs(this.flairs, this.flairMap);

  static Flairs fromJson(String jsonString) {
    List<dynamic> json = jsonDecode(jsonString);

    List<Flair> flairs = [];
    Map<String, Flair> flairMap = {};
    json.forEach((map) {
      Flair? flair = Flair.fromJson(map);
      if (flair != null) {
        flairs.add(flair);
        flairMap[flair.name] = flair;
      }
    });
    return Flairs(flairs, flairMap);
  }

  factory Flairs.empty() {
    return Flairs([], {});
  }
}

class Flair {
  final String name;
  final int priority;
  final int? color;
  final String? url;
  final bool hidden;
  bool loading;
  Image? image;

  Flair({
    required this.name,
    required this.priority,
    this.color,
    this.url,
    this.hidden = true,
    this.loading = false,
    this.image,
  });

  static Flair? fromJson(Map<String, dynamic> map) {
    if (map.containsKey('name') && map.containsKey('priority')) {
      return Flair(
        name: map['name'],
        priority: map["priority"],
        color: (map['color']?.length ?? 0) == 0
            ? null
            : int.parse('FF' + map['color']?.substring(1), radix: 16),
        url: map['image']?[0]['url'],
        hidden: map['hidden'],
      );
    } else {
      return null;
    }
  }
}
