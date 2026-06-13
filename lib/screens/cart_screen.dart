import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../widgets/paypal_webview.dart';
import '../services/auth_service.dart';

class CartScreen extends StatefulWidget {
  final List<Map<String, dynamic>> cart;

  const CartScreen({super.key, required this.cart});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late List<Map<String, dynamic>> _cart;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    // Normaliza cantidad mínima = 1
    _cart = widget.cart.map((item) {
      return {
        ...item,
        'cantidad': (item['cantidad'] == null || (item['cantidad'] is int && item['cantidad']! <= 0))
            ? 1
            : item['cantidad'],
      };
    }).toList();
    _calculateTotal();
  }

  void _calculateTotal() {
    _total = _cart.fold(0.0, (sum, item) {
      final price = double.tryParse(item['precio']?.toString() ?? '0') ?? 0.0;
      final quantity = (item['cantidad'] is int) ? item['cantidad'] as int : 1;
      return sum + (price * quantity);
    });
    setState(() {});
  }

  void _removeItem(int index) {
    setState(() {
      _cart.removeAt(index);
      _calculateTotal();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado del carrito')),
    );
  }

  void _changeQuantity(int index, int delta) {
    setState(() {
      final current = (_cart[index]['cantidad'] is int) ? _cart[index]['cantidad'] as int : 1;
      final updated = (current + delta).clamp(1, 99);
      _cart[index]['cantidad'] = updated;
      _calculateTotal();
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
      _total = 0.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Carrito vaciado')),
    );
  }

  Future<void> _startPayPalFlow() async {
    if (_cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tu carrito está vacío')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8080/create-order'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'cart': _cart, 'total': _total}),
      );

      if (response.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear orden: ${response.body}')),
        );
        return;
      }

      final approvalUrl = json.decode(response.body)['approvalUrl'];
      if (approvalUrl == null || approvalUrl.toString().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se recibió approvalUrl de PayPal')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PayPalWebView(
            approvalUrl: approvalUrl,
            onSuccess: () async {
              // TODO: reemplazar con email real del usuario autenticado
              final email = 'cliente@correo.com';

              await AuthService.sendPurchaseSummaryEmail(
                toEmail: email,
                cart: _cart,
                total: _total,
              );

              _clearCart();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago exitoso y resumen enviado')),
              );
            },
            onCancel: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pago cancelado')),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de red: ${e.toString()}')),
      );
    }
  }

  Widget _buildImage(dynamic imagen) {
    if (imagen == null || imagen.toString().isEmpty) {
      return const Icon(Icons.image, size: 50);
    }
    final path = imagen.toString();
    final isRemote = path.startsWith('http');
    return isRemote
        ? Image.network(path, width: 50, height: 50, fit: BoxFit.cover)
        : Image.file(File(path), width: 50, height: 50, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final totalItems = _cart.fold<int>(0, (sum, item) {
      final qtyRaw = item['cantidad'];
      final qty = (qtyRaw is int)
        ? qtyRaw
        : int.tryParse(qtyRaw?.toString() ?? '') ?? 1;
      return sum + qty; // ✅ ahora siempre devuelve int
      });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tu Carrito'),
        actions: [
          if (_cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  'Artículos: $totalItems',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _cart.isEmpty
          ? const Center(child: Text('No hay productos en el carrito'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _cart.length,
                    itemBuilder: (context, index) {
                      final item = _cart[index];
                      final name = (item['nombre_product'] ?? 'Sin nombre').toString();
                      final price = double.tryParse(item['precio']?.toString() ?? '0') ?? 0.0;
                      final qty = (item['cantidad'] is int) ? item['cantidad'] as int : 1;
                      final subtotal = price * qty;

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          leading: SizedBox(width: 50, height: 50, child: _buildImage(item['imagen'])),
                          title: Text(name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Precio: \$${price.toStringAsFixed(2)}'),
                              Text('Subtotal: \$${subtotal.toStringAsFixed(2)}'),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline),
                                    onPressed: () => _changeQuantity(index, -1),
                                  ),
                                  Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline),
                                    onPressed: () => _changeQuantity(index, 1),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeItem(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const Divider(),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text('Total:',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Text('\$${_total.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _startPayPalFlow,
                              icon: const Icon(Icons.payment),
                              label: const Text('Pagar con PayPal'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: _clearCart,
                            child: const Text(
                              'Vaciar Carrito',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
