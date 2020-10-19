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

  List<TableRow> buildTable(List fields, List listdata) {
    List<Widget> headers = fields
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
      for (var field in fields) {
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
                    defaultColumnWidth: IntrinsicColumnWidth(flex: 0.2),
                    border: TableBorder.all(),
                    children: buildTable(data["fields"], data["data"])),
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
