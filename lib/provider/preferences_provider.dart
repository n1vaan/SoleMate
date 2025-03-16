import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/services/sharedpreferences.dart';
import 'package:sole_mate/utils/constant/apibase_url.dart';

class PreferenceProvider extends ChangeNotifier {
  final Set<String> _selectedBrands = {};
  String? _gender;

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  Set<String> get selectedBrands => _selectedBrands;
  String? get gender => _gender;

  void toggleBrand(String brand) {
    if (_selectedBrands.contains(brand)) {
      _selectedBrands.remove(brand);
    } else {
      _selectedBrands.add(brand);
    }
    notifyListeners();
  }

  void setGender(String? gender) {
    _gender = gender;
    notifyListeners();
  }

 Future<void> loadPreferences() async {
  // Fetch auth token from SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');

  // Log the fetched token if it is not null or empty
  if (token != null && token.isNotEmpty) {
    // log('Fetched auth_token: $token');
  } else {
    // log('Token is missing');
  }

  // Fetch and log other preferences
  _gender = await SharedPreferencesService.getData('selected_gender');
  final brandsList = await SharedPreferencesService.getStringList('selected_brands');

  if (brandsList != null) {
    _selectedBrands.addAll(brandsList.toSet());
  }

  // Log gender and selected brands
  log('Fetched gender: $_gender');
  log('Fetched selected brands: ${_selectedBrands.toList()}');

  notifyListeners();
}


 Future<bool> sendPreferences(String token) async {
  if (_gender == null || _gender!.isEmpty) {
    return false;
  }

  final url = '$baseUrl/user/updatePrefrence';

  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'gender': _gender,
        'brands': _selectedBrands.toList(),
      }),
    );
       // Log the request headers
  log('Request headers: ${response.request?.headers}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      await SharedPreferencesService.saveData('selected_gender', _gender!);
      await SharedPreferencesService.saveStringList('selected_brands', _selectedBrands.toList());
      log('Updated selected brands: ${_selectedBrands.toList()}');
      return true;
    } else {
      return false;
    }
  } catch (error) {
    log('Network error or unexpected issue: $error');
    return false;
  }
}

}
