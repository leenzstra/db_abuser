import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/pages/success_page.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:db_abuser/funcs.dart' as funcs;

class DropTablePage extends StatefulWidget {
  DropTablePage(this.db, {Key key}) : super(key: key);
  final String db;
  @override
  _DropTablePageState createState() => _DropTablePageState();
}

class _DropTablePageState extends State<DropTablePage> {
  String table;

  buildQuery(String table, bool isView) {
    String com = isView ? "VIEW" : "TABLE";
    return "DROP $com `$table`";
  }

  buildField(List<String> list, List<String> views) {
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
                          future: funcs.getTables(widget.db),
                          builder: (context, AsyncSnapshot<Map> snapshot) {
                            List<Widget> children;
                            if (snapshot.hasData) {
                              children = [
                                buildField(snapshot.data["data"],
                                    snapshot.data["views"]),
                                DButton(
                                    onPressed: () async {
                                      bool isView =
                                          (snapshot.data["views"] as List)
                                              .contains(table);
                                      String query = buildQuery(table, isView);
                                      String res = await funcs.dropTable(
                                          query: query, db: widget.db);
                                      Navigator.of(context).pushReplacement(
                                          new MaterialPageRoute(
                                        builder: (context) => SuccessPage(
                                            query: query, resultText: res),
                                      ));
                                    },
                                    child: Text('Удалить')),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
