import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'login_form.dart';
import 'services/auth_service.dart';
import 'screens/verification_screen.dart';

class UserForm extends StatefulWidget {
  const UserForm({super.key});

  @override
  State<UserForm> createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _apPController = TextEditingController();
  final _apMController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  bool _loading = false;

  Future<void> _submitForm() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();
    final apP = _apPController.text.trim();
    final apM = _apMController.text.trim();
    final email = _emailController.text.trim().toLowerCase();
    final pass = _passController.text.trim();

    setState(() => _loading = true);

    try {
      // 1. Validar si el correo ya existe en backend
      final checkRes = await http.get(
        Uri.parse('http://10.0.2.2:8080/api/usuarios/check-email?email=$email'),
      );

      if (checkRes.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error verificando correo: ${checkRes.body}')),
        );
        return;
      }

      final dynamic rawCheck = jsonDecode(checkRes.body);
      final exists = (rawCheck is Map && (rawCheck['exists'] ?? false) == true);
      if (exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este correo ya está registrado.')),
        );
        return;
      }

      // 2. Determinar rol
      String role;
      if (pass == 'AndresAdmin') {
        role = 'administrador';
      } else {
        final countRes =
            await http.get(Uri.parse('http://10.0.2.2:8080/api/usuarios/count'));
        int count = 0;
        if (countRes.statusCode == 200) {
          final dynamic rawCount = jsonDecode(countRes.body);
          if (rawCount is Map && rawCount['count'] is int) {
            count = rawCount['count'] as int;
          }
        }
        role = count == 0 ? 'administrador' : 'cliente';
      }

      // 3. Generar código de verificación en Flutter
      final verificationCode = AuthService.generateCode();

      // 4. Crear usuario en backend (sin guardar verificationCode)
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/api/usuarios/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombre': nombre,
          'app': apP,
          'apm': apM,
          'email': email,
          'password': pass,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        // 5. Enviar correo con el código
        final sent = await AuthService.sendVerificationEmail(email: email, code: verificationCode);
        if (!sent) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo enviar el correo de verificación')),
          );
          return;
        }

        // Guardar datos en SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('currentUserEmail', email);
        await prefs.setString('currentUserRole', role);
        await prefs.setBool('isVerified', false);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Usuario creado como $role. Verifica tu cuenta por correo.')),
        );

        // 6. Navegar a pantalla de verificación y pasar el código generado
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VerificationScreen(
              email: email,
              verificationCode: verificationCode,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear usuario: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error inesperado: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Usuario')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingresa el nombre' : null,
              ),
              TextFormField(
                controller: _apPController,
                decoration: const InputDecoration(labelText: 'Apellido Paterno'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingresa el apellido paterno' : null,
              ),
              TextFormField(
                controller: _apMController,
                decoration: const InputDecoration(labelText: 'Apellido Materno (opcional)'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingresa un correo' : null,
              ),
              TextFormField(
                controller: _passController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Por favor ingresa la contraseña' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _submitForm,
                child: _loading ? const CircularProgressIndicator() : const Text('Crear'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginForm()),
                  );
                },
                child: const Text('¿Ya tienes una cuenta? Inicia sesión aquí'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apPController.dispose();
    _apMController.dispose();
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }
}
