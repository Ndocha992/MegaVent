import 'package:flutter/material.dart';

// Create a constants class to encapsulate constants
class Constants {
  // Cloudinary configuration
  static const String cloudinaryCloudName = 'dvhdyruva';
  static const String cloudinaryApiKey = '426277598191425';
  static const String cloudinaryApiSecret = 'wgqlR3bEORv2_aZailcWS1KW5xY';
}

class AppConstants {
  // Color palette
  static const Color primaryColor = Color(0xFF4361EE);
  static const Color primaryDarkColor = Color(0xFF3A56D4);
  static const Color primaryLightColor = Color(0xFF738AFF);
  static const Color secondaryColor = Color(0xFF48CAE4);
  static const Color accentColor = Color(0xFFFF9F1C);
  static const Color backgroundColor = Color(0xFFF9FAFC);
  static const Color backgroundSecondaryColor = Color(0xFFEEF1F7);
  static const Color textColor = Color(0xFF14181B);
  static const Color textSecondaryColor = Color(0xFF67727E);
  static const Color borderColor = Color(0xFFD9E2EC);
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFE53935);
  static const Color successColor = Color(0xFF2E7D32);
  static const Color warningColor = Color(0xFFFF9800);

  // Gradients
  static const List<Color> splashGradient = [
    Color(0xFF4361EE),
    Color(0xFF3A56D4),
    Color(0xFF2D46C8),
  ];

  static const List<Color> cardGradient = [
    Color(0xFF4361EE),
    Color(0xFF3F5DE0),
  ];

  static const List<Color> accentGradient = [
    Color(0xFFFF9F1C),
    Color(0xFFFF8700),
  ];

  // Text Styles
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headlineLarge = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLarge = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyLargeSecondary = TextStyle(
    fontFamily: 'Poppins',
    color: textSecondaryColor,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMediumSecondary = TextStyle(
    fontFamily: 'Poppins',
    color: textSecondaryColor,
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'Poppins',
    color: textColor,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmallSecondary = TextStyle(
    fontFamily: 'Poppins',
    color: textSecondaryColor,
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Container Decorations
  static BoxDecoration containerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration gradientContainerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: cardGradient,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration accentContainerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: accentGradient,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: accentColor.withOpacity(0.3),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Input Decoration
  static InputDecoration inputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: bodyMediumSecondary,
      hintStyle: bodyMediumSecondary.copyWith(
          color: textSecondaryColor.withOpacity(0.5)),
      prefixIcon: Icon(
        prefixIcon,
        color: primaryColor,
        size: 22,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
    );
  }

  // Button Styles
  static final ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: primaryColor,
    minimumSize: const Size(double.infinity, 56),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: primaryColor,
    backgroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 56),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: BorderSide(color: primaryColor, width: 1.5),
    ),
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: primaryColor,
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 14,
      fontWeight: FontWeight.w600,
    ),
  );

  static final ButtonStyle iconButtonStyle = IconButton.styleFrom(
    foregroundColor: primaryColor,
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );

  static final ButtonStyle gradientButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white,
    minimumSize: const Size(double.infinity, 56),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    textStyle: const TextStyle(
      fontFamily: 'Poppins',
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
    padding: EdgeInsets.zero,
  );

  // Gradient Button
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    List<Color>? gradientColors,
    double? width,
    double height = 56,
    bool isLoading = false,
  }) {
    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors ?? cardGradient,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // Card Styles
  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static BoxDecoration gradientCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: cardGradient,
    ),
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        spreadRadius: 0,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
