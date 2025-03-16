import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sole_mate/screens/authentication/signin.dart';
import 'package:sole_mate/utils/constant/apibase_url.dart';
import 'package:sole_mate/widgets/customgradient_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;

  const ChangePasswordScreen({required this.email});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // bool _isLoading = false;

  // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
    log('ChangePasswordScreen initialized with email: ${widget.email}');
  }

  Future<void> _changePassword() async {
    log('Attempting to change password...');
    if (_newPasswordController.text != _confirmPasswordController.text) {
      log('Passwords do not match');
      _showPopup('Passwords do not match', false);
      return;
    }

    setState(() {
      // _isLoading = true;
    });

    final url = '$baseUrl/user/resetPassword';
    log('Sending PUT request to $url with email: ${_emailController.text}, OTP: ${_otpController.text}');

    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'email': _emailController.text,
        'otp': _otpController.text,
        'password': _newPasswordController.text,
        'confirmPassword': _confirmPasswordController.text,
      }),
    );

    log('Received response with status code: ${response.statusCode}');
    final responseData = json.decode(response.body);
    log('Response data: $responseData');

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (responseData['message'] == 'Password has been Change') {
        log('Password successfully updated');
        _showPopup('Password successfully updated', true);
      }
    } else if (response.statusCode == 400) {
      log('Failed to update password: ${responseData['message']}');

      // Show combined message for invalid OTP and password length
      String errorMessage = 'Invalid OTP';

      if (_newPasswordController.text.length < 8) {
        errorMessage += ' and password should be at least 8 characters';
      }

      _showPopup(errorMessage, false);
    } else {
      log('Error: ${response.reasonPhrase}');
      _showPopup('Error: ${response.reasonPhrase}', false);
    }
  }

  void _showPopup(String message, bool isSuccess) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isSuccess ? Colors.green : Colors.red,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    if (isSuccess) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const LoginScreen()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      'Change Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Enter Your email',
                  readOnly: true,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _otpController,
                  labelText: 'Enter Your OTP Code',
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _newPasswordController,
                  labelText: 'Enter your new password',
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _confirmPasswordController,
                  labelText: 'Retype your password',
                  obscureText: true,
                ),
                const SizedBox(height: 40),
                GradientButton(
                  text: "Change Password",
                  onPressed: _changePassword,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final bool readOnly;

  const CustomTextField({
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        filled: true,
        fillColor: Colors.transparent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.grey,
          ),
        ),
      ),
      style: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black,
      ),
    );
  }
}
