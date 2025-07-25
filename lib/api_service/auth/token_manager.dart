import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final _storage = FlutterSecureStorage();

  static Future<String?> getAccessToken() =>
      _storage.read(key: 'accessToken');

  static Future<String?> getRefreshToken() =>
      _storage.read(key: 'refreshToken');

  static Future<void> setTokens(String accessToken, String refreshToken) async {
    log("그럼 이거 출력 되어야 하는데?");
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }
}
