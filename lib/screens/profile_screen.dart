import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/provider/profileprovider.dart';
import 'package:sole_mate/provider/theme_provider.dart';
import 'package:sole_mate/screens/editprofile.dart';
import 'package:sole_mate/screens/preference.dart';
import 'package:sole_mate/screens/shoesizescreen.dart';
import 'package:sole_mate/widgets/customgradient_button.dart';

import './authentication/signin.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = "unknown";
  String email = "example@gmail.com";
  XFile? _image;

  Future<void> _navigateToEditProfile(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilePage(
          name: name,
          email: email,
          image: _image,
        ),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        name = result['name'];
        // email = result['email'];
        _image = result['image'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final profileProvider = Provider.of<ProfileProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 50),
                    Text(
                      'Profile',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        themeProvider.themeMode == ThemeMode.dark
                            ? Icons.light_mode
                            : Icons.dark_mode,
                      ),
                      onPressed: () {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xff16B6F0), Color(0xff53C9E7)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: ClipOval(
                        child: profileProvider.profileImageUrl.isNotEmpty
                            ? Image.network(
                                profileProvider.profileImageUrl,
                                fit: BoxFit.cover,
                                width: 100,
                                height: 100,
                              )
                            : SvgPicture.asset(
                                'assets/svgicons/male.svg',
                                width: 75,
                                height: 75,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  profileProvider.name,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  profileProvider.email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10),
                GradientButton(
                  text: "Edit Profile",
                  onPressed: () {
                    _navigateToEditProfile(context);
                  },
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF16B6F0),
                          Color(0xFF53C9E7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'Preference',
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PreferenceScreen()));
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF16B6F0),
                          Color(0xFF53C9E7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'Shoe Size',
                    style: theme.textTheme.bodyLarge,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios_outlined),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ShoeSizeScreen()));
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF16B6F0),
                          Color(0xFF53C9E7),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'Logout',
                    style: theme.textTheme.bodyLarge,
                  ),
                  onTap: () {
                    _logoutUser(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
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
