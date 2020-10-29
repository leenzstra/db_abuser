import 'package:db_abuser/funcs.dart';
import 'package:db_abuser/pages/raw_sql_page.dart';
import 'package:db_abuser/pages/select_page.dart';
import 'package:db_abuser/pages/success_page.dart';
import 'package:db_abuser/pages/update_page.dart';
import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/pages/alter_table_page.dart';
import 'package:db_abuser/pages/create_table_page.dart';
import 'package:db_abuser/pages/delete_page.dart';
import 'package:db_abuser/pages/drop_table_page.dart';
import 'package:db_abuser/pages/insert_into_page.dart';
import 'package:db_abuser/ui/db_form_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          accentColor: Colors.red,
          inputDecorationTheme:
              InputDecorationTheme(border: OutlineInputBorder())),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String dbname = "lab2";
  final _formKey = GlobalKey<FormBuilderState>();
  Widget buildTablesField(List<String> list) {
    return DBContainer(
      width: 200,
      child: FormBuilderDropdown(
        onChanged: (value) async {
          dbname = value;
          print(dbname);
        },
        initialValue: "lab2",
        attribute: "db",
        decoration: InputDecoration(labelText: "База данных"),
        hint: Text('Выберите БД'),
        validators: [FormBuilderValidators.required()],
        items: list
            .map((tab) => DropdownMenuItem(value: tab, child: Text("$tab")))
            .toList(),
      ),
    );
  }

  Widget buildLeftColumn({@required Widget child}) {
    return Container(
        alignment: Alignment.center,
        color: Colors.black.withOpacity(0.05),
        child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
              flex: 2,
              child: buildLeftColumn(
                  child: FutureBuilder(
                      future: getDatabases(),
                      builder: (context,
                          AsyncSnapshot<Map<String, dynamic>> snapshot) {
                        if (snapshot.hasData) {
                          print(snapshot.data);
                          return FormBuilder(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                buildTablesField(snapshot.data["data"]),
                                Text("или"),
                                DBContainer(
                                  width: 200,
                                  child: FormBuilderTextField(
                                      attribute: "createdb",
                                      decoration: InputDecoration(
                                          labelText: "Создать базу данных")),
                                ),
                                DButton(
                                    onPressed: () async {
                                      if (!_formKey.currentState.validate()) {
                                        return;
                                      }
                                      _formKey.currentState.save();
                                      String db = _formKey
                                          .currentState.value["createdb"];
                                      String query = "CREATE DATABASE `$db`;";
                                      String res =
                                          await createDatabase(query: query);
                                      print(res);
                                      setState(() {});
                                      Navigator.of(context)
                                          .push(new MaterialPageRoute(
                                        builder: (context) => SuccessPage(
                                            query: query, resultText: res),
                                      ));
                                    },
                                    child: Text('Создать')),
                              ],
                            ),
                          );
                        } else {
                          return Text("Загрузка");
                        }
                      }))),
          Expanded(
            flex: 8,
            child: Container(
                alignment: Alignment.center,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "DB_MNPLTR",
                      style:
                          TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CreateTablePage(dbname),
                                  ));
                            },
                            child: Text("CREATE")),
                        DButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AlterTablePage(dbname),
                                  ));
                            },
                            child: Text("ALTER")),
                        DButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DropTablePage(dbname),
                                  ));
                            },
                            child: Text("DROP")),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        InsertIntoPage(dbname),
                                  ));
                            },
                            child: Text("INSERT")),
                        DButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdatePage(dbname),
                                  ));
                            },
                            child: Text("UPDATE")),
                        DButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DeletePage(dbname),
                                  ));
                            },
                            child: Text("DELETE")),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SelectPage(dbname),
                                  ));
                            },
                            width: 200,
                            child: Text("SELECT")),
                        DButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RawSQLPage(dbname),
                                  ));
                            },
                            width: 100,
                            child: Text("RAW SQL")),
                      ],
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}
