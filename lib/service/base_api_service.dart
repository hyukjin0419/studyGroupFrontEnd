import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class BaseApiService {
  final String baseUrl;
  final http.Client httpClient;

  BaseApiService({
    required this.baseUrl,
    http.Client? client,
  }) : httpClient = client ?? http.Client();

  Uri uri(String basePath, String endpoint) => Uri.parse('$baseUrl$basePath$endpoint');

  dynamic decodeJson(http.Response response) {
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
