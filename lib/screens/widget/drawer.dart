
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/screens/authentication/forgetpassword.dart';
import 'package:sole_mate/screens/widget/customdrawerheader.dart';

import '../authentication/signin.dart';
import '../favouriteitems.dart';
import '../supportscreen.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          CustomDrawerHeader(),
          const SizedBox(height: 20),
          _buildListTile(
            context,
            title: 'Saved',
            iconPath: 'assets/icons/bookmark.png',
            isDarkMode: isDarkMode,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoritedProductsScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildListTile(
            context,
            title: 'Change password',
            iconData: Icons.password_sharp,
            isDarkMode: isDarkMode,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
            ),
          ),
          const SizedBox(height: 10),
          _buildListTile(
            context,
            title: 'Support',
            iconData: Icons.support,
            isDarkMode: isDarkMode,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SupportPage()),
            ),
          ),
          const SizedBox(height: 10),
          _buildListTile(
            context,
            title: 'Logout',
            iconData: Icons.logout_outlined,
            isDarkMode: isDarkMode,
            onTap: () => _logoutUser(context),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(
      BuildContext context, {
        required String title,
        String? iconPath,
        IconData? iconData,
        required bool isDarkMode,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF16B6F0), Color(0xFF53C9E7)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: iconPath != null
              ? Image.asset(
            iconPath,
            color: Colors.white,
            height: 25,
            width: 25,
          )
              : Icon(
            iconData,
            color: Colors.white,
          ),
        ),
      ),
      title: Text(
        title,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      onTap: onTap,
    );
  }

 Future<void> _logoutUser(BuildContext context) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final isGoogleUser = prefs.getBool('is_google_user') ?? false;

    if (isGoogleUser) {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
      await prefs.remove('is_google_user');
      await prefs.remove('auth_token');
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('profile_picture');
    } else {
      await prefs.remove('auth_token');
    }

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  } catch (e) {
    log('Logout Error: $e');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to logout. Please try again.')));
    }
  }
}

}
