import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/provider/auth_provider.dart';
import 'package:sole_mate/screens/authentication/signup.dart';
import 'package:sole_mate/screens/bottomapbar.dart';
import 'package:sole_mate/screens/gender_select.dart';
import 'package:sole_mate/widgets/custom_textfromfield.dart';
import 'package:sole_mate/widgets/custombutton.dart';

import 'forgetpassword.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkSavedLoginAndRedirect(context);
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    signInOption: SignInOption.standard,
  );

  Future<void> handleGoogleSignIn() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final String? accessToken = googleAuth.accessToken;

        if (accessToken != null) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          final success = await authProvider.googleLogin(
            name: googleUser.displayName ?? 'Google User',
            email: googleUser.email,
            profilePicture: googleUser.photoUrl,
            accessToken: accessToken,
          );

          if (success && mounted) {
            // Check gender and brands after successful login
            final prefs = await SharedPreferences.getInstance();
            final gender = prefs.getString('selected_gender');
            final brands = prefs.getStringList('selected_brands');

            if (gender != null && brands != null && brands.isNotEmpty) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const CustomBottomNavBar()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const GenderScreen()),
              );
            }
          } else {
            throw Exception('Google login failed');
          }
        }
      }
    } catch (e) {
      setState(
          () => _errorMessage = 'Google sign in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void showSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.red}) {
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

  String? emailValidator(String? value) {
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );

    if (value == null || value.isEmpty) {
      return 'Please enter your email address';
    } else if (!emailRegExp.hasMatch(value)) {
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
                          "Sign In",
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 15),
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
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ForgotPasswordScreen()),
                              );
                            },
                            child: Text(
                              "Forgot Password?",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_errorMessage.isNotEmpty)
                          Text(
                            _errorMessage,
                            style: const TextStyle(color: Colors.red),
                          ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child:
                                  Text('OR', style: theme.textTheme.bodyMedium),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: screenSize.width * 0.8,
                          child: Column(
                            children: [
                              // Google Sign In Button
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black87,
                                    // backgroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                          text: "Sign In",
                          isLoading: _isLoading,
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              final email = _emailController.text.trim();
                              final password = _passwordController.text.trim();

                              setState(() {
                                _errorMessage = '';
                                _isLoading = true;
                              });

                              try {
                                // Perform login
                                await Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .login(email, password, context);
                              } catch (error) {
                                setState(() {
                                  // Set specific error message based on the error
                                  if (error.toString().contains(
                                      'Email or Password Incorrect')) {
                                    _errorMessage =
                                        'Email or password is incorrect';
                                  } else {
                                    _errorMessage = error.toString();
                                  }
                                });

                                // // Show error message in a snackbar
                                // showSnackBar(context, _errorMessage);
                              } finally {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            }
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen()),
                                );
                              },
                              child: Text(
                                "Sign Up",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
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
