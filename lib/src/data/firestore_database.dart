import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_project_baws/src/domain/clothing_Item.dart';
import 'package:my_project_baws/src/domain/user.dart';

import 'database_repository.dart';

class FirestoreDatabase implements DatabaseRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  List<ClothingItem> cart = [];

  @override
  List<ClothingItem> products = [];

  @override
  Future<List<ClothingItem>> getProducts() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('products').get();
      products = snapshot.docs
          .map(
              (doc) => ClothingItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return products;
    } catch (e) {
      print('Error getting products: $e');
      return [];
    }
  }

  @override
  Future<List<ClothingItem>> getCart() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('cart').get();
      cart = snapshot.docs
          .map(
              (doc) => ClothingItem.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      return cart;
    } catch (e) {
      print('Error getting cart: $e');
      return [];
    }
  }

  @override
  Future<void> addItemToCart(ClothingItem clothingItem, User user) async {
    try {
      user.addClothingToBasket(clothingItem);
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeItemFromCart(ClothingItem clothingItem) async {
    try {
      await _firestore.collection('cart').doc(clothingItem.id).delete();
      cart.removeWhere((item) => item.id == clothingItem.id);
    } catch (e) {
      print('Error removing item from cart: $e');
      rethrow;
    }
  }

  Future<void> addProduct(ClothingItem clothingItem) async {
    try {
      await _firestore
          .collection('products')
          .doc(clothingItem.id)
          .set(clothingItem.toMap());
      products.add(clothingItem);
    } catch (e) {
      print('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(ClothingItem clothingItem) async {
    try {
      await _firestore
          .collection('products')
          .doc(clothingItem.id)
          .update(clothingItem.toMap());
      int index = products.indexWhere((item) => item.id == clothingItem.id);
      if (index != -1) {
        products[index] = clothingItem;
      }
    } catch (e) {
      print('Error updating product: $e');
      rethrow;
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      products.removeWhere((item) => item.id == productId);
    } catch (e) {
      print('Error deleting product: $e');
      rethrow;
    }
  }
}
