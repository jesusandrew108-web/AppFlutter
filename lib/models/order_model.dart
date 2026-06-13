import 'product_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<ProductModel> products;
  final double total;
  final DateTime date;

  OrderModel({
    required this.id,
    required this.userId,
    required this.products,
    required this.total,
    required this.date,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      products: (json['products'] as List)
          .map((p) => ProductModel.fromJson(p))
          .toList(),
      total: double.tryParse(json['total'].toString()) ?? 0.0,
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'products': products.map((p) => p.toJson()).toList(),
    'total': total,
    'date': date.toIso8601String(),
  };
}
