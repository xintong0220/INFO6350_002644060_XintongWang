// lib/Pages/BrowsePostsActivity.dart
import 'package:flutter/material.dart';
import 'package:final_project/Components/PostCard.dart';
import 'package:final_project/Components/ActionBar.dart';
import 'package:final_project/Back/Product.dart';
import 'package:final_project/Pages/NewPostActivity.dart';
import 'package:final_project/Pages/ProductDetailView.dart';
import 'package:final_project/Pages/LoginScreen.dart';
import 'package:get/get.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BrowsePostsActivity extends StatefulWidget {
  const BrowsePostsActivity({Key? key}) : super(key: key);

  @override
  _BrowsePostsActivityState createState() => _BrowsePostsActivityState();
}

class _BrowsePostsActivityState extends State<BrowsePostsActivity> {
  Stream<List<Product>> getProducts() {
    return FirebaseFirestore.instance
        .collection('products')
        .orderBy('createdAt', descending: true) // Sort based on create time
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return Product.fromFirestore(doc);
          }).toList();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ActionBar(
        title: 'Browse Posts',
        showBackButton: false,
        showAuthButton: true,
      ),
      body: StreamBuilder<List<Product>>(
        stream: getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Loading error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(
              child: Text('There is no products recording, please add some.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => ProductDetailView(product: product));
                },
                child: PostCard(product: product),
              );
            },
          );
        },
      ),
      floatingActionButton: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // if user logged in, show add product button
          if (snapshot.hasData) {
            return FloatingActionButton(
              onPressed: () async {
                final newProduct = await Get.to<Product>(
                  () => const NewPostActivity(),
                );

                if (newProduct is Product) {
                  Get.snackbar(
                    'Success',
                    'Product "${newProduct.name}" added successfully',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    duration: Duration(seconds: 3),
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: const Icon(Icons.add),
            );
          } else {
            // If user not signed in, show log in button
            return FloatingActionButton(
              onPressed: () {
                Get.snackbar(
                  'Login Required',
                  'Please login to add new products',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  duration: Duration(seconds: 3),
                  snackPosition: SnackPosition.BOTTOM,
                  mainButton: TextButton(
                    child: Text('LOGIN', style: TextStyle(color: Colors.white)),
                    onPressed: () {
                      Get.to(() => LoginScreen());
                    },
                  ),
                );
              },
              child: const Icon(Icons.login),
              backgroundColor: Colors.orange,
            );
          }
        },
      ),
    );
  }
}
