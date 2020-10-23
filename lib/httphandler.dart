import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//асинхронная функция, получает в параметры ссылку на файл и сформированный заранее запрос
//возвращает Map(ассоциативный массив) с результатом
//map["result"] - результат
//map["data"] - данные

Future<Map<String, dynamic>> postHTTP(String file, String query,
    {String db = "_nodb_"}) async {
  Map<String, String> body = {"query": query, "db": db};
  http.Response response =
      await http.post('http://localhost/php/$file', body: body);
  if (response.statusCode >= 200) {
    print("POST: $query");
    print(response.body);
    Map<String, dynamic> map = JsonDecoder().convert(response.body);
    print(map);
    return map;
  } else {
    print(response.statusCode);
  }
  return {"result": "connection-error ${response.statusCode}"};
}
