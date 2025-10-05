import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final _storage = FlutterSecureStorage();

  static Future<void> clearTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
  }

  static Future<String?> getFcmToken() =>
      _storage.read(key: 'fcmToken');

  static Future<void> setFcmToken(String fcmToken) async {
    await _storage.write(key: 'fcmToken', value: fcmToken);
  }

  static Future<void> clearFcmToken() async {
    await _storage.delete(key: 'fcmToken');
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: 'accessToken');

  static Future<String?> getRefreshToken() =>
      _storage.read(key: 'refreshToken');

  static Future<void> setTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
  }
}
