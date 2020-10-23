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

Future<Map<String, dynamic>> getFields(
    {@required String tableName, @required String db}) async {
  Map<String, dynamic> data =
      await postHTTP("get_table_fields.php", "DESCRIBE `$tableName`", db: db);
  return data;
}

Future<Map<String, dynamic>> getTypes(
    {@required String tableName, @required String db}) async {
  Map data =
      await postHTTP("get_table_types.php", "DESCRIBE `$tableName`", db: db);
  return data;
}

Future<Map<String, dynamic>> getTables(String db) async {
  print("DB = $db");
  Map<String, dynamic> data =
      await postHTTP("get_table.php", "SHOW TABLES", db: db);
  Map<String, dynamic> result = new Map();
  List<String> tables = [];
  (data["data"] as List).forEach((element) {
    tables.add(element["Tables_in_$db"].toString());
  });
  result["data"] = tables;
  result["result"] = data["result"];
  return result;
}

Future<Map<String, dynamic>> getDatabases() async {
  Map<String, dynamic> data = await postHTTP("get_table.php", "SHOW DATABASES");
  Map<String, dynamic> result = new Map();
  List<String> tables = [];
  (data["data"] as List).forEach((element) {
    tables.add(element["Database"].toString());
  });
  result["data"] = tables;
  result["result"] = data["result"];
  return result;
}

Future<String> createDatabase({@required String query}) async {
  Map data = await postHTTP("nofeedback_query.php", query);
  return data["result"];
}

Future<String> createTable(
    {@required String query, @required String db}) async {
  Map data = await postHTTP("nofeedback_query.php", query, db: db);
  return data["result"];
}

Future<String> dropTable({@required String query, @required String db}) async {
  Map data = await postHTTP("nofeedback_query.php", query, db: db);
  return data["result"];
}

Future<String> alterTable({@required String query, @required String db}) async {
  Map data = await postHTTP("nofeedback_query.php", query, db: db);
  return data["result"];
}

Future<String> insertIntoTable(
    {@required String query, @required String db}) async {
  Map data = await postHTTP("nofeedback_query.php", query, db: db);
  return data["result"];
}

Future<String> deleteFromTable(
    {@required String query, @required String db}) async {
  Map data = await postHTTP("nofeedback_query.php", query, db: db);
  return data["result"];
}

Future<String> updateTable(
    {@required String query, @required String db}) async {
  Map data = await postHTTP("nofeedback_query.php", query, db: db);
  return data["result"];
}

Future<Map<String, dynamic>> selectTable(String table,
    {@required String query, @required String db}) async {
  Map<String, dynamic> data = await postHTTP("get_table.php", query, db: db);
  print(data);
  Map<String, dynamic> fields = await getFields(tableName: table, db: db);

  Map<String, dynamic> map = {
    "fields": fields["data"],
    "data": data["data"],
    "error": data["result"]
  };

  return map;
}

Future<Map<String, dynamic>> selectTableManual(
    {@required String query, @required String db}) async {
  Map<String, dynamic> data = await postHTTP("get_table.php", query, db: db);
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
