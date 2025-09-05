import 'package:flutter/material.dart';

class DropDownIcon extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      width: 23,
      child: FittedBox(
        fit: BoxFit.fill,
        child: Icon(
          Icons.arrow_drop_down,
          color: Colors.black,
          size: 1,
        ),
      ),
    );
  }
}
