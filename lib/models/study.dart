import 'package:study_group_front_end/models/study_member.dart';

import 'member.dart';

class Study {
  final int id;
  final String name;
  final String description;
  final int leaderId;
  final List<StudyMember> members;

  Study({
    required this.id,
    required this.name,
    required this.description,
    required this.leaderId,
    required this.members,
  });

  factory Study.fromJson(Map<String, dynamic> json){
    return Study(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      leaderId: json['leaderId'],
      members: (json['members'] as List<dynamic>)
        .map((e) => StudyMember.fromJson(e))
        .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'leaderId': leaderId,
      'members': members.map ((e) => e.toJson()).toList(),
    };
  }
}
