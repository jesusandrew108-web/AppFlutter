import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../login_form.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const VerificationScreen({
    Key? key,
    required this.email,
    required this.verificationCode,
  }) : super(key: key);

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _verificationCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _verificationCodeController.dispose();
    super.dispose();
  }

  Future<void> _verifyCode() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    final enteredCode = _verificationCodeController.text.trim();

    if (enteredCode != widget.verificationCode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código de verificación incorrecto. Intenta de nuevo.')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/usuarios/verify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.email}),
      );

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isVerified', true);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Correo verificado exitosamente! Ya puedes iniciar sesión.')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginForm()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al verificar usuario: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red/verificación: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificar Correo')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Se ha enviado un código a ${widget.email}. Ingresa el código a continuación para verificar tu cuenta.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _verificationCodeController,
                decoration: const InputDecoration(labelText: 'Código de Verificación'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingresa el código' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _verifyCode,
                child: _loading ? const CircularProgressIndicator() : const Text('Verificar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
