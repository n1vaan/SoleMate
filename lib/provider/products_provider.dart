import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/models/filterproductmodel.dart';
import 'package:sole_mate/models/shoes.dart';
import 'package:sole_mate/utils/constant/apibase_url.dart';

class ProductProvider with ChangeNotifier {
  String? _token;
  String? _gender;
  Set<String> _brands = {};
  List<Product> _products = [];
  bool _isLoading = false;
  bool _hasMoreProducts = true;
  bool _hasFetchedAllProducts = false;
  int _currentPage = 1;

  Set<String> _existingProductIds = {};
  ProductFilter? _currentFilter;

  String get baseUrl => Constants.apiBaseUrl;

  String? get token => _token;
  String? get gender => _gender;
  Set<String> get brands => _brands;
  List<Product> get products => _products.isNotEmpty ? _products : [];
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMoreProducts;

  ProductProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.microtask(() => _initialize());
    });
  }

  Future<void> _initialize() async {
    await fetchPreferences();
    if (!_hasFetchedAllProducts && _token != null) {
      final lastPageData = await getLastPageData();
      if (lastPageData != null) {
        _currentPage = lastPageData['pageNumber'] ?? 1;
      }
      await fetchProducts(page: _currentPage);
    }
  }

  Future<void> fetchPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    log('Fetched auth_token: $_token');
    _gender = prefs.getString('selected_gender');
    _brands = prefs.getStringList('selected_brands')?.toSet() ?? {};
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getLastPageData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? pageNumber = prefs.getInt('lastPageNumber');
    // String? productId = prefs.getString('lastProductId');
  
    if (pageNumber != null) {
      return {'pageNumber': pageNumber};
    }
    return {'pageNumber': 1}; // Default to page 1 if no data is found
  }

  Future<void> saveLastPageData(int pageNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastPageNumber', pageNumber);
    // await prefs.setString('lastProductId', productId);
  }

  Future<List<Product>> fetchProducts({int page = 1}) async {
    if (_token == null ||
        _gender == null ||
        _brands.isEmpty ||
        _hasFetchedAllProducts) return [];

    if (_isLoading) return [];

    _isLoading = true;
    
    log("Fetching products for page $page");
    final url = '$baseUrl/product/get-products?page=$page';

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _isLoading = false;
        notifyListeners();
        return [];
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

      final queryParams = {
        'brands': _brands.join(','),
      };

      final uri = Uri.parse(url).replace(queryParameters: queryParams);

      log('API Request URL: $uri');
      log('API Request Headers: $headers');

      final response = await http.post(
        Uri.parse(url),
        headers: headers);

      log('API Response Status Code: ${response.statusCode}');
      log('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final List<dynamic> productsList = data['products'];
        log("ProductList: ${json.encode(productsList)}");
        if (productsList.isEmpty) {
          _hasMoreProducts = false;
          _hasFetchedAllProducts = true;
          log("No more products");
          return [];
        } else {
          final newProducts = productsList
              .map((item) => Product.fromJson(item))
              .where((product) => !_existingProductIds.contains(product.id))
              .toList();

          if (newProducts.isNotEmpty) {
            _products.addAll(newProducts);
            await saveLastPageData(page,);
            log("Returning new products");
            return newProducts;
          } else {
            log("No new products");
            _hasMoreProducts = false;
            return [];
          }
        }
      } else {
        _hasMoreProducts = false;
        return [];
      }
    } catch (e) {
      log("Error fetching products: $e");
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Product>> fetchFilteredProducts(
      {int page = 1, required ProductFilter filter}) async {
    if (_token == null || _gender == null) return [];

    if (_isLoading) return [];

    _isLoading = true;
    Future.microtask(() => notifyListeners());

    final url = '$baseUrl/product/get-products?page=$page';

    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _isLoading = false;
        Future.microtask(() => notifyListeners());
        return [];
      }

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

      final body = jsonEncode(filter.toMap());

      log('API Request URL: $url');
      log('API Request Headers: $headers');
      // log('API Request Body: $body');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      log('API Response Status Code: ${response.statusCode}');
      // log('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final List<dynamic> productsList = data['products'];

        if (productsList.isEmpty) {
          _hasMoreProducts = false;
          return [];
        } else {
          final newProducts = productsList
              .map((item) => Product.fromJson(item))
              .where((product) => !_existingProductIds.contains(product.id))
              .toList();

          if (newProducts.isNotEmpty) {
            _products.addAll(newProducts);
            newProducts
                .forEach((product) => _existingProductIds.add(product.id));
            return newProducts;
          } else {
            _hasMoreProducts = false;
            return [];
          }
        }
      } else {
        _hasMoreProducts = false;
        return [];
      }
    } catch (e) {
      print("Error fetching filtered products: $e");
      return [];
    } finally {
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    }
  }

  Future<List<Product>> fetchMoreProducts() async {
    if (!_hasMoreProducts || _isLoading) return [];

    _currentPage += 1; // Increment the current page
    log("Fetching page: $_currentPage");

    _isLoading = false;
    notifyListeners();

    try {
      List<Product> newProducts;
      if (_currentFilter != null) {
        log("Calling filtered products.");
        newProducts = await fetchFilteredProducts(
            page: _currentPage, filter: _currentFilter!);
      } else {
        log("Calling fetch products.");
        newProducts = await fetchProducts(page: _currentPage);
      }

      log("API Response for page $_currentPage: ${newProducts.length} products");

      if (newProducts.isNotEmpty) {
        //_products.addAll(newProducts); // Add the new products
        newProducts.forEach((product) => _existingProductIds.add(product.id));
      } else {
        _hasMoreProducts = false; // No more products to fetch
      }

      log("New page fetched: ${newProducts.length} products");
      return newProducts;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }



  Future<void> applyFilters(ProductFilter filter) async {
    _currentFilter = filter;
    await reloadProducts();
  }

  Future<void> clearFilters() async {
    _currentFilter = null;
    clearFilteredProducts();
    await fetchProducts(); 
  }

  Future<void> reloadProducts() async {
    try {
      await resetProvider();
      if (_currentFilter != null) {
        await fetchFilteredProducts(filter: _currentFilter!);
      } else {
        await fetchProducts();
      }
      log("API Response: ${products.length} products fetched");
      log("First few products: ${products.take(5).map((p) => p.id).toList()}");

      notifyListeners();

    } catch (error) {
      log("Error fetching products: $error");
    }
  }


void clearFilteredProducts() {
  _products.clear(); 
  notifyListeners(); 
}
 

  Future<void> resetProvider() async {
    _products.clear();
    _existingProductIds.clear();
    _hasMoreProducts = true;
    _hasFetchedAllProducts = false;
    _currentPage = 1;
    log("Provider reset. Products cleared.");
    notifyListeners();
  }


  Future<void> filterresetProvider() async {
    _products.clear();
    log("Provider reset. Products cleared.");
    notifyListeners();
  }

  Future<void> dislikeProduct(String productId) async {
    final url = '$baseUrl/product/disLikedProducts';
    try {
      await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'id': productId}),
      );
    } catch (e) {
      log("Error disliking product: $e");
    }
  }

  Future<void> favoriteProduct(String productId) async {
    final url = '$baseUrl/product/favoritized';
    try {
      await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'id': productId}),
      );
    } catch (e) {
      log("Error favoriting product: $e");
    }
  }

  Future<void> likeProduct(String productId) async {
    final url = '$baseUrl/product/LikeProduct';
    try {
      await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
        body: json.encode({'id': productId}),
      ).then((value) => {
        log('Liked Product Response: ${value.body}')
      });
    } catch (e) {
      log("Error liking product: $e");
    }
  
  }
}