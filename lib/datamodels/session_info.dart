import 'dart:convert';

abstract class SessionInfo {
  const SessionInfo();
}

class Available extends SessionInfo {
  final String? nick;
  final String? username;
  final String? userId;
  final String? userStatus;
  final String? createdDate;
  final String? country;
  final List<String>? roles;
  final List<String>? features;
  final Map<String, dynamic>? subscription;
  final List<String>? settings;

  const Available({
    this.nick,
    this.username,
    this.userId,
    this.userStatus,
    this.createdDate,
    this.country,
    this.roles,
    this.features,
    this.subscription,
    this.settings,
  });

  static Available fromJson(String jsonString) {
    Map<String, dynamic> json = jsonDecode(jsonString);

    return Available(
      nick: json['nick'] as String?,
      username: json['username'] as String?,
      userId: json['userId'] as String?,
      userStatus: json['userStatus'] as String?,
      createdDate: json['createdDate'] as String?,
      country: json['country'] as String?,
      roles: json['roles']?.cast<String>(),
      features: json['features']?.cast<String>(),
      subscription: json['subscription'] as Map<String, dynamic>?,
      settings: json['settings']?.cast<String>(),
    );
  }
}

class Unavailable extends SessionInfo {
  final int? httpStatusCode;
  final bool usedToken;

  const Unavailable({this.httpStatusCode, this.usedToken = false});
}

class Unauthenticated extends SessionInfo {}
