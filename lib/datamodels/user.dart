class User {
  final String nick;
  final List<String> features;

  User({
    this.nick,
    this.features,
  });

  static User fromJson(Map<String, dynamic> json) {
    return User(
      nick: json['nick'] as String,
      features: json['features']?.cast<String>(),
    );
  }
}
