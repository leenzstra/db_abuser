import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/pages/success_page.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:db_abuser/funcs.dart' as funcs;
import 'package:db_abuser/ui/ui_funcs.dart' as ui_funcs;

class AlterTablePage extends StatefulWidget {
  AlterTablePage({Key key}) : super(key: key);

  @override
  _AlterTablePageState createState() => _AlterTablePageState();
}

class _AlterTablePageState extends State<AlterTablePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  String table;
  List fields;
  List types;
  bool isSelected = false;
  buildQuery(Map values) {
    String spec = values["spec"];
    return "ALTER TABLE `$table` $spec ";
  }

  buildTablesField(List<String> list) {
    return Container(
      width: 300,
      child: FormBuilderDropdown(
        onChanged: (value) async {
          table = value;
          Map m = await ui_funcs.getFieldsAndTypes(table);
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
            .map((tab) => DropdownMenuItem(value: tab, child: Text("$tab")))
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
                            future: funcs.getTables(),
                            builder: (context, AsyncSnapshot<Map> snapshot) {
                              List<Widget> children;
                              if (snapshot.hasData) {
                                children = [
                                  buildTablesField(snapshot.data["data"]),
                                  buildField('spec'),
                                  DButton(
                                      onPressed: () async {
                                        if (!_formKey.currentState.validate()) {
                                          return;
                                        }
                                        _formKey.currentState.save();
                                        String query = buildQuery(
                                            _formKey.currentState.value);
                                        String res =
                                            await funcs.dropTable(query: query);
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
