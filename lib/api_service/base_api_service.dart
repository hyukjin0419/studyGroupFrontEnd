import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:study_group_front_end/api_service/Auth/token_manager.dart';

abstract class BaseApiService {
  // final String _baseUrl = 'http://localhost:8080';
  final String _baseUrl = 'http://192.168.45.143:8080';
  // final String _baseUrl = 'https://studygroupbackend-production.up.railway.app';



  Future<http.Response> get(String path, {bool authRequired = true}) async {
    return await _requestWithRetry(() async {
      final headers = await _buildHeaders(authRequired);
      final uri = Uri.parse('$_baseUrl$path');

      //요청 로그
      debugPrint('[Get 요청]');
      debugPrint('URL: $uri');
      debugPrint('Headers: $headers');

      final response = await http.get(Uri.parse('$_baseUrl$path'), headers: headers);

      //응답 로그 출력
      debugPrint('[응답]');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      return response;
    });
  }

  Future<http.Response> post(String path, dynamic body, {bool authRequired = true}) async {
    return await _requestWithRetry(() async {
      final headers = await _buildHeaders(authRequired);
      final uri = Uri.parse('$_baseUrl$path');

      debugPrint('[Post 요청]');
      debugPrint('URL: $uri');
      debugPrint('Headers: $headers');

      return await http.post(
          Uri.parse('$_baseUrl$path'),
          headers: headers,
          body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> delete(String path, {bool authRequired = true}) async {
    return await _requestWithRetry(() async {
      final headers = await _buildHeaders(authRequired);
      return await http.delete(Uri.parse("$_baseUrl$path"), headers: headers);
    });
  }

  Future<Map<String, String>> _buildHeaders(bool authRequired) async {
    final headers = {'Content-Type': 'application/json'};
    if (authRequired) {
      final token = await TokenManager.getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Future<http.Response> _requestWithRetry(Future<http.Response> Function() request) async {
    http.Response response = await request();

    if (response.statusCode == 401) {
      final success = await _refreshAccessToken();
      if (success) {
        await _buildHeaders(true);
        response = await request();
      } else {
        await TokenManager.clearTokens();
      }
    }
    return response;
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await TokenManager.getRefreshToken();

    if (refreshToken == null) {
      log("refresh token 호출 실패", name: "base_api_service");
      return false;
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/reissue/access_token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final newAccessToken = json['accessToken'];

      await TokenManager.setTokens(newAccessToken, refreshToken);

      return true;
    }

    return false;
  }
}
