import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  static Future<String?> createPayPalOrder(
      List<Map<String, dynamic>> cart, double total) async {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:8080/create-order'), // ✅ puerto correcto
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'cart': cart, 'total': total}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['approvalUrl'];
    } else {
      print('Error al crear orden: ${response.body}');
      return null;
    }
  }
}
