import 'package:db_abuser/datatable.dart';
import 'package:db_abuser/funcs.dart';
import 'package:db_abuser/pages/success_page.dart';
import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class RawSQLPage extends StatefulWidget {
  RawSQLPage(this.db, {Key key}) : super(key: key);

  final String db;

  @override
  _RawSQLPageState createState() => _RawSQLPageState();
}

class _RawSQLPageState extends State<RawSQLPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  DatabaseTable dbTable;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        body: Scrollbar(
          child: SingleChildScrollView(
            child: Stack(
              children: [
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
                        DBContainer(
                          width: 700,
                          child: FormBuilderTextField(
                              attribute: "sql",
                              maxLines: null,
                              keyboardType: TextInputType.multiline),
                        ),
                        DButton(
                            onPressed: () async {
                              _formKey.currentState.save();
                              print(_formKey.currentState.value["sql"]);
                              String query = _formKey.currentState.value["sql"];
                              Map<String, dynamic> data =
                                  await rawQuery(query: query, db: widget.db);
                              setState(() {
                                dbTable = new DatabaseTable(data, query);
                              });
                            },
                            child: Text("Выполнить")),
                        dbTable == null
                            ? Container(
                                height: 5,
                              )
                            : dbTable
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
