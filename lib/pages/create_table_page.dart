import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/pages/success_page.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:db_abuser/ui/ui_funcs.dart' as ui_funcs;
import 'package:db_abuser/funcs.dart' as funcs;

class CreateTablePage extends StatefulWidget {
  CreateTablePage({Key key}) : super(key: key);

  @override
  _CreateTablePageState createState() => _CreateTablePageState();
}

class _CreateTablePageState extends State<CreateTablePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final _createKey = GlobalKey<FormBuilderState>();
  String table;
  int count;

  List<String> typeList = ["INT", "VARCHAR", "TEXT", "DATE"];

  String buildQuery(Map m) {
    print(m);
    String query = "CREATE TABLE `$table` (";
    for (int i = 0; i < count; i++) {
      query += "`" + m['fieldName$i'] + "` " + m["fieldType$i"];
      if (m["fieldSize$i"] != '') {
        query += "(" + m["fieldSize$i"] + ")";
      }
      if (m["fieldNull$i"] == true) {
        query += " NULL";
      } else {
        query += " NOT NULL";
      }
      if (m["fieldA_i$i"] == true) {
        query += " PRIMARY KEY AUTO_INCREMENT";
      }
      if (i != count - 1) {
        query += ', ';
      }
    }
    query += ');';
    print(query);
    return query;
  }

  List<Widget> buildField(String attr, String label, bool isNum, bool isReq) {
    List<String Function(dynamic)> validators = [];
    if (isNum) {
      validators.add(FormBuilderValidators.numeric());
    }
    if (isReq) {
      validators.add(FormBuilderValidators.required());
    }
    List<Widget> list = [];
    for (int i = 0; i < count; i++) {
      Widget w = DBContainer(
          width: 200,
          child: FormBuilderTextField(
              validators: validators,
              attribute: "$attr$i",
              decoration: InputDecoration(labelText: "$label ${i + 1}")));
      list.add(w);
    }
    return list;
  }

  buildFieldCheckbox(String attr, String label) {
    List<Widget> list = [];
    for (int i = 0; i < count; i++) {
      Widget w = DBContainer(
          width: 150,
          child: FormBuilderCheckbox(
            initialValue: false,
            label: Text(label),
            attribute: "$attr$i",
          ));
      list.add(w);
    }
    return list;
  }

  buildFieldDropdown(String attr, String label, bool isReq, List<String> data) {
    List<String Function(dynamic)> validators = [];
    if (isReq) {
      validators.add(FormBuilderValidators.required());
    }
    List<Widget> list = [];
    for (int i = 0; i < count; i++) {
      Widget w = DBContainer(
        width: 200,
        child: FormBuilderDropdown(
          attribute: "$attr$i",
          decoration: InputDecoration(labelText: label),
          validators: validators,
          items: data
              .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
              .toList(),
        ),
      );
      list.add(w);
    }

    return list;
  }

  buildListOfRows() {
    List<Widget> names = buildField('fieldName', 'Название поля', false, true);
    List<Widget> types =
        buildFieldDropdown('fieldType', "Тип поля", true, typeList);
    List<Widget> sizes = buildField('fieldSize', 'Размер типа', true, false);
    List<Widget> nulls = buildFieldCheckbox('fieldNull', 'NULL');
    List<Widget> ais = buildFieldCheckbox('fieldA_i', 'A_I');
    List<Row> rows = [];
    for (int i = 0; i < count; i++) {
      Row r = new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [names[i], types[i], sizes[i], nulls[i], ais[i]],
      );
      rows.add(r);
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        FormBuilder(
                          key: _formKey,
                          child: Column(
                            children: [
                              DBContainer(
                                child: FormBuilderTextField(
                                  attribute: "table_name",
                                  validators: [
                                    FormBuilderValidators.required()
                                  ],
                                  decoration: InputDecoration(
                                      labelText: "Название таблицы"),
                                  onSaved: (val) => table = val,
                                ),
                              ),
                              DBContainer(
                                child: FormBuilderTextField(
                                  validators: [
                                    FormBuilderValidators.numeric(),
                                    FormBuilderValidators.required(),
                                    FormBuilderValidators.min(1,
                                        errorText: "Min = 1"),
                                    FormBuilderValidators.max(50,
                                        errorText: "Max = 50"),
                                  ],
                                  attribute: "count",
                                  decoration: InputDecoration(
                                      labelText: "Кол-во полей"),
                                  onSaved: (val) => count = int.parse(val),
                                ),
                              ),
                            ],
                          ),
                        ),
                        DButton(
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            }
                            _formKey.currentState.save();
                            setState(() {});
                            print(_formKey.currentState.value);
                          },
                          child: Text("Далее"),
                        ),
                        count != null
                            ? Column(
                                children: [
                                  FormBuilder(
                                    key: _createKey,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: buildListOfRows(),
                                    ),
                                  ),
                                  DButton(
                                    onPressed: () async {
                                      if (!_createKey.currentState.validate()) {
                                        return;
                                      }
                                      _createKey.currentState.save();
                                      String query = buildQuery(
                                          _createKey.currentState.value);
                                      String res =
                                          await funcs.createTable(query: query);
                                      Navigator.of(context).pushReplacement(
                                          new MaterialPageRoute(
                                        builder: (context) => SuccessPage(
                                            query: query, resultText: res),
                                      ));
                                    },
                                    child: Text("Создать"),
                                  ),
                                ],
                              )
                            : Container(),
                      ],
                    ),
                  ),
                  DButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text("Меню")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
