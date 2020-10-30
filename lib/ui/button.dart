import 'package:flutter/material.dart';

class DButton extends StatelessWidget {
  const DButton(
      {Key key,
      @required this.onPressed,
      @required this.child,
      this.width = 100,
      this.height = 50})
      : super(key: key);

  final Function onPressed;
  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
          margin: const EdgeInsets.all(2.0),
          width: width,
          height: height,
          child: FlatButton(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Theme.of(context).accentColor)),
            onPressed: onPressed,
            child: child,
          )),
    );
  }
}
