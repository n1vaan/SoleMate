import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sole_mate/provider/profileprovider.dart';
import 'package:sole_mate/widgets/customgradient_button.dart';

class EditProfilePage extends StatefulWidget {
  final String name;
  final String email;
  final XFile? image;

  EditProfilePage({required this.name, required this.email, this.image});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _nameController;
  XFile? _image;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _image = widget.image;
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = pickedFile;
      }
    });
  }

  Future<void> _updateProfile() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    final uri =
        Uri.parse('http://154.38.177.247:3333/user/updateProfile');
    final request = http.MultipartRequest('PUT', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['name'] = _nameController.text;

    if (_image != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profilePicture', _image!.path),
      );
    }

    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        json.decode(responseBody);

        Navigator.pop(context, {'name': _nameController.text, 'image': _image});
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An error occurred')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
     final profileProvider = Provider.of<ProfileProvider>(context);
    final theme = Theme.of(context);


    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_outlined),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Expanded(
                    child: Text(
                      'Edit Profile',
                      textAlign: TextAlign.center, // To center the text
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  if (_isLoading)
                    const CircularProgressIndicator(
                      strokeWidth: 4.0,
                    )
                  else
                    const SizedBox(
                        width: 24), // Ensures spacing when not loading
                ],
              ),
              const SizedBox(height: 30),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: _image != null
                      ? FileImage(File(_image!.path))
                      : const  AssetImage("assets/images/male.png")
                          as ImageProvider,
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Icon(Icons.camera_alt,
                        color: isDarkMode ? Colors.white : Colors.black),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: profileProvider.name,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white : Colors.black,
                      width: 1.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white : Colors.black,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              GradientButton(
                  text: "Save",
                  onPressed: () {
                    _updateProfile();
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
