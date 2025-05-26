import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:study_group_front_end/providers/member_provider.dart';
import 'package:study_group_front_end/models/member.dart';

class MemberTestScreen extends StatelessWidget {
  const MemberTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memberProvider = context.watch<MemberProvider>();

    return Scaffold(
      appBar: AppBar(title: Text("멤버 테스트")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              await memberProvider.create(MemberCreateReqDto(
                userName: 'hyukjin',
                password: '1234',
                email: "redtruth0419@gmail.com"
              ));
              print("생성 완료: ${memberProvider.currentMember?.userName}");
            },
            child: Text("멤버 생성"),
          ),
          ElevatedButton(
            onPressed: () async {
              await memberProvider.login(MemberLoginReqDto(
                userName: 'hyukjin',
                password: '1234',
              ));
              print("로그인 완료: ${memberProvider.currentMember?.userName}");
            },
            child: Text("로그인"),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await memberProvider.getMemberById(4);
              print("ID 1번 멤버 이름: ${result.userName}");
            },
            child: Text("ID로 멤버 조회"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: memberProvider.memberList.length,
              itemBuilder: (_, index) {
                final member = memberProvider.memberList[index];
                return ListTile(
                  title: Text(member.userName),
                );
              },
            ),
          ),

        ],
      ),
    );
  }
}
