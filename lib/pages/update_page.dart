import 'package:db_abuser/pages/success_page.dart';
import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:db_abuser/ui/ui_funcs.dart' as ui_funcs;
import 'package:db_abuser/funcs.dart' as funcs;

class UpdatePage extends StatefulWidget {
  UpdatePage(this.db, {Key key}) : super(key: key);
  final String db;
  @override
  _UpdatePageState createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String table;
  List fields;
  List types;
  bool isSelected = false;
  List<Widget> inputs = [];

  @override
  void initState() {
    super.initState();
    addSetFields();
  }

  buildQuery(Map values) {
    print(values);
    String q = "UPDATE `$table` SET ";
    for (int i = 0; i < inputs.length; i++) {
      if (values['set$i'] != '') {
        q += values['set$i'];
      }
      if (i != inputs.length - 1) {
        q += ', ';
      }
    }
    if (values['where'] != '') {
      String where = values['where'];
      q += " WHERE $where";
    }
    print(q);
    return q;
  }

  buildTablesField(List<String> list, List<String> views) {
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

  Widget buildField(String attribute, String label) {
    return DBContainer(
        child: FormBuilderTextField(
            initialValue: "Поле = 'Значение'",
            attribute: attribute,
            decoration: InputDecoration(labelText: label)));
  }

  addSetFields() {
    inputs.add(buildField('set${inputs.length}', 'SET ${inputs.length + 1}'));
  }

  delSetFields() {
    if (inputs.length > 1) {
      inputs.removeLast();
    }
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
                  child: FormBuilder(
                    key: _formKey,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: children,
                              ),
                            );
                          },
                        ),
                        Column(
                          children: inputs,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            DButton(
                                onPressed: () {
                                  setState(() {
                                    addSetFields();
                                  });
                                },
                                child: Text('+')),
                            DButton(
                                onPressed: () {
                                  setState(() {
                                    delSetFields();
                                  });
                                },
                                child: Text('-'))
                          ],
                        ),
                        buildField('where', 'Условие'),
                        DButton(
                            onPressed: () async {
                              if (!_formKey.currentState.validate()) {
                                return;
                              }
                              _formKey.currentState.save();
                              String query =
                                  buildQuery(_formKey.currentState.value);
                              String res = await funcs.updateTable(
                                  query: query, db: widget.db);
                              Navigator.of(context)
                                  .pushReplacement(new MaterialPageRoute(
                                builder: (context) =>
                                    SuccessPage(query: query, resultText: res),
                              ));
                            },
                            child: Text(
                              'Обновить',
                              textAlign: TextAlign.center,
                            )),
                      ],
                    ),
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
