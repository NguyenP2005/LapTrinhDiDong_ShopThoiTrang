import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        return _createTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS cart');
          await _createTable(db);
        }
      },
      version: 2,
    );
  }

  Future<void> _createTable(Database db) async {
    await db.execute('''
      CREATE TABLE cart(
        userId TEXT,
        productId TEXT,
        name TEXT,
        price REAL,
        image TEXT,
        quantity INTEGER,
        PRIMARY KEY (userId, productId)
      )
    ''');
  }

  Future<String> _getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('current_user');
    if (userStr != null) {
      try {
        final user = jsonDecode(userStr);
        return user['id'].toString();
      } catch (e) {
        debugPrint('cart_service: failed to parse userId: $e');
      }
    }
    return 'guest';
  }

  // Lấy tất cả items trong giỏ hàng của user hiện tại
  Future<List<CartItem>> getCartItems() async {
    final db = await database;
    final userId = await _getUserId();
    final maps = await db.query(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return maps.map((e) => CartItem.fromMap(e)).toList();
  }

  // Thêm hoặc cập nhật số lượng nếu sản phẩm đã tồn tại trong giỏ của user
  Future<void> addToCart(CartItem item) async {
    final db = await database;
    final userId = await _getUserId();
    final existing = await db.query(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, item.productId],
    );

    if (existing.isNotEmpty) {
      // Tăng số lượng nếu sản phẩm đã có trong giỏ
      final currentQty = existing.first['quantity'] as int;
      await db.update(
        'cart',
        {'quantity': currentQty + item.quantity},
        where: 'userId = ? AND productId = ?',
        whereArgs: [userId, item.productId],
      );
    } else {
      final map = item.toMap();
      map['userId'] = userId;
      await db.insert('cart', map);
    }
  }

  Future<void> removeFromCart(String productId) async {
    final db = await database;
    final userId = await _getUserId();
    await db.delete(
      'cart', 
      where: 'userId = ? AND productId = ?', 
      whereArgs: [userId, productId],
    );
  }

  Future<void> updateQuantity(String productId, int newQuantity) async {
    final db = await database;
    final userId = await _getUserId();
    await db.update(
      'cart',
      {'quantity': newQuantity},
      where: 'userId = ? AND productId = ?',
      whereArgs: [userId, productId],
    );
  }

  Future<void> clearCart() async {
    final db = await database;
    final userId = await _getUserId();
    await db.delete(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }
}
