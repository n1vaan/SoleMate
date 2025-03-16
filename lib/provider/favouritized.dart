import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/models/shoes.dart';
import 'package:sole_mate/utils/constant/apibase_url.dart';

class FavouriteProvider with ChangeNotifier {
  String? _token;
  bool _hasInternet = true;
  List<Product> _favoritedProducts = [];

  String get baseUrl => Constants.apiBaseUrl;

  List<Product> get favoritedProducts => _favoritedProducts;
  bool get hasInternet => _hasInternet;

  FavouriteProvider() {
    fetchPreferences().then((_) {
      fetchFavoritedProducts();
    });
  }

  Future<void> fetchPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token == null || _token!.isEmpty) {
      log('Token is null or empty');
    } else {
      log('Token retrieved: $_token');
    }
    notifyListeners();
  }

  Future<void> fetchFavoritedProducts() async {
    final url = '$baseUrl/product/get-favoritized';

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _hasInternet = false;
      notifyListeners();
      log('No internet connection');
      return;
    }

    _hasInternet = true;
    log('Internet connection available');

    try {
      if (_token == null || _token!.isEmpty) {
        log('Token is missing');
        return;
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );

      log('Favorited Products Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> favoriteProductsData = data['favoriteProducts'] ?? [];
        
        _favoritedProducts = await Future.wait(
          favoriteProductsData.map((productData) => _parseProductData(productData)).toList(),
        );
        notifyListeners();
      } else {
        log('Failed to fetch favorited products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error fetching favorited products: $e');
    }
  }

  Future<Product> _parseProductData(dynamic productData) async {
    try {
      return Product.fromJson(productData);
    } catch (e) {
      log('Error parsing product data: $e');
      return Product(id: '', brand: '', shoeName: '', thumbnail: '', retailPrice: 0.0);
    }
  }

  Future<void> removeFavoritedProduct(String productId) async {
    final url = '$baseUrl/product/remove-favorite';

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _hasInternet = false;
      notifyListeners();
      log('No internet connection');
      return;
    }

    _hasInternet = true;

    try {
      if (_token == null || _token!.isEmpty) {
        log('Token is missing');
        return;
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'productId': productId}),
      );

      log('Remove Favorite Product Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        // Remove the product from the local list
        _favoritedProducts.removeWhere((product) => product.id == productId);
        notifyListeners();
        log('Product removed from favorites successfully');
      } else if (response.statusCode == 400) {
        log('Failed to remove product from favorites: ${response.body}');
        // You might want to show an error message to the user here
      } else {
        log('Failed to remove product from favorites. Status code: ${response.statusCode}');
      }
    } catch (e) {
      log('Error removing product from favorites: $e');
    }
  }
}