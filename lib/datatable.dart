import 'package:flutter/material.dart';

class DatabaseTable extends StatelessWidget {
  const DatabaseTable(this.data, this.query, {Key key}) : super(key: key);

  final Map data;
  final String query;

  check() {
    if (data["error"] != "OK") {
      return false;
    }
    return true;
  }

  List<TableRow> buildTable(List listdata) {
    List usedFields = [];
    (listdata[0] as Map).forEach((key, value) {
      usedFields.add(key);
    });
    List<Widget> headers = usedFields
        .map((field) => Padding(
              padding: const EdgeInsets.all(5.0),
              child: Text(
                field,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ))
        .toList();
    List<List> rowsList = [headers];
    List<TableRow> tableRows = [];
    for (int i = 0; i < listdata.length; i++) {
      List row = [];
      List<Widget> rowsText = [];
      for (var field in usedFields) {
        row.add(listdata[i][field]);
      }
      rowsText.addAll(row
          .map((e) => Padding(
                padding: const EdgeInsets.all(5.0),
                child: Text(e),
              ))
          .toList());
      rowsList.add(rowsText);
    }
    tableRows = rowsList.map((e) => TableRow(children: e)).toList();

    return tableRows;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: check()
          ? Column(
              children: [
                Text(query),
                Table(
                    border: TableBorder.all(color: Colors.red),
                    children: buildTable(data["data"])),
              ],
            )
          : Column(
              children: [
                Text(
                  "Не удалось построить таблицу: ${data['error']}",
                  style: TextStyle(fontSize: 30),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(query),
                ),
              ],
            ),
    );
  }
}
