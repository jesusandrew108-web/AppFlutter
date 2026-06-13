import 'package:flutter/material.dart';
import '../helper/db_helper.dart'; // Importamos el helper
import 'product_management_screen.dart'; // Nueva pantalla para gestionar productos
// ✅ Correcto
import 'user_list_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administrador'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Bienvenido, Administrador',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 40),

            // Botón para ir a la gestión de usuarios (Asignar roles)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserListScreen()),
                );
              },
              icon: const Icon(Icons.people_alt, size: 28),
              label: const Text('Gestionar Usuarios (Roles)', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            const SizedBox(height: 20),

            // Botón para ir a la gestión de productos (CRUD)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProductManagementScreen()),
                );
              },
              icon: const Icon(Icons.inventory, size: 28),
              label: const Text('Gestionar Productos (CRUD)', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
    );
  }
}