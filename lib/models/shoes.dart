
import 'dart:convert';

class Product {
  final String id;
  final String brand;
  final String shoeName;
  final String thumbnail;
  final double retailPrice;
  final String? colorway;
  final DateTime? releaseDate;

  Product({
    required this.id,
    required this.brand,
    required this.shoeName,
    required this.thumbnail,
    required this.retailPrice,
    this.colorway,
    this.releaseDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      return Product(
        id: json['_id'],
        brand: json['brand'],
        shoeName: json['shoeName'],
        thumbnail: json['thumbnail'],
        retailPrice: (json['retailPrice'] ?? 0).toDouble(),
        colorway: json['colorway'],
        releaseDate: _parseDate(json['releaseDate']),
      );
    } catch (e) {
      // Log detailed information about the error
      print('Error parsing product data: $e');
      print('Failed JSON: ${jsonEncode(json)}');
      rethrow; // Optionally rethrow the exception if you want to handle it further up
    }
  }

  static DateTime? _parseDate(dynamic dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      // Handle unexpected date formats here
      print('Error parsing date: $dateString');
      return null;
    }
  }
}
