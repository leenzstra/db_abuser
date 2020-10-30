import 'package:db_abuser/datatable.dart';
import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:db_abuser/funcs.dart';
import 'package:intl/intl.dart';

class ProceduresPage extends StatefulWidget {
  ProceduresPage(this.db, {Key key}) : super(key: key);
  final String db;
  @override
  _ProceduresPageState createState() => _ProceduresPageState();
}

class _ProceduresPageState extends State<ProceduresPage> {
  String procedureName;
  List paramsNames;
  List paramsTypes;
  DatabaseTable dbTable;
  final _formKey = GlobalKey<FormBuilderState>();
  var _callKey = GlobalKey<FormBuilderState>();
  bool isSelectedProc = false;

  String buildQuery(Map params) {
    String q = "CALL $procedureName(";
    params.forEach((key, value) {
      q += "$value,";
    });
    q = q.substring(0, q.length - 1) + ");";
    return q;
  }

  Widget buildTablesField(List<String> list) {
    return DBContainer(
      child: FormBuilderDropdown(
        onSaved: (value) async {
          procedureName = value;
          _callKey = new GlobalKey<FormBuilderState>();
        },
        attribute: "proc",
        decoration: InputDecoration(labelText: "Процедура"),
        hint: Text('Выберите процедуру'),
        validators: [FormBuilderValidators.required()],
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
          child: checkFieldIsDate(types[c].toString())
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
                  validators: checkFieldIsNum(types[c].toString())
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
                      FormBuilder(
                        key: _formKey,
                        child: Column(
                          children: [
                            FutureBuilder(
                              future: getProcedures(db: widget.db),
                              builder: (context, AsyncSnapshot<Map> snapshot) {
                                List<Widget> children;
                                if (snapshot.hasData) {
                                  children = [
                                    buildTablesField(snapshot.data["data"]),
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
                                      child: Text('Получение процедур...'),
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
                            DButton(
                              onPressed: () async {
                                if (!_formKey.currentState.validate()) {
                                  return;
                                }
                                _formKey.currentState.save();
                                Map m = await getProcedureParams(
                                    db: widget.db, proc: procedureName);
                                paramsNames = m["names"];
                                paramsTypes = m["types"];
                                print('got params');
                                if (paramsNames.length == 0) {
                                  isSelectedProc = false;
                                  String query = "CALL $procedureName();";
                                  Map<String, dynamic> data =
                                      await callProcedure(
                                          query: query, db: widget.db);
                                  dbTable = new DatabaseTable(data, query);
                                  print(2);
                                } else {
                                  print(3);
                                  isSelectedProc = true;
                                }
                                print(4);
                                setState(() {});
                              },
                              child: Text("Вызвать"),
                            ),
                          ],
                        ),
                      ),
                      FormBuilder(
                        key: _callKey,
                        child: Column(
                          children: isSelectedProc
                              ? [
                                  buildColumn(
                                      buildFields(paramsNames, paramsTypes)),
                                  DButton(
                                      width: 200,
                                      onPressed: () async {
                                        if (!_callKey.currentState.validate()) {
                                          return;
                                        }
                                        _callKey.currentState.save();

                                        String query = buildQuery(
                                            _callKey.currentState.value);
                                        print(_callKey.currentState.value);
                                        print("QUERY: $query");
                                        Map<String, dynamic> data =
                                            await callProcedure(
                                                query: query, db: widget.db);

                                        setState(() {
                                          dbTable =
                                              new DatabaseTable(data, query);
                                        });
                                      },
                                      child: Text(
                                        'Вызвать с параметрами',
                                        textAlign: TextAlign.center,
                                      )),
                                ]
                              : [],
                        ),
                      ),
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
