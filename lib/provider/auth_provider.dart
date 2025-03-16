import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/screens/bottomapbar.dart';
import 'package:sole_mate/screens/gender_select.dart';
import 'package:sole_mate/utils/constant/apibase_url.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  String get token => _token ?? '';

  
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;


  // Base URL from Constants
  String get baseUrl => Constants.apiBaseUrl;

  // Initialize auth state on app start
  Future<void> initAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _isLoggedIn = _token != null;
    notifyListeners();
  }



  //Google Auth
  Future<bool> googleLogin({
    required String name,
    required String email,
    required String? profilePicture,
    required String accessToken,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/google-login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'profilePicture': profilePicture,
          'accessToken': accessToken,
        }),
      );

      log('Google Login Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true) {
          // Save user data and token
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', data['token']);
          await prefs.setString('user_name', data['user']['name']);
          await prefs.setString('user_email', data['user']['email']);
          await prefs.setString('user_id', data['user']['_id']);
          await prefs.setBool('is_google_user', true);
          if (data['user']['profilePicture'] != null) {
            await prefs.setString('profile_picture', data['user']['profilePicture']);
          }

          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (e) {
      log('Google Login Error: $e');
      return false;
    }
  }


  // Signup function
  Future<bool> register(String name, String email, String password) async {
    final url = '$baseUrl/user/register';
    try {
      log('Attempting to register with URL: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'email': email, 'password': password}),
      );

      log('Registration response status code: ${response.statusCode}');
      log('Registration response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        log('Registration successful');
        final responseData = jsonDecode(response.body);

        final token = responseData['token'] as String?;
        if (token != null) {
          _token = token;
          // In the register method
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', _token!);
          log('Saved auth_token: ${prefs.getString('auth_token')}');

          // Notify listeners if needed
          notifyListeners();
          return true; 
        } else {
          throw Exception('Token not found in response');
        }
      } else if (response.statusCode == 409 || response.statusCode == 400) {
        throw Exception('User already registered');
      } else {
        throw Exception('Failed to register: ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      log('ClientException during registration: $e');
      throw Exception(
          'Connection failed. Please check your internet connection.');
    } catch (error) {
      log('Error during registration: $error');
      throw Exception('Failed to register: $error');
    }
  }



//logout function
  Future<void> login(
      String email, String password, BuildContext context) async {
    final url = '$baseUrl/user/login';
    try {
      log('Attempting to login with URL: $url');
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      log('Login response status code: ${response.statusCode}');
      log('Login response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final String token = responseData['token'];
        final Map<String, dynamic> userData = responseData['user'];

        // Save token to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        log('Saved auth_token: ${prefs.getString('auth_token')}');

        // Check if gender and brands are available
        final String? gender = userData['gender'];
        final List<String> brands = List<String>.from(userData['brands'] ?? []);

        if (gender != null && brands.isNotEmpty) {
          // Save gender and brands to SharedPreferences
          await prefs.setString('selected_gender', gender);
          await prefs.setStringList('selected_brands', brands);
          log('Saved selected_gender: $gender');
          log('Saved selected_brands: $brands');

          // Navigate to CustomBottomNavBar if data is available
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => const CustomBottomNavBar()),
            );
          }
        } else {
          // Navigate to GenderScreen if data is missing
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GenderScreen()),
            );
          }
        }

        notifyListeners();
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        throw Exception('Email or Password Incorrect');
      } else if (response.statusCode == 404) {
        throw Exception('User not found');
      } else {
        throw Exception('Login failed: ${response.reasonPhrase}');
      }
    } on http.ClientException catch (e) {
      log('ClientException during login: $e');
      throw Exception(
          'Connection failed. Please check your internet connection.');
    } catch (error) {
      log('Error during login: $error');
      throw Exception('Login failed: $error');
    }
  }




//check user login status
Future<void> checkSavedLoginAndRedirect(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/verify-token'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final gender = data['user']['gender'];
        final brands = List<String>.from(data['user']['brands'] ?? []);

        if (gender != null && brands.isNotEmpty) {
          await prefs.setString('selected_gender', gender);
          await prefs.setStringList('selected_brands', brands);
          
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const CustomBottomNavBar()),
            );
          }
        } else {
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const GenderScreen()),
            );
          }
        }
      }
    } catch (e) {
      log('Verify Token Error: $e');
      await prefs.remove('auth_token');
    }
  }

}
