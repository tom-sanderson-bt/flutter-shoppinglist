import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

const String _firebaseAppPath =
    'flutter-test-4ae8f-default-rtdb.europe-west1.firebasedatabase.app';
const String _firebaseDbName = 'shopping-list';

class FirebaseService {
  final _listUrl = Uri.https(_firebaseAppPath, '$_firebaseDbName.json');

  Future<Response> getItems() async {
    var result = await http.get(_listUrl);
    return result;
  }

  Future<Response> addItem(String name, String category, int quantity) async {
    var body =
        jsonEncode({'name': name, 'quantity': quantity, 'category': category});

    var result = await http.post(_listUrl,
        headers: {'content-type': 'application/json'}, body: body);
    return result;
  }

  Future<Response> deleteItem(String id) async {
    final itemUrl = Uri.https(_firebaseAppPath, '$_firebaseDbName/$id.json');

    var result = await http.delete(itemUrl);
    return result;
  }
}
