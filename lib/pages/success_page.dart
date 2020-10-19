import 'package:db_abuser/ui/button.dart';
import 'package:flutter/material.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key key, @required this.query, @required this.resultText})
      : super(key: key);

  final String query;
  final String resultText;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            resultText == 'OK'
                ? Icons.check_circle_outline
                : Icons.error_outline,
            color: resultText == 'OK' ? Colors.green : Colors.red,
            size: 50,
          ),
          Text(query),
          Text(resultText),
          DButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("В меню"))
        ],
      )),
    );
  }
}
