import 'package:db_abuser/httphandler.dart';
import 'package:flutter/material.dart';

bool checkFieldIsNum(String type) {
  if (type.indexOf('int') == -1) {
    print('not num');
    return false;
  }
  print('num');
  return true;
}

bool checkFieldIsDate(String type) {
  if (type.indexOf(RegExp("date", caseSensitive: false)) == -1) {
    print('not date');
    return false;
  }
  print('date');
  return true;
}

Future<Map<String, dynamic>> getFields({@required String tableName}) async {
  Map<String, dynamic> data = await postHTTP(
      fileLink: "get_table_fields.php", query: "DESCRIBE `$tableName`");
  return data;
}

Future<Map<String, dynamic>> getTypes({@required String tableName}) async {
  Map data = await postHTTP(
      fileLink: "get_table_types.php", query: "DESCRIBE `$tableName`");
  return data;
}

Future<Map<String, dynamic>> getTables({String dbName = 'lab2'}) async {
  Map<String, dynamic> data =
      await postHTTP(fileLink: "get_table.php", query: "SHOW TABLES");
  Map<String, dynamic> result = new Map();
  List<String> tables = [];
  (data["data"] as List).forEach((element) {
    tables.add(element["Tables_in_$dbName"].toString());
  });
  result["data"] = tables;
  result["result"] = data["result"];
  return result;
}

Future<String> createTable({@required String query}) async {
  Map data = await postHTTP(fileLink: "nofeedback_query.php", query: query);
  return data["result"];
}

Future<String> dropTable({@required String query}) async {
  Map data = await postHTTP(fileLink: "nofeedback_query.php", query: query);
  return data["result"];
}

Future<String> alterTable({@required String query}) async {
  Map data = await postHTTP(fileLink: "nofeedback_query.php", query: query);
  return data["result"];
}

Future<String> insertIntoTable({@required String query}) async {
  Map data = await postHTTP(fileLink: "nofeedback_query.php", query: query);
  return data["result"];
}

Future<String> deleteFromTable({@required String query}) async {
  Map data = await postHTTP(fileLink: "nofeedback_query.php", query: query);
  return data["result"];
}

Future<String> updateTable({@required String query}) async {
  Map data = await postHTTP(fileLink: "nofeedback_query.php", query: query);
  return data["result"];
}

Future<Map<String, dynamic>> selectTable(
  String table, {
  @required String query,
}) async {
  Map<String, dynamic> data =
      await postHTTP(fileLink: "get_table.php", query: query);
  Map<String, dynamic> fields = await getFields(tableName: table);

  Map<String, dynamic> map = {
    "fields": fields["data"],
    "data": data["data"],
    "error": data["result"]
  };
  return map;
}

Future<Map<String, dynamic>> selectTableManual({
  @required String query,
}) async {
  Map<String, dynamic> data =
      await postHTTP(fileLink: "get_table.php", query: query);
  List fields = [];
  if (data["result"] == "OK") {
    (data["data"][0] as Map).forEach((key, value) {
      fields.add(key);
    });
  }
  Map<String, dynamic> map = {
    "fields": fields,
    "data": data["data"],
    "error": data["result"]
  };
  return map;
}
