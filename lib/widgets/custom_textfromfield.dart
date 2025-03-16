
import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final bool isNumber;
  final bool isPassword;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    Key? key,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.isNumber = false,
    this.isPassword = false,
    this.validator,
  }) : super(key: key);

  @override
  _CustomTextFormFieldState createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.isNumber ? TextInputType.number : TextInputType.text,
      obscureText: widget.isPassword && !_isPasswordVisible,
      style: theme.textTheme.bodyLarge,
      validator: widget.validator,
      decoration: InputDecoration(
        prefixIcon: Icon(widget.icon, color: theme.iconTheme.color),
        hintText: widget.hintText,
        hintStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.inputDecorationTheme.border?.borderSide.color ?? Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.inputDecorationTheme.focusedBorder?.borderSide.color ?? Colors.grey,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.inputDecorationTheme.enabledBorder?.borderSide.color ?? Colors.grey,
          ),
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: theme.iconTheme.color,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }
}
