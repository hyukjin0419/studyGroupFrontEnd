import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:study_group_front_end/service/Auth/token_manager.dart';

abstract class BaseApiService {
  final String _baseUrl = 'http://localhost:8080';


  Future<http.Response> get(String path, {bool authRequired = true}) async {
    return await _requestWithRetry(() async {
      final headers = await _buildHeaders(authRequired);
      return await http.get(Uri.parse('$_baseUrl$path'), headers: headers);
    });
  }

  Future<http.Response> post(String path, dynamic body, {bool authRequired = true}) async {
    return await _requestWithRetry(() async {
      final headers = await _buildHeaders(authRequired);
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
      return await http.delete(Uri.parse("$_baseUrl$path"), headers: headers)
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
        final retryHeaders = await _buildHeaders(true);
        response = await request();
      } else {
        await TokenManager.clearTokens();
      }
    }
    return response;
  }

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await TokenManager.getRefreshTokne();
    if (refreshToken == null) return false;

    final response = await http.post(
      Uri.parse('$_baseUrl/reissue/access_token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final newAccessToken = json['accessToken'];
      final newRefreshToken = json.containsKey('refreshToken') ? json['refreshToken'] : refreshToken;

      await TokenManager.setTokens(newAccessToken, newRefreshToken);
      return true;
    }

    await TokenManager.clearTokens();
    return true;
  }
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  
  




// BaseApiService({
//   required this.baseUrl,
//   http.Client? client,
// }) : httpClient = client ?? http.Client();
//
// Uri uri(String basePath, String endpoint) => Uri.parse('$baseUrl$basePath$endpoint');
//
// dynamic decodeJson(http.Response response) {
//   return jsonDecode(utf8.decode(response.bodyBytes));
// } {
}
