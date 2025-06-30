import 'package:study_group_front_end/dto/base_res_dto.dart';

class MemberDeleteResponse {
  final String message;

  MemberDeleteResponse({required this.message});

  factory MemberDeleteResponse.fromJson(Map<String, dynamic> json) {
    return MemberDeleteResponse(
      message: json['message'],
    );
  }
}