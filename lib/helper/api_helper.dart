import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiHelper {
  static Future<Map<String, dynamic>> post(
      String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    return json.decode(response.body);
  }

  static Future<Map<String, dynamic>> get(String url) async {
    final response = await http.get(Uri.parse(url));
    return json.decode(response.body);
  }
}
