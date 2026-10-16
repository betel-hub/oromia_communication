class Product {
  final String id;
  final String name;
  final String? description;
  final double price;
  final String currency;
  final String imageUrl;
  final String? category;
  final int stock;
  final bool purchased;
  final bool canRead;

  Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    this.currency = 'ETB',
    required this.imageUrl,
    this.category,
    this.stock = 0,
    this.purchased = false,
    this.canRead = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: (json['id'] ?? json['shop_id'] ?? '').toString(),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      description:
          (json['description'] ?? json['summary'] ?? '').toString(),
      price: _toDouble(json['price'] ?? json['amount']),
      currency: (json['currency'] ?? 'ETB').toString(),
      imageUrl:
          (json['image_url'] ?? json['thumbnail'] ?? json['image'] ?? '')
              .toString(),
      category: json['category']?.toString(),
      stock: _toInt(json['stock']),
      purchased: json['purchased'] == true,
      canRead: json['can_read'] == true,
    );
  }

  String get formattedPrice => '${price.toStringAsFixed(0)} $currency';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'currency': currency,
        'image_url': imageUrl,
        'category': category,
        'stock': stock,
        'purchased': purchased,
        'can_read': canRead,
      };
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get subtotal => product.price * quantity;
}

int _toInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

double _toDouble(dynamic value) {
  if (value == null) return 0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0;
  return 0;
}