import 'package:db_abuser/funcs.dart';
import 'package:db_abuser/pages/select_page.dart';
import 'package:db_abuser/pages/update_page.dart';
import 'package:db_abuser/ui/button.dart';
import 'package:db_abuser/pages/alter_table_page.dart';
import 'package:db_abuser/pages/create_table_page.dart';
import 'package:db_abuser/pages/delete_page.dart';
import 'package:db_abuser/pages/drop_table_page.dart';
import 'package:db_abuser/pages/insert_into_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
          accentColor: Colors.red,
          highlightColor: Colors.red,
          cursorColor: Colors.red,
          inputDecorationTheme:
              InputDecorationTheme(border: OutlineInputBorder())),
      routes: {
        '/': (context) => MyHomePage(),
        '/create': (context) => CreateTablePage(),
        '/drop': (context) => DropTablePage(),
        '/alter': (context) => AlterTablePage(),
        '/insert': (context) => InsertIntoPage(),
        '/delete': (context) => DeletePage(),
        '/update': (context) => UpdatePage(),
        '/select': (context) => SelectPage()
      },
      initialRoute: '/',
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "DB_MNPLTR",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/create');
                    },
                    child: Text("CREATE")),
                DButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/alter');
                    },
                    child: Text("ALTER")),
                DButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/drop');
                    },
                    child: Text("DROP")),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/insert');
                    },
                    child: Text("INSERT")),
                DButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/update');
                    },
                    child: Text("UPDATE")),
                DButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/delete');
                    },
                    child: Text("DELETE")),
              ],
            ),
            DButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/select');
                },
                width: 200,
                child: Text("SELECT")),
          ],
        )),
      ),
    );
  }
}
