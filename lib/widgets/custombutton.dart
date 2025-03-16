
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final Future<void> Function()? onPressed;
  final double? widthFactor; // Optional width factor relative to screen width
  final double height;
  final double borderRadius;
  final bool isLoading; // Loading state indicator

  const CustomButton({
    required this.text,
    this.onPressed,
    this.widthFactor,
    this.height = 54,
    this.borderRadius = 12.0,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final buttonColor = isDarkMode ? Colors.white : Colors.black;
    final textColor = isDarkMode ? Colors.black : Colors.white;

    double screenWidth = MediaQuery.of(context).size.width;
    double buttonWidth = (widthFactor != null) ? screenWidth * widthFactor! : screenWidth * 0.8;

    return GestureDetector(
      onTap: isLoading ? null : () async {
        if (onPressed != null) {
          await onPressed!(); 
        }
      },
      child: Container(
        width: buttonWidth,
        height: height,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Center(
          child: isLoading
              ? CircularProgressIndicator(color: isDarkMode ?  Colors.black : Colors.white) 
              : Text(
                  text,
                  style: theme.textTheme.labelLarge?.copyWith(color: textColor),
                ),
        ),
      ),
    );
  }
}
