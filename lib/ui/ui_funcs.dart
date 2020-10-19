import 'package:flutter/material.dart';
import 'package:db_abuser/funcs.dart' as funcs;

List getFieldsText(List fields, List types) {
  int c = -1;
  List<Widget> widgets = [
    Text(
      "Поля таблицы: ",
      style: TextStyle(fontWeight: FontWeight.bold),
    )
  ];
  fields.forEach((field) {
    c++;
    widgets.add(Text("$field - ${types[c]}"));
  });
  return widgets;
}

Future<Map<String, List>> getFieldsAndTypes(String table) async {
  var tmp = await funcs.getFields(tableName: table);
  print(tmp);
  List fields = tmp["data"];
  tmp = await funcs.getTypes(tableName: table);
  List types = tmp["data"];
  Map<String, List> m = {"fields": fields, "types": types};
  return m;
}
