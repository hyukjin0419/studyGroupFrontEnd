import 'package:study_group_front_end/dto/base_res_dto.dart';

class MemberLoginRequest{
  final String userName;
  final String password;

  MemberLoginRequest({
    required this.userName,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
  };
}