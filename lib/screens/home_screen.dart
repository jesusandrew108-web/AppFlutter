import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../login_form.dart';
import '../user_profile.dart';
import '../helper/db_helper.dart';
import '../screens/productos_screen.dart';
import '../screens/bluetooth_print_screen.dart'; // ✅ Importa la pantalla de impresión
import '../services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Map<String, dynamic>> _cartItems = [];
  Map<String, dynamic> _userData = {};

  @override
  void initState() {
    super.initState();
    _loadUserProfile();

    // ⏰ Verificación periódica de abandono de carrito
    Timer.periodic(const Duration(minutes: 5), (timer) {
      _checkCartAbandonment();
    });
  }

  Future<void> _loadUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('currentUserEmail');
    if (email != null) {
      final user = await SQHelper.getUserByEmail(email);
      if (mounted && user != null) {
        setState(() {
          _userData = user;
        });
      }
    }
  }

  void _updateCart(List<Map<String, dynamic>> newCart) {
    setState(() {
      _cartItems = newCart;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUserEmail');
    await prefs.remove('user_cart');
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginForm()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // 🔔 Verifica si hay productos sin pagar y lanza notificación
  void _checkCartAbandonment() async {
    final cartItems = await SQHelper.getCartItems();
    if (cartItems.isNotEmpty) {
      NotificationService.show(
        '¡Tu carrito te espera!',
        'Tienes productos sin comprar. ¿Deseas finalizar tu compra?',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      ProductosScreen(onCartUpdate: _updateCart),
      const Center(child: Text('Pantalla de Carrito (Implementar)')),
      _userData.isNotEmpty
          ? UserProfileScreen(userData: _userData)
          : const Center(child: CircularProgressIndicator()),
    ];

    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Productos',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart),
                if (_cartItems.isNotEmpty)
                  Positioned(
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '${_cartItems.length}',
                        style: const TextStyle(color: Colors.white, fontSize: 8),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Carrito',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      floatingActionButton: _selectedIndex == 2
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BluetoothPrintScreen(),
                      ),
                    );
                  },
                  label: const Text('Imprimir Ticket'),
                  icon: const Icon(Icons.print),
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
                const SizedBox(height: 10),
                FloatingActionButton.extended(
                  onPressed: _logout,
                  label: const Text('Cerrar Sesión'),
                  icon: const Icon(Icons.logout),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
              ],
            )
          : null,
    );
  }
}
