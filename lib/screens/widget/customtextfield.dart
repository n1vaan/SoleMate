import 'package:flutter/material.dart';

class Texfieldcustom extends StatelessWidget {
  const Texfieldcustom({
    Key? key,
    required this.controller,
    this.labelText = 'Email', 
  }) : super(key: key);

  final TextEditingController controller;
  final String labelText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.blue.shade200, 
            width: 2.0, // Border width
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            color: Colors.blue.shade400, 
            width: 2.0, 
          ),
        ),
        labelStyle: TextStyle(color: Colors.blue.shade800), 
      ),
    );
  }
}
