import 'package:flutter/material.dart';
import 'helper/db_helper.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshUsers();
  }

  void _refreshUsers() async {
    // ✅ Llamada correcta al método estático
    final data = await SQHelper.getUsers();
    setState(() {
      _users = data;
      _isLoading = false;
    });
  }

  // Diálogo para confirmar el cambio de rol
  void _changeRole(int id, String currentRole) {
    final newRole = currentRole == 'administrador' ? 'cliente' : 'administrador';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cambiar Rol'),
        content: Text('¿Estás seguro de cambiar el rol del usuario a "$newRole"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // ✅ Llamada correcta al método estático
              await SQHelper.updateUserRole(id, newRole);
              _refreshUsers();
              if (mounted) Navigator.of(context).pop();
              if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Rol actualizado a "$newRole"')),
              );
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios y Roles'),
        backgroundColor: Colors.deepPurple,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final isSelf = user['email'] == 'admin@tienda.com'; // Evitar cambiar rol al admin principal

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    title: Text(user['email']),
                    subtitle: Text('ID: ${user['id']} | Rol: ${user['role'].toUpperCase()}'),
                    trailing: isSelf
                        ? const Icon(Icons.admin_panel_settings, color: Colors.grey)
                        : TextButton(
                            onPressed: () => _changeRole(user['id'], user['role']),
                            child: Text(
                              user['role'] == 'administrador' ? 'Hacer Cliente' : 'Hacer Admin',
                              style: TextStyle(
                                color: user['role'] == 'administrador' ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                  ),
                );
              },
            ),
    );
  }
}
