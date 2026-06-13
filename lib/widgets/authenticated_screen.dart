// authenticated_screen
import 'package:flutter/material.dart';

class AuthenticatedScreen extends StatelessWidget {
  const AuthenticatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pantalla Autenticada'),
      ),
      body: const Center(
        child: Text('Bienvenido, usuario autenticado'),
      ),
    );
  }
}