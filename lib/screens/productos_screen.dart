import 'dart:io';
import 'package:flutter/material.dart';
import '../helper/db_helper.dart';
import 'cart_screen.dart';

class ProductosScreen extends StatefulWidget {
  final Function(List<Map<String, dynamic>>) onCartUpdate;

  const ProductosScreen({super.key, required this.onCartUpdate});

  @override
  State<ProductosScreen> createState() => _ProductosScreenState();
}

class _ProductosScreenState extends State<ProductosScreen> {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _cart = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    final data = await SQHelper.getProducts();
    setState(() {
      _products = data;
      _isLoading = false;
    });
  }

  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = _cart.indexWhere((item) => item['id'] == product['id']);
      if (index != -1) {
        final currentQty = _cart[index]['cantidad'] ?? 1;
        _cart[index]['cantidad'] = currentQty + 1;
      } else {
        final newProduct = Map<String, dynamic>.from(product);
        newProduct['cantidad'] = 1;
        _cart.add(newProduct);
      }
    });

    widget.onCartUpdate(_cart);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product['nombre_product']} agregado al carrito')),
    );
  }

  void _goToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CartScreen(cart: _cart),
      ),
    );
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
        title: const Text('Productos disponibles'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: _goToCart,
          ),
          if (_cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '$totalItems',
                  style: const TextStyle(fontSize: 16, color: Colors.amber),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? const Center(child: Text('No hay productos disponibles'))
              : ListView.builder(
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    final imagePath = product['imagen'];
                    final isLocal = imagePath != null && !imagePath.toString().startsWith('http');

                    final imageWidget = (imagePath == null || imagePath.toString().isEmpty)
                        ? const Icon(Icons.image, size: 50)
                        : isLocal
                            ? Image.file(File(imagePath), width: 50, height: 50, fit: BoxFit.cover)
                            : Image.network(imagePath, width: 50, height: 50, fit: BoxFit.cover);

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: SizedBox(width: 50, height: 50, child: imageWidget),
                        title: Text(product['nombre_product'] ?? 'Sin nombre'),
                        subtitle: Text('Precio: \$${product['precio'] ?? '0'}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () => _addToCart(product),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
