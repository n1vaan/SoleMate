

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/provider/auth_provider.dart';
import 'package:sole_mate/screens/authentication/signin.dart';
import 'package:sole_mate/screens/gender_select.dart';
import 'package:sole_mate/widgets/custom_textfromfield.dart';
import 'package:sole_mate/widgets/custombutton.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
    ],
    signInOption: SignInOption.standard,
    hostedDomain: "",
  );

  Future<void> handleGoogleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Sign out first to force account picker to show
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        // Get user credentials
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // Get user details
        final String? name = googleUser.displayName;
        final String email = googleUser.email;
        final String? photoUrl = googleUser.photoUrl;
        final String? accessToken = googleAuth.accessToken;

        log('Google Sign In Successful');
        log('Name: $name');
        log('Email: $email');
        log('Photo URL: $photoUrl');
        log('Access Token: $accessToken');

        if (accessToken != null) {
          try {
            final authProvider =
                Provider.of<AuthProvider>(context, listen: false);

            final success = await authProvider.googleLogin(
              name: name ?? 'Google User',
              email: email,
              profilePicture: photoUrl,
              accessToken: accessToken,
            );

            if (success) {
              // Navigate to next screen
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Successfully signed in with Google'),
                    backgroundColor: Colors.green,
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GenderScreen(),
                  ),
                );
              }
            } else {
              throw Exception('Google login failed');
            }
          } catch (e) {
            log('API Error: $e');
            setState(() {
              _errorMessage =
                  'Failed to sign in with Google. Please try again.';
            });
          }
        } else {
          throw Exception('No access token received');
        }
      }
    } catch (e) {
      log('Google Sign In Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Google sign in failed. Please try again.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: screenSize.height * 0.3,
                  child: Center(
                    child: Image.asset(
                      isDarkMode
                          ? 'assets/images/logo.png'
                          : 'assets/images/logoblack.png',
                      fit: BoxFit.contain,
                      width: screenSize.width * 0.6,
                    ),
                  ),
                ),
                SizedBox(
                  width: screenSize.width,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Sign Up",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
                        CustomTextFormField(
                          icon: Icons.person,
                          hintText: "Enter your name",
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          icon: Icons.email,
                          hintText: "Enter your email address",
                          controller: _emailController,
                          validator: emailValidator,
                        ),
                        const SizedBox(height: 8),
                        CustomTextFormField(
                          icon: Icons.password,
                          hintText: "Enter your password",
                          controller: _passwordController,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                        const SizedBox(height: 5),
                        Text(
                          "or Continue with",
                          style:
                              theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 25),
                        Container(
                          width: screenSize.width * 0.8,
                          child: Column(
                            children: [
                              // Google Sign In Button
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                    // backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      side: BorderSide(
                                          color: Colors.grey.shade300),
                                    ),
                                    elevation: 1,
                                  ),
                                  onPressed: handleGoogleSignIn,
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Image.asset(
                                          'assets/icons/google.png',
                                          height: 24,
                                        ),
                                        const Text(
                                          'Sign In with Google',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        const SizedBox(width: 12),
                                      ]))
                            ],
                          ),
                        ),
                  
                        const SizedBox(height: 20),
                        CustomButton(
                          text: "Sign Up",
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final name = _nameController.text;
                              final email = _emailController.text;
                              final password = _passwordController.text;

                              setState(() {
                                _errorMessage = '';
                                _isLoading = true;
                              });

                              try {
                                final authProvider = Provider.of<AuthProvider>(
                                    context,
                                    listen: false);
                                print("[log] Attempting to register user...");

                                final success = await authProvider.register(
                                    name, email, password);

                                if (success) {
                                  final prefs =
                                      await SharedPreferences.getInstance();
                                  await prefs.remove('selected_gender');
                                  await prefs.remove('selected_brands');

                                  if (mounted) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const GenderScreen(),
                                      ),
                                    );
                                  }
                                }
                              } catch (error) {
                                print(
                                    "[log] Error during registration: $error");
                                setState(() {
                                  if (error
                                      .toString()
                                      .contains('User already registered')) {
                                    _errorMessage = 'User already registered';
                                  } else {
                                    _errorMessage = 'Failed to register';
                                  }
                                });
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                                print("[log] Registration process completed.");
                              }
                            }
                          },
                        ),
                      
                            Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Already have an account?",
                              style: theme.textTheme.bodyLarge,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Sign In",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                       
                       
                      
                      
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
