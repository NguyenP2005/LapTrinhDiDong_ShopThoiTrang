import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';

class CartService {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'cart.db'),
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE cart(
            productId TEXT PRIMARY KEY,
            name TEXT,
            price REAL,
            image TEXT,
            quantity INTEGER
          )
        ''');
      },
      version: 1,
    );
  }

  // Lấy tất cả items trong giỏ hàng
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final maps = await db.query('cart');
    return maps.map((e) => CartItem.fromMap(e)).toList();
  }

  // Thêm hoặc cập nhật số lượng nếu sản phẩm đã tồn tại
  Future<void> addToCart(CartItem item) async {
    final db = await database;
    final existing = await db.query(
      'cart',
      where: 'productId = ?',
      whereArgs: [item.productId],
    );

    if (existing.isNotEmpty) {
      // Tăng số lượng nếu sản phẩm đã có trong giỏ
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        'cart',
        {'quantity': currentQty + item.quantity},
        where: 'productId = ?',
        whereArgs: [item.productId],
      );
    } else {
      await db.insert('cart', item.toMap());
    }
  }

  Future<void> removeFromCart(String productId) async {
    final db = await database;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  // Thêm hàm này vào cuối class CartService:
  Future<void> updateQuantity(String productId, int newQuantity) async {
    final db = await database;
    await db.update(
      'cart',
      {'quantity': newQuantity},
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    await db.delete('cart');
  }
}
