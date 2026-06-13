import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class AuthService {
  static final String _username = 'TU_CORREO@gmail.com';
  static final String _password = 'TU_CONTRASEÑA_DE_APP'; // no tu contraseña normal

  static final smtpServer = gmail(_username, _password);

  static Future<void> sendPurchaseSummaryEmail({
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
      ..subject = 'Resumen de tu compra 🛒'
      ..text = '''
Gracias por tu compra en Mi Tiendita.

Resumen de productos:
$items

Total pagado: \$${total.toStringAsFixed(2)}

Esperamos que disfrutes tu pedido.
''';

    try {
      await send(message, smtpServer);
      print('Resumen de compra enviado a $toEmail');
    } catch (e) {
      print('Error al enviar resumen: $e');
    }
  }
}
