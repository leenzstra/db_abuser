import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/pages/success_page.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:db_abuser/ui/ui_funcs.dart' as ui_funcs;
import 'package:db_abuser/funcs.dart' as funcs;
import 'package:intl/intl.dart';

class InsertIntoPage extends StatefulWidget {
  InsertIntoPage({Key key}) : super(key: key);

  @override
  _InsertIntoPageState createState() => _InsertIntoPageState();
}

class _InsertIntoPageState extends State<InsertIntoPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String table;
  bool isSelected = false;

  List fields;
  List types;

  buildQuery(Map val) {
    String q = "INSERT INTO `$table` (";
    List fieldsList = [];
    List valuesList = [];
    List typesList = [];
    print(val);
    int tmpCounter = 0;
    val.forEach((key, value) {
      if (value != '') {
        fieldsList.add(key);
        valuesList.add(value);
        typesList.add(types[tmpCounter]);
      }
      tmpCounter++;
    });
    for (int i = 0; i < valuesList.length; i++) {
      q += "`${fieldsList[i]}`";
      if (i != valuesList.length - 1) {
        q += ', ';
      }
    }
    q += ") VALUES (";
    for (int i = 0; i < valuesList.length; i++) {
      if (funcs.checkFieldIsNum(typesList[i])) {
        q += "${valuesList[i]}";
      } else if (funcs.checkFieldIsDate(typesList[i])) {
        q += "'" + (valuesList[i].toString()).substring(0, 10) + "'";
      } else if (RegExp('null', caseSensitive: false)
          .hasMatch(valuesList[i].toString())) {
        q += 'null';
      } else {
        q += "'${valuesList[i]}'";
      }

      if (i != valuesList.length - 1) {
        q += ', ';
      }
    }
    q += ');';
    print(q);
    return q;
  }

  buildTablesField(List<String> list) {
    return DBContainer(
      child: FormBuilderDropdown(
        onChanged: (value) {
          table = value;
        },
        attribute: "table",
        decoration: InputDecoration(labelText: "Таблица"),
        hint: Text('Выберите таблицу'),
        validators: [FormBuilderValidators.required()],
        onSaved: (newValue) => table = newValue,
        items: list
            .map((tab) => DropdownMenuItem(value: tab, child: Text("$tab")))
            .toList(),
      ),
    );
  }

  List<Widget> buildFields(List fields, List types) {
    int c = -1;
    List<Widget> w = fields.map((field) {
      c++;
      return DBContainer(
          child: funcs.checkFieldIsDate(types[c].toString())
              ? FormBuilderDateTimePicker(
                  timePicker: (context) {
                    return null;
                  },
                  format: DateFormat("yyyy-MM-dd"),
                  attribute: field,
                  decoration:
                      InputDecoration(labelText: "$field - ${types[c]}"))
              : FormBuilderTextField(
                  attribute: field,
                  validators: funcs.checkFieldIsNum(types[c].toString())
                      ? [FormBuilderValidators.numeric()]
                      : [],
                  decoration:
                      InputDecoration(labelText: "$field - ${types[c]}")));
    }).toList();

    return w;
  }

  buildColumn(List<Widget> w) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: w,
    );
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
                  DButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Text("Меню")),
                  Center(
                    child: Column(
                      children: [
                        FutureBuilder(
                          future: funcs.getTables(),
                          builder: (context, AsyncSnapshot<Map> snapshot) {
                            List<Widget> children;
                            if (snapshot.hasData) {
                              children = [
                                buildTablesField(snapshot.data["data"]),
                                DButton(
                                    onPressed: () async {
                                      Map<String, List> m = await ui_funcs
                                          .getFieldsAndTypes(table);
                                      fields = m["fields"];
                                      types = m["types"];
                                      setState(() {
                                        isSelected = true;
                                      });
                                    },
                                    child: Text("Выбрать")),
                              ];
                            } else {
                              children = <Widget>[
                                SizedBox(
                                  child: CircularProgressIndicator(),
                                  width: 60,
                                  height: 60,
                                ),
                                const Padding(
                                  padding: EdgeInsets.only(top: 16),
                                  child: Text('Получение таблиц...'),
                                )
                              ];
                            }
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: children,
                              ),
                            );
                          },
                        ),
                        FormBuilder(
                          key: _formKey,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          child: Column(
                              children: isSelected
                                  ? [
                                      buildColumn(buildFields(fields, types)),
                                      DButton(
                                          onPressed: () async {
                                            if (!_formKey.currentState
                                                .validate()) {
                                              return;
                                            }
                                            _formKey.currentState.save();
                                            String query = buildQuery(
                                                _formKey.currentState.value);
                                            String res = await funcs
                                                .insertIntoTable(query: query);
                                            Navigator.of(context)
                                                .pushReplacement(
                                                    new MaterialPageRoute(
                                                        builder: (context) =>
                                                            SuccessPage(
                                                                query: query,
                                                                resultText:
                                                                    res)));
                                          },
                                          child: Text('Добавить'))
                                    ]
                                  : [Container()]),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
