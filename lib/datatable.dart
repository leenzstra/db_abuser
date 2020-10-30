import 'package:flutter/material.dart';

class DatabaseTable extends StatelessWidget {
  const DatabaseTable(this.data, this.query, {Key key}) : super(key: key);

  final Map data;
  final String query;

  bool check() {
    print("CHECK: $data");
    if (data["error"] != "OK") {
      return false;
    }
    return true;
  }

  bool checkQueryAccepted() {
    if (data['error'] == "OK" || data['error'] == "empty-table-error") {
      return true;
    }
    return false;
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
                child: Text(e.toString()),
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
                Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 25,
                ),
                Text(query),
                Table(
                    border: TableBorder.all(color: Colors.red),
                    children: buildTable(data["data"])),
              ],
            )
          : Column(
              children: [
                Icon(
                  checkQueryAccepted() == true
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color:
                      checkQueryAccepted() == true ? Colors.green : Colors.red,
                  size: 25,
                ),
                Text(
                  checkQueryAccepted() == true
                      ? "Запрос выполнен. Получена пустая таблица"
                      : "Запрос не выполнен: ${data['error']}",
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
