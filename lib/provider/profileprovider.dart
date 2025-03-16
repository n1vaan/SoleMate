
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/utils/constant/apibase_url.dart';

class ProfileProvider with ChangeNotifier {
  String _name = 'Unknown';
  String _email = 'example@gmail.com';
  String _profileImageUrl = '';
  String? _token;

  String get name => _name;
  String get email => _email;
  String get profileImageUrl => _profileImageUrl;

    // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  ProfileProvider() {
    fetchUserProfile();
  }

  Future<void> fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/user'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _name = data['name'] ?? 'N/A';
        _email = data['email'] ?? 'N/A';
        _profileImageUrl = data['profilePicture'] ?? '';
        notifyListeners();
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      log('Error fetching profile: $e');
    }
  }

  Future<void> updateProfile(String name, XFile? image) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      log("$name");

      String? base64Image;
      if (image != null) {
        final bytes = File(image.path).readAsBytesSync();
        base64Image = base64Encode(bytes);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/user/updateProfile'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          if (base64Image != null) 'profilePicture': base64Image,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _name = data['name'];
        _profileImageUrl = data['profilePicture'];
        notifyListeners();
      } else {
        throw Exception('Failed to update profile');
      }
    } catch (e) {
      log('Error updating profile: $e');
    }
  }
}
