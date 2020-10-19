import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//асинхронная функция, получает в параметры ссылку на файл и сформированный заранее запрос
//возвращает Map(ассоциативный массив) с результатом
//map["result"] - результат
//map["data"] - данные

Future<Map<String, dynamic>> postHTTP(
    {@required String fileLink, @required String query}) async {
  Map<String, String> body = {"query": query};
  http.Response response =
      await http.post('http://localhost/php/$fileLink', body: body);
  if (response.statusCode >= 200) {
    Map<String, dynamic> map = JsonDecoder().convert(response.body);
    return map;
  } else {
    print(response.statusCode);
  }
  return {"result": "connection-error ${response.statusCode}"};
}
