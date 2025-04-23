// firebase_service.dart
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // get current user
  User? get currentUser => _auth.currentUser;

  // anonymous user
  Future<User?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      return result.user;
    } catch (e) {
      print('anonymous log in error: $e');
      return null;
    }
  }

  // upload product
  Future<String?> uploadProduct({
    required String name,
    required double price,
    required String description,
    required List<String> images,
  }) async {
    try {
      // get current user, if no user, sign in anonymously
      User? user = _auth.currentUser;
      if (user == null) {
        print('Did not find user, try sign in anonymously');
        UserCredential result = await _auth.signInAnonymously();
        user = result.user;
        print('anonymously sign in successfully，user ID: ${user?.uid}');
      } else {
        print('current user，ID: ${user.uid}');
      }

      if (user == null) {
        print('user did not find, try again');
        return null;
      }

      // upload picture to Firebase Storage
      List<String> imageUrls = [];
      for (String imagePath in images) {
        File imageFile = File(imagePath);
        String fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageUrls.length}.jpg';
        Reference ref = _storage.ref().child(
          'product_images/${user.uid}/$fileName',
        );

        UploadTask uploadTask = ref.putFile(imageFile);
        TaskSnapshot snapshot = await uploadTask;

        String downloadUrl = await snapshot.ref.getDownloadURL();
        imageUrls.add(downloadUrl);
      }

      // create product ID
      String productId = DateTime.now().millisecondsSinceEpoch.toString();

      // store temp data
      Map<String, dynamic> productData = {
        'id': productId,
        'name': name,
        'price': price, // make sure this is number
        'description': description,
        'imageUrls': imageUrls, // string number
        'userId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('products').doc(productId).set(productData);
      try {
        await _firestore.collection('products').doc(productId).set(productData);

        return productId;
      } catch (e) {
        print('Firestore write error: $e');
        print('wrong stack: ${StackTrace.current}');
        return null;
      }
    } catch (e) {
      print('product upload error: $e');
      print('wrong stack: ${StackTrace.current}');
      return null;
    }
  }

  // get all products
  Stream<List<Map<String, dynamic>>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            Map<String, dynamic> data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // get single product
  Future<Map<String, dynamic>?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }
      return null;
    } catch (e) {
      print('get product error: $e');
      return null;
    }
  }

  // delete product
  Future<bool> deleteProduct(String productId) async {
    try {
      // get product info and delete images.
      DocumentSnapshot doc =
          await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // delete images in storage
        List<dynamic> imageUrls = data['imageUrls'] ?? [];
        for (String url in List<String>.from(imageUrls)) {
          try {
            // implement using url
            Reference ref = _storage.refFromURL(url);
            await ref.delete();
          } catch (e) {
            print('delete image error: $e');
            // continue
          }
        }

        // delete doc in firebase
        await _firestore.collection('products').doc(productId).delete();
        return true;
      }
      return false;
    } catch (e) {
      print('delete product error: $e');
      return false;
    }
  }
}

final firebaseService = FirebaseService();
