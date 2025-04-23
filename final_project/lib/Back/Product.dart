import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final List<String> imageUrls;
  final String userId;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.userId,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  factory Product.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // handling possible data types.
    double price = 0.0;
    if (data['price'] != null) {
      if (data['price'] is double) {
        price = data['price'];
      } else if (data['price'] is int) {
        price = (data['price'] as int).toDouble();
      } else if (data['price'] is String) {
        price = double.tryParse(data['price']) ?? 0.0;
      }
    }

    List<String> imageUrls = [];
    if (data['imageUrls'] != null) {
      if (data['imageUrls'] is List) {
        imageUrls = List<String>.from(data['imageUrls']);
      }
    }

    // deal with timestamps
    DateTime createdAt = DateTime.now();
    if (data['createdAt'] != null) {
      if (data['createdAt'] is Timestamp) {
        createdAt = (data['createdAt'] as Timestamp).toDate();
      }
    }

    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      price: price,
      description: data['description'] ?? '',
      imageUrls: imageUrls,
      userId: data['userId'] ?? '',
      createdAt: createdAt,
    );
  }

  // cast product type into firebase docs
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'price': price,
      'description': description,
      'imageUrls': imageUrls,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // create copy of the product
  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    List<String>? imageUrls,
    String? userId,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
