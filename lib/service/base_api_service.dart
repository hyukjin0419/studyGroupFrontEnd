import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BaseApiService {
  final String baseUrl = 'http://localhost:8080';


  Future<http.Response> get(String path, {bool authRequired = true}) async {
    return await _requestWithRetry(() async {
      final headers = await _buildHeaders(authRequired);
      return await http.get(Uri.parse('$_baseUrl$path'), headers: headers);
    });
  }

  Future<http.Response> post()

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
