import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String _username = 'jesusandrew108@gmail.com';
  static final String _password = 'alol vdet kkvb mqei'; // App Password (Gmail)
  static final SmtpServer smtpServer = gmail(_username, _password);

  static String generateCode() {
    final random = Random();
    return (random.nextInt(900000) + 100000).toString();
  }

  static Future<bool> sendVerificationEmail({required String email, required String code}) async {
    final message = Message()
      ..from = Address(_username, 'AndrewShop')
      ..recipients.add(email)
      ..subject = 'Tu código de verificación'
      ..html = '<h2>Tu código</h2><h1 style="letter-spacing:2px;">$code</h1>';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendOtpEmail({required String email, required String code}) async {
    final message = Message()
      ..from = Address(_username, 'AndrewShop')
      ..recipients.add(email)
      ..subject = 'Código 2FA'
      ..html = '<p>Tu código de autenticación es:</p><h1 style="letter-spacing:2px;">$code</h1>';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendPasswordResetEmail({required String email, required String code}) async {
    final message = Message()
      ..from = Address(_username, 'AndrewShop')
      ..recipients.add(email)
      ..subject = 'Código para restablecer contraseña'
      ..html = '<h2>Usa este código</h2><h1 style="letter-spacing:2px;">$code</h1>';
    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendUsernameReminderEmail({required String email, required String username}) async {
    final message = Message()
      ..from = Address(_username, 'AndrewShop')
      ..recipients.add(email)
      ..subject = 'Recordatorio de usuario'
      ..html = '<p>Tu nombre de usuario es:</p><h3>$username</h3>';
    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendPurchaseSummaryEmail({
    required String toEmail,
    required List<Map<String, dynamic>> cart,
    required double total,
  }) async {
    final items = cart.map((item) {
      return "- ${item['nombre_product']} x${item['cantidad']} @ \$${item['precio']}";
    }).join('\n');

    final message = Message()
      ..from = Address(_username, 'Mi Tiendita')
      ..recipients.add(toEmail)
      ..subject = 'Resumen de tu compra'
      ..text = '''
Gracias por tu compra en Mi Tiendita.

Resumen de productos:
$items

Total pagado: \$${total.toStringAsFixed(2)}

Esperamos que disfrutes tu pedido.
''';

    try {
      await send(message, smtpServer);
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<void> login(String email, String password) async {
    final uri = Uri.parse('http://10.0.2.2:8080/api/usuarios/login');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error al iniciar sesión (${response.statusCode}): ${response.body}');
    }

    final dynamic raw = jsonDecode(response.body);
    if (raw is! Map) {
      throw Exception('Respuesta inválida de login');
    }

    final data = raw as Map<String, dynamic>;
    final token = (data['token'] is String) ? data['token'] as String : '';
    final role = (data['role'] is String) ? data['role'] as String : 'cliente';
    final verified = (data['verified'] ?? false) == true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentUserEmail', email);
    await prefs.setString('currentUserRole', role);
    await prefs.setString('authToken', token);
    await prefs.setBool('isVerified', verified);
    await prefs.setString('lastLoginAt', DateTime.now().toIso8601String());
  }
}
