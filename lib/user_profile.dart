// user_profile.dart

import 'package:flutter/material.dart';

// 💡 MODIFICACIÓN: La pantalla de perfil ahora recibe los datos del usuario.
class UserProfileScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  const UserProfileScreen({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    // 💡 Extracción de datos con valores por defecto
    final String nombre = userData['nombre'] ?? 'N/A';
    final String apP = userData['apP'] ?? '';
    final String apM = userData['apM'] ?? '';
    final String email = userData['email'] ?? 'N/A';
    final String role = userData['role'] ?? 'cliente';
    final String nombreCompleto = '$nombre $apP $apM'.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Usuario'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 120,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  nombreCompleto.isEmpty ? 'Usuario sin nombre' : nombreCompleto,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
              ),
              Center(
                child: Text(
                  'Rol: ${role.toUpperCase()}',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic),
                ),
              ),
              const Divider(height: 40, thickness: 1),
              
              // Detalles del Usuario
              _buildDetailRow(Icons.person_outline, 'Nombre(s)', nombre),
              _buildDetailRow(Icons.badge_outlined, 'Apellido Paterno', apP),
              _buildDetailRow(Icons.badge_outlined, 'Apellido Materno', apM.isEmpty ? 'No especificado' : apM),
              _buildDetailRow(Icons.email_outlined, 'Correo Electrónico', email),

              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implementar lógica de edición de perfil
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de edición de perfil pendiente.')),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Editar Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              // Botón de Cierre de Sesión
              const SizedBox(height: 10),
              TextButton(
                onPressed: () async {
                  // Asumimos que tienes una función para cerrar sesión que limpia SharedPreferences
                  // await _clearSessionAndNavigateToLogin(context); 
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Función de cierre de sesión pendiente.')),
                  );
                },
                child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Widget auxiliar para mostrar filas de detalles
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueAccent, size: 24),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}