// lib/models/filterproductmodel.dart

class ProductFilter {
  final String? colorway;
  final double minRetailPrice;
  final double maxRetailPrice;
  final String? startReleaseDate;
  final String? endReleaseDate;

  ProductFilter({
    this.colorway,
    required this.minRetailPrice,
    required this.maxRetailPrice,
    this.startReleaseDate,
    this.endReleaseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'colorway': colorway,
      'minRetailPrice': minRetailPrice,
      'maxRetailPrice': maxRetailPrice,
      'startReleaseDate': startReleaseDate,
      'endReleaseDate': endReleaseDate,
    };
  }
}
