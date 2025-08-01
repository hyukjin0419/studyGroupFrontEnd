import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

Future<String?> scanQrCode(BuildContext context) async {
  String? result;
  bool _isScanned = false;

  await showDialog(
    context: context,
    builder: (context) {
      return Scaffold(
        appBar: AppBar(title: const Text("QR 스캔")),
        body: MobileScanner(
          onDetect: (capture) {
            if (_isScanned) return;
            _isScanned = true;

            final barcode = capture.barcodes.first;
            result = barcode.rawValue;

            Future.microtask(() {
              Navigator.of(context).pop();
            });
          },
        )
      );
    }
  );

  return result;
}