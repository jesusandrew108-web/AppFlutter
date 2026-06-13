import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';


class SQHelper {
  static Future<sql.Database> db() async {
    final databasePath = await sql.getDatabasesPath();
    final path = join(databasePath, 'tiendita.db');

    return sql.openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onOpen: (db) async {
        await _ensureAdminExists(db);
      },
    );
  }

  static Future<void> _createTables(sql.Database database) async {
    await database.execute("""
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'cliente',
        is_verified INTEGER NOT NULL DEFAULT 0,
        verification_code TEXT,
        nombre TEXT,
        apP TEXT,
        apM TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);

    await database.execute("""
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        nombre_product TEXT NOT NULL,
        precio REAL NOT NULL,
        cantidad INTEGER NOT NULL,
        imagen TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);

    await database.execute("""
      CREATE TABLE cart(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        product_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        precio REAL NOT NULL,
        cantidad INTEGER NOT NULL,
        imagen TEXT,
        addedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
    """);
  }

  static Future<void> _ensureAdminExists(sql.Database db) async {
    final List<Map<String, dynamic>> admins = await db.query(
      'users',
      where: 'role = ?',
      whereArgs: ['administrador'],
      limit: 1,
    );

    if (admins.isEmpty) {
      await db.insert('users', {
        'email': 'admin@tienda.com',
        'password': 'admin',
        'role': 'administrador',
        'is_verified': 1,
        'verification_code': null,
        'nombre': 'Admin',
        'apP': 'Principal',
        'apM': '',
      });
      print('Administrador por defecto creado: admin@tienda.com/admin');
    }
  }

  // 📦 CRUD de productos
  static Future<int> createProduct(
      String name, double price, int quantity, String? imagePath) async {
    final db = await SQHelper.db();
    final data = {
      'nombre_product': name,
      'precio': price,
      'cantidad': quantity,
      'imagen': imagePath,
    };
    return await db.insert('products', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await SQHelper.db();
    return await db.query('products', orderBy: 'id');
  }

  static Future<int> updateProduct(
      int id, String name, double price, int quantity, String? imagePath) async {
    final db = await SQHelper.db();
    final data = {
      'nombre_product': name,
      'precio': price,
      'cantidad': quantity,
      'imagen': imagePath,
      'createdAt': DateTime.now().toString(),
    };
    return await db.update('products', data, where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> deleteProduct(int id) async {
    final db = await SQHelper.db();
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // 🛒 Carrito
  static Future<int> addToCart({
    required int productId,
    required String nombre,
    required double precio,
    required int cantidad,
    String? imagen,
  }) async {
    final db = await SQHelper.db();
    final data = {
      'product_id': productId,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'imagen': imagen,
    };
    return await db.insert('cart', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getCartItems() async {
    final db = await SQHelper.db();
    return await db.query('cart', orderBy: 'addedAt DESC');
  }

  static Future<void> clearCart() async {
    final db = await SQHelper.db();
    await db.delete('cart');
  }

  static Future<void> deleteCartItem(int id) async {
    final db = await SQHelper.db();
    await db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  // 👤 Gestión de usuarios
  static Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await SQHelper.db();
    final results = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  static Future<int> createUser(
    String nombre,
    String apP,
    String apM,
    String email,
    String password,
    String verificationCode,
    String role,
  ) async {
    final db = await SQHelper.db();
    final data = {
      'nombre': nombre,
      'apP': apP,
      'apM': apM,
      'email': email,
      'password': password,
      'verification_code': verificationCode,
      'role': role,
      'is_verified': 0,
    };
    return await db.insert('users', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  static Future<void> verifyUser(String email) async {
    final db = await SQHelper.db();
    await db.update(
      'users',
      {'is_verified': 1},
      where: 'email = ?',
      whereArgs: [email],
    );
  }

  static Future<int> updateUserPassword(String email, String newPassword) async {
    final db = await SQHelper.db();
    final data = {
      'password': newPassword,
      'verification_code': null,
    };
    return await db.update('users', data, where: 'email = ?', whereArgs: [email]);
  }

  static Future<List<Map<String, dynamic>>> getUsers() async {
    final db = await SQHelper.db();
    return await db.query('users', orderBy: 'id');
  }

  static Future<int> updateUserRole(int id, String newRole) async {
    final db = await SQHelper.db();
    final data = {'role': newRole};
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  // helper/db_helper.dart (añade métodos para OTP y mejora seguridad mínima)
static Future<void> updateUserOtp(String email, String otp) async {
  final db = await SQHelper.db();
  await db.update(
    'users',
    {'verification_code': otp},
    where: 'email = ?',
    whereArgs: [email],
  );
}

static Future<void> clearUserOtp(String email) async {
  final db = await SQHelper.db();
  await db.update(
    'users',
    {'verification_code': null},
    where: 'email = ?',
    whereArgs: [email],
  );
}

static Future<void> updateCartItemCantidad(int productId, int newCantidad) async {
  final db = await SQHelper.db(); // ✅ aquí usas tu método db()
  await db.update(
    'cart',
    {'cantidad': newCantidad},
    where: 'product_id = ?', // ✅ nombre correcto de la columna
    whereArgs: [productId],
  );
}


// Sugerencia de seguridad: guarda password hasheado (ver sección Seguridad para cómo aplicar bcrypt en backend).

}
