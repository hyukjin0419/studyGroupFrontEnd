import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';


class StudyJoinCodeToQrDialog extends StatelessWidget {
  final String joinCode;

  const StudyJoinCodeToQrDialog({super.key, required this.joinCode});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("스터디 초대 QR 코드"),
      content: SizedBox(
        width:240,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QrImageView(
            data: joinCode,
            version: QrVersions.auto,
            size: 200,
          ),
          const SizedBox(height: 16),
          // SelectableText(
          //   joinCode,
          //   style: const TextStyle(fontSize: 16),
          // )
        ],
      ),
      ),
    );
  }
}