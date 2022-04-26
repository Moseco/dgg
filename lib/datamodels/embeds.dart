import 'dart:convert';

class Embeds {
  final List<Embed> embedsList;

  const Embeds({
    required this.embedsList,
  });

  static Embeds fromJson(String jsonString) {
    var list = jsonDecode(jsonString) as List;

    List<Embed> embeds =  list.map((embed) => Embed.fromJson(embed)).toList();

    return Embeds(embedsList: embeds);
  }
}

class Embed {
  final String link;
  final String platform;
  final String channel;
  final String title;
  final int count;

  Embed({
    required this.link,
    required this.platform,
    required this.channel,
    required this.title,
    required this.count,
  });

  static Embed fromJson(dynamic json){
    return Embed(
    link: json['link'] as String,
    platform: json['platform'] as String,
    channel: json['channel'] as String,
    title: json['title'] as String,
    count: json['count'] as int,
    );
  }
}
