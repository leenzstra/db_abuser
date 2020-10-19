import 'package:flutter/material.dart';

class DBContainer extends StatelessWidget {
  const DBContainer({Key key, this.width = 300, @required this.child})
      : super(key: key);
  final double width;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.all(8), width: width, child: child);
  }
}
