import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/pages/success_page.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:db_abuser/funcs.dart' as funcs;
import 'package:db_abuser/ui/ui_funcs.dart' as ui_funcs;

class AlterTablePage extends StatefulWidget {
  AlterTablePage(this.db, {Key key}) : super(key: key);
  final String db;
  @override
  _AlterTablePageState createState() => _AlterTablePageState();
}

class _AlterTablePageState extends State<AlterTablePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String table;
  List fields;
  List types;
  bool isSelected = false;

  buildQuery(Map values, bool isView) {
    String spec = values["spec"];
    String com = isView ? "VIEW" : "TABLE";
    return "ALTER $com `$table` $spec ";
  }

  buildTablesField(List<String> list, List<String> views) {
    return Container(
      width: 300,
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
        onSaved: (newValue) => table = newValue,
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

  buildField(String attribute) {
    return DBContainer(
        child: FormBuilderTextField(
            minLines: 5,
            maxLines: 10,
            attribute: attribute,
            decoration: InputDecoration(labelText: "Спецификации")));
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
                                  buildField('spec'),
                                  DButton(
                                      onPressed: () async {
                                        if (!_formKey.currentState.validate()) {
                                          return;
                                        }
                                        _formKey.currentState.save();
                                        bool isView =
                                            (snapshot.data["views"] as List)
                                                .contains(table);
                                        String query = buildQuery(
                                            _formKey.currentState.value,
                                            isView);
                                        String res = await funcs.dropTable(
                                            query: query, db: widget.db);
                                        Navigator.of(context).pushReplacement(
                                            new MaterialPageRoute(
                                          builder: (context) => SuccessPage(
                                              query: query, resultText: res),
                                        ));
                                      },
                                      child: Text('Изменить')),
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
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        )));
  }
}
