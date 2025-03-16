import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sole_mate/screens/authentication/resetpassword.dart';
import 'package:sole_mate/utils/constant/apibase_url.dart';
import 'package:sole_mate/widgets/customgradient_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

    // Use a getter for the base URL
  String get baseUrl => Constants.apiBaseUrl;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text;
    final url = '$baseUrl/user/forgetPassword';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        _showSnackBar(
          message: 'Email sent to $email',
          backgroundColor: Colors.green,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChangePasswordScreen(email: email),
          ),
        );
      } else {
        _showSnackBar(
          message: 'Failed to send email',
          backgroundColor: Colors.red,
        );
      }
    } else {
      _showSnackBar(
        message: 'Error: ${response.reasonPhrase}',
        backgroundColor: Colors.red,
      );
    }
  }

  void _showSnackBar({required String message, required Color backgroundColor}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
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
                      'Forgot Password',
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
                  labelText: 'Enter your Email',
                ),
                const SizedBox(height: 20),
                GradientButton(
                  text: "Reset password",
                  onPressed: () {
                    _resetPassword();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
