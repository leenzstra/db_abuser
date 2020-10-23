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

Future<Map<String, List>> getFieldsAndTypes(String table, String db) async {
  var tmp = await funcs.getFields(tableName: table, db: db);
  print(tmp);
  List fields = tmp["data"];
  tmp = await funcs.getTypes(tableName: table, db: db);
  List types = tmp["data"];
  Map<String, List> m = {"fields": fields, "types": types};
  return m;
}
