// screens/forgot_username_screen.dart
import 'package:flutter/material.dart';
import '../helper/db_helper.dart';
import '../services/auth_service.dart';

class ForgotUsernameScreen extends StatefulWidget {
  const ForgotUsernameScreen({super.key});
  @override
  State<ForgotUsernameScreen> createState() => _ForgotUsernameScreenState();
}

class _ForgotUsernameScreenState extends State<ForgotUsernameScreen> {
  final _emailController = TextEditingController();

  Future<void> _sendReminder() async {
    final email = _emailController.text.trim();
    final user = await SQHelper.getUserByEmail(email);
    if (user != null) {
      await AuthService.sendUsernameReminderEmail(email: email, username: email);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hemos enviado tu usuario al correo.')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No encontramos una cuenta con ese correo.')));
    }
  }

  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Usuario')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Correo')),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _sendReminder, child: const Text('Enviar usuario')),
        ]),
      ),
    );
  }
}
