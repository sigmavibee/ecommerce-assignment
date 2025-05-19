import 'dart:io';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String imageUrl;
  final File? imageFile;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.imageUrl,
    required this.imageFile,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? imageUrl,
    File? imageFile,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFile: imageFile ?? this.imageFile,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'] is double
          ? json['price']
          : double.parse(json['price'].toString()),
      stock: json['stock'],
      imageUrl: json['image_url'],
      imageFile: json['image_file'] != null
          ? File(json['image_file'])
          : null, // Assuming image_file is a file path
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'stock': stock,
        'image_url': imageUrl,
        'is_active': isActive,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
