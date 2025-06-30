// import 'dart:convert';
// import 'package:study_group_front_end/dto/member/delete/member_delete_response.dart';
// import 'package:study_group_front_end/dto/member/detail/member_detail_response.dart';
// import 'package:study_group_front_end/dto/member/update/member_update_request.dart';
// import 'package:study_group_front_end/service/base_api_service.dart';
//
// //관리자용 -> 현재 사용 x
// class  MemberApiService extends BaseApiService{
//   final String basePath = '/members';
//
//   Future<MemberDetailResponse> getMemberById(int id) async {
//     final response = await get('$basePath/$id)');
//
//     if (response.statusCode == 200) {
//       return MemberDetailResponse.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('get member by id failed: ${response.statusCode}');
//     }
//   }
//
//   Future<List<MemberDetailResponse>> getAllMembers() async {
//     final response = await get(basePath);
//
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonList = jsonDecode(utf8.decode(response.bodyBytes));
//       return jsonList.map((e) => MemberDetailResponse.fromJson(e)).toList();
//     } else {
//       throw Exception('get all members failed: ${response.statusCode}');
//     }
//   }
//
//   Future<MemberDetailResponse> updateMember(int id, MemberUpdateRequest request) async {
//     final response = await post(
//       '$basePath/$id',
//       request.toJson(),
//     );
//
//     if (response.statusCode == 200) {
//       return MemberDetailResponse.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('update member failed: ${response.statusCode}');
//     }
//   }
//
//   Future<MemberDeleteResponse> deleteMember(int id) async{
//     final response = await delete('$basePath/$id');
//
//     if (response.statusCode == 200) {
//       return MemberDeleteResponse.fromJson(jsonDecode(response.body));
//     } else {
//       throw Exception('delete member failed: ${response.statusCode}');
//     }
//   }
// }
