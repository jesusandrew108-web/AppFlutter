import 'package:flutter/material.dart';
import 'package:flutter_application_1_new/helper/db_helper.dart';
import 'package:flutter_application_1_new/login_form.dart';

class PasswordResetScreen extends StatefulWidget {
  final String email;
  final String verificationCode;

  const PasswordResetScreen({
    super.key,
    required this.email,
    required this.verificationCode,
  });

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      final enteredCode = _codeController.text;
      final newPassword = _newPasswordController.text;

      if (enteredCode == widget.verificationCode) {
        await SQHelper.updateUserPassword(widget.email, newPassword); // ✅ acceso correcto

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contraseña actualizada exitosamente.')),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginForm()),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código de recuperación incorrecto.')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Restablecer Contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Ingresa el código que te enviamos y tu nueva contraseña.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Código de Recuperación'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Ingresa el código' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _newPasswordController,
                decoration: const InputDecoration(labelText: 'Nueva Contraseña'),
                obscureText: true,
                validator: (value) => value == null || value.isEmpty ? 'Ingresa la nueva contraseña' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _resetPassword,
                child: const Text('Restablecer Contraseña'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }
}
