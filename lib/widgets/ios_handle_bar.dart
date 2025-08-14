import 'package:flutter/material.dart';

class iosHandleBar extends StatelessWidget {
    @override
    Widget build(BuildContext context) {
        return Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.fromLTRB(0,6,0,29),
            decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(3),
            ),
        );
    }
}
