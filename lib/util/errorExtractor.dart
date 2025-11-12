import 'dart:convert';

import 'package:http/http.dart';

extractErrorMessageFromResponse(Response response) {
  final body = jsonDecode(response.body);
  final message = body['message'];
  return message;
}

extractErrorMessageFromMessage(Object message){
  final errorMessage = message.toString().replaceFirst("Exception: ", "");
  return errorMessage;
}