import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../helper/db_helper.dart';


class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _refreshProducts();
  }

  void _refreshProducts() async {
  final data = await SQHelper.getProducts();
  print("Productos cargados en pantalla (admin): ${data.length}");
  setState(() {
    _products = data;
    _isLoading = false;
  });
}


  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingProduct = _products.firstWhere((element) => element['id'] == id);
      _nameController.text = existingProduct['nombre_product'];
      _priceController.text = existingProduct['precio'].toString();
      _quantityController.text = existingProduct['cantidad'].toString();
      _selectedImage = existingProduct['imagen'] != null && existingProduct['imagen'].toString().isNotEmpty
          ? File(existingProduct['imagen'])
          : null;
    } else {
      _nameController.clear();
      _priceController.clear();
      _quantityController.clear();
      _selectedImage = null;
    }

    await showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          top: 15,
          left: 15,
          right: 15,
          bottom: MediaQuery.of(context).viewInsets.bottom + 50,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(id == null ? 'Crear Producto' : 'Actualizar Producto',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nombre')),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Precio'),
            ),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Cantidad'),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Seleccionar Imagen'),
            ),
            if (_selectedImage != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Image.file(_selectedImage!, width: 100, height: 100, fit: BoxFit.cover),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final String name = _nameController.text;
                final double price = double.tryParse(_priceController.text) ?? 0.0;
                final int quantity = int.tryParse(_quantityController.text) ?? 0;
                final String? imagePath = _selectedImage?.path;

                if (name.isNotEmpty && price > 0 && quantity >= 0) {
                  if (id == null) {
                    await SQHelper.createProduct(name, price, quantity, imagePath);
                  } else {
                    await SQHelper.updateProduct(id, name, price, quantity, imagePath);
                  }

                  _nameController.clear();
                  _priceController.clear();
                  _quantityController.clear();
                  _selectedImage = null;
                  if (mounted) Navigator.of(context).pop();
                  _refreshProducts();
                } else {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Por favor, completa todos los campos correctamente.')),
                  );
                }
              },
              child: Text(id == null ? 'Crear' : 'Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteProduct(int id) async {
    await SQHelper.deleteProduct(id);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Producto eliminado exitosamente!')),
    );
    _refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        backgroundColor: Colors.deepOrange,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _products.length,
              itemBuilder: (context, index) {
                final product = _products[index];
                final imagePath = product['imagen'];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    leading: imagePath != null && imagePath.toString().isNotEmpty
                        ? Image.file(File(imagePath), width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.inventory, size: 40),
                    title: Text(product['nombre_product']),
                    subtitle: Text('Precio: \$${product['precio'].toStringAsFixed(2)} | Cantidad: ${product['cantidad']}'),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showForm(product['id']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteProduct(product['id']),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(null),
        child: const Icon(Icons.add),
      ),
    );
  }
}
