import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'admin_screen.dart';

class Verify2FAScreen extends StatefulWidget {
  final String email;
  final String role;
  final String otpCode;

  const Verify2FAScreen({
    super.key,
    required this.email,
    required this.role,
    required this.otpCode,
  });

  @override
  State<Verify2FAScreen> createState() => _Verify2FAScreenState();
}

class _Verify2FAScreenState extends State<Verify2FAScreen> {
  final _otpController = TextEditingController();

  Future<void> _verify() async {
    final entered = _otpController.text.trim();
    if (entered == widget.otpCode) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) =>
                widget.role == 'administrador' ? const AdminScreen() : const HomeScreen(),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Código incorrecto')));
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Autenticación 2FA')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          const Text('Ingresa el código que enviamos a tu correo'),
          const SizedBox(height: 20),
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Código'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _verify, child: const Text('Verificar')),
        ]),
      ),
    );
  }
}
