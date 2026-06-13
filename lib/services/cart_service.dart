import 'package:flutter_application_1_new/helper/db_helper.dart';

class CartService {
  /// Verifica si hay productos en el carrito
  static Future<bool> hasItemsInCart() async {
    final items = await SQHelper.getCartItems();
    return items.isNotEmpty;
  }

  /// Obtiene todos los productos del carrito
  static Future<List<Map<String, dynamic>>> getCartItems() async {
    return await SQHelper.getCartItems();
  }

  /// Vacía completamente el carrito
  static Future<void> clearCart() async {
    await SQHelper.clearCart();
  }

  /// Elimina un producto específico del carrito
  static Future<void> deleteItem(int id) async {
    await SQHelper.deleteCartItem(id);
  }

  /// Agrega un producto al carrito (si existe, suma cantidad)
  static Future<void> addItem({
    required int productId,
    required String nombre,
    required double precio,
    required int cantidad,
    String? imagen,
  }) async {
    final items = await SQHelper.getCartItems();
    final existing = items.firstWhere(
      (item) => item['productId'] == productId,
      orElse: () => {},
    );

    if (existing.isNotEmpty) {
      final newCantidad = (existing['cantidad'] ?? 1) + cantidad;
      await SQHelper.updateCartItemCantidad(productId, newCantidad);
    } else {
      await SQHelper.addToCart(
        productId: productId,
        nombre: nombre,
        precio: precio,
        cantidad: cantidad,
        imagen: imagen,
      );
    }
  }
}
