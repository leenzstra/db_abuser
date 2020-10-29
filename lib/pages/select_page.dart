import 'package:db_abuser/datatable.dart';
import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:db_abuser/ui/ui_funcs.dart' as ui_funcs;
import 'package:db_abuser/funcs.dart' as funcs;

class SelectPage extends StatefulWidget {
  SelectPage(this.db, {Key key}) : super(key: key);
  final String db;
  @override
  _SelectPageState createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  final _autoFormKey = GlobalKey<FormBuilderState>();
  final _manualKey = GlobalKey<FormBuilderState>();
  String table;
  List fields;
  List types;
  bool isSelected = false;
  DatabaseTable dbTable;

  buildQuery(Map values) {
    print(values);
    String q = "SELECT ";
    q += values["fields"] + ' FROM $table';
    if (values['where'] != '') {
      q += " WHERE " + values['where'];
    }
    print(q);
    return q;
  }

  Widget buildTablesField(List<String> list, List<String> views) {
    return DBContainer(
      child: FormBuilderDropdown(
        onChanged: (value) async {
          table = value;
          Map m = await ui_funcs.getFieldsAndTypes(table, widget.db);
          fields = m["fields"];
          types = m["types"];
          setState(() {
            isSelected = true;
          });
        },
        attribute: "table",
        decoration: InputDecoration(labelText: "Таблица"),
        hint: Text('Выберите таблицу'),
        validators: [FormBuilderValidators.required()],
        items: list
            .map((tab) => DropdownMenuItem(
                value: tab,
                child: views.contains(tab)
                    ? RichText(
                        text: TextSpan(
                          text: '[VIEW] ',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.white54),
                          children: <TextSpan>[
                            TextSpan(
                              text: '$tab',
                              style: TextStyle(
                                  fontStyle: FontStyle.normal,
                                  color: Colors.white),
                            )
                          ],
                        ),
                      )
                    : Text("$tab")))
            .toList(),
      ),
    );
  }

  Widget buildField(String attribute, String label, String init,
      {double width = 300}) {
    return DBContainer(
        width: width,
        child: FormBuilderTextField(
            initialValue: init,
            attribute: attribute,
            decoration: InputDecoration(labelText: label)));
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                      alignment: Alignment.topRight,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: isSelected
                              ? ui_funcs.getFieldsText(fields, types)
                              : [])),
                ),
                DButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text("Меню")),
                Center(
                  child: Column(
                    children: [
                      FormBuilder(
                        key: _autoFormKey,
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: funcs.getTables(widget.db),
                              builder: (context, AsyncSnapshot<Map> snapshot) {
                                List<Widget> children;
                                if (snapshot.hasData) {
                                  children = [
                                    buildTablesField(snapshot.data["data"],
                                        snapshot.data["views"]),
                                  ];
                                } else if (snapshot.hasError) {
                                  children = <Widget>[
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 60,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 16),
                                      child: Text('Error: ${snapshot.error}'),
                                    )
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: children,
                                  ),
                                );
                              },
                            ),
                            buildField(
                                'fields', 'Поля', 'поле1, поле2, поле3 или *'),
                            buildField('where', 'Условие', "Поле = 'Значение'"),
                            DButton(
                                onPressed: () async {
                                  if (!_autoFormKey.currentState.validate()) {
                                    return;
                                  }
                                  _autoFormKey.currentState.save();
                                  String query = buildQuery(
                                      _autoFormKey.currentState.value);
                                  Map<String, dynamic> data =
                                      await funcs.selectTable(table,
                                          query: query, db: widget.db);
                                  setState(() {
                                    dbTable = new DatabaseTable(data, query);
                                  });
                                },
                                child: Text(
                                  'Запрос',
                                  textAlign: TextAlign.center,
                                )),
                          ],
                        ),
                      ),
                      FormBuilder(
                          key: _manualKey,
                          child: Column(
                            children: [
                              Divider(
                                height: 50,
                              ),
                              buildField('manual', 'Ручной запрос',
                                  "SELECT * FROM `Таблица` WHERE Условие",
                                  width: 800),
                              DButton(
                                  onPressed: () async {
                                    if (!_manualKey.currentState.validate()) {
                                      return;
                                    }
                                    _manualKey.currentState.save();
                                    String query =
                                        _manualKey.currentState.value['manual'];
                                    print(query);
                                    Map<String, dynamic> data =
                                        await funcs.selectTableManual(
                                            query: query, db: widget.db);
                                    setState(() {
                                      dbTable = new DatabaseTable(data, query);
                                    });
                                  },
                                  child: Text(
                                    'Ручной запрос',
                                    textAlign: TextAlign.center,
                                  )),
                            ],
                          )),
                      dbTable == null
                          ? Container(
                              height: 5,
                            )
                          : dbTable
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      )),
    );
  }
}
