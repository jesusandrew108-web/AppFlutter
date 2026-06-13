import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class ProfileScreen extends StatelessWidget {
  final auth = LocalAuthentication();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final ok = await auth.authenticate(
              localizedReason: 'Autenticación requerida',
            );
            if (ok) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Autenticado')),
              );
            }
          },
          child: Text('Usar huella'),
        ),
      ),
    );
  }
}
