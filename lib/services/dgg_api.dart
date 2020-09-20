import 'dart:io';

import 'package:dgg/datamodels/auth_info.dart';
import 'package:dgg/datamodels/session_info.dart';
import 'package:injectable/injectable.dart';
import 'package:dgg/app/locator.dart';
import 'package:dgg/services/shared_preferences_service.dart';

import 'package:http/http.dart' as http;

@lazySingleton
class DggApi {
  static const String sessionInfoUrl = "https://www.destiny.gg/api/chat/me";

  final _sharedPreferencesService = locator<SharedPreferencesService>();

  AuthInfo _authInfo;

  Future<SessionInfo> getSessionInfo() async {
    _authInfo = await _sharedPreferencesService.getAuthInfo();

    if (_authInfo == null) {
      return Unavailable();
    }

    final response = await http.get(
      sessionInfoUrl,
      headers: _authInfo != null
          ? {HttpHeaders.cookieHeader: _authInfo.toHeaderString()}
          : null,
    );

    if (response.statusCode == 200) {
      return Available.fromJson(response.body);
    } else {
      return Unavailable(httpStatusCode: response.statusCode);
    }
  }
}
