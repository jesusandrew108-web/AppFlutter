import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyOtpScreen extends StatelessWidget {
  final String email;
  final otpController = TextEditingController();

  VerifyOtpScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Verificar código')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              decoration: InputDecoration(labelText: 'Código OTP'),
            ),
            ElevatedButton(
              onPressed: () async {
                final response = await http.post(
                  Uri.parse('http://10.0.2.2:8000/verify-otp'),
                  body: json.encode({'email': email, 'otp': otpController.text}),
                  headers: {'Content-Type': 'application/json'},
                );
                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Código verificado')),
                  );
                  Navigator.pop(context);
                }
              },
              child: Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}
