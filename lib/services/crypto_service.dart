import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CryptoService {
  static const String _charset =
      'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

  String generateRandomString(int length) {
    return List.generate(
            length, (i) => _charset[Random.secure().nextInt(_charset.length)])
        .join();
  }

  String generateCodeChallenge(String secret, String codeVerifier) {
    //First hash the secret
    List<int> secretHash =
        utf8.encode(sha256.convert(utf8.encode(secret)).toString());
    //Then hash codeVerifier + hashed secret
    Digest digest = sha256.convert(utf8.encode(codeVerifier) + secretHash);
    //Encode to base64 and return
    return base64.encode(utf8.encode(digest.toString()));
  }
}
