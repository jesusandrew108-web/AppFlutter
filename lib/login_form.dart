import 'package:flutter/material.dart';
import 'package:flutter_application_1_new/screens/forgot_password_screen.dart';
import 'package:flutter_application_1_new/screens/forgot_username_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'user_form.dart';
import 'services/auth_service.dart';
import 'screens/verification_screen.dart';
import 'screens/verify_2fa_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  Future<void> _login() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    final password = _passController.text.trim();

    setState(() => _loading = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de login: ${response.body}')),
        );
        return;
      }

      final dynamic raw = jsonDecode(response.body);
      if (raw is! Map) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Respuesta de login inválida')),
        );
        return;
      }

      final data = raw as Map<String, dynamic>;
      final role = (data['role'] is String) ? data['role'] as String : 'cliente';
      final verified = (data['verified'] ?? false) == true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUserEmail', email);
      await prefs.setString('currentUserRole', role);
      await prefs.setBool('isVerified', verified);

      if (!verified) {
        // Usuario no verificado → enviar nuevo código y redirigir
        final verificationCode = AuthService.generateCode();
        final sent = await AuthService.sendVerificationEmail(email: email, code: verificationCode);
        if (!sent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo enviar el correo de verificación')),
          );
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: email,
              verificationCode: verificationCode,
            ),
          ),
        );
        return;
      }

      // Usuario verificado → 2FA
      final otp = AuthService.generateCode();
      final sentOtp = await AuthService.sendOtpEmail(email: email, code: otp);
      if (!sentOtp) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo enviar el código 2FA')),
        );
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Verify2FAScreen(email: email, role: role, otpCode: otp),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al iniciar sesión: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Bienvenido a AndrewShop',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v == null || v.isEmpty ? 'Ingresa tu correo' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _passController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (v) => v == null || v.isEmpty ? 'Ingresa tu contraseña' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                child: _loading ? const CircularProgressIndicator() : const Text('Ingresar'),
              ),
              const SizedBox(height: 30),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const UserForm()),
                    );
                  },
                  child: const Text(
                    '¿No tienes cuenta? Regístrate aquí',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ForgotUsernameScreen()),
                  );
                },
                child: const Text('¿Olvidaste tu usuario?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
                  );
                },
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
