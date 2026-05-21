// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  static CollectionReference productCollection =
      FirebaseFirestore.instance.collection('products');

  static Future<void> createOrUpdateProduct(
      String name, int price) async {
    try {
      await productCollection.add({
        'name': name,
        'price': price,
      });
    } catch (e) {
      print(e);
    }
  }

  static Future<void> deleteProduct(String id) async {
    try {
      await productCollection.doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  static Future<void> updateProduct(String id, String name, int price) async {
    try {
      await productCollection.doc(id).update({
        'name': name,
        'price': price,
      });
    } catch (e) {
      print(e);
    }
  }

  static Stream<QuerySnapshot> getProducts() {
    return productCollection.snapshots();
  }
}
