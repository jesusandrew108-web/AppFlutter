import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'verify_otp_screen.dart';

class ForgotPasswordScreen extends StatelessWidget {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recuperar contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Correo electrónico'),
            ),
            ElevatedButton(
              onPressed: () async {
                await http.post(
                  Uri.parse('http://10.0.2.2:8000/send-otp'),
                  body: json.encode({'email': emailController.text}),
                  headers: {'Content-Type': 'application/json'},
                );
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => VerifyOtpScreen(email: emailController.text),
                ));
              },
              child: Text('Enviar código'),
            ),
          ],
        ),
      ),
    );
  }
}
