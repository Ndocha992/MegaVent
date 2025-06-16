import 'package:flutter/material.dart';

// Create a constants class to encapsulate constants
class Constants {
  // Cloudinary configuration
  static const String cloudinaryCloudName = 'dvhdyruva';
  static const String cloudinaryApiKey = '426277598191425';
  static const String cloudinaryApiSecret = 'wgqlR3bEORv2_aZailcWS1KW5xY';
}

class AppConstants {
  // Color palette - Based on MegaVent logo gradient
  static const Color primaryColor = Color(0xFF6B46C1); // Rich purple
  static const Color primaryDarkColor = Color(0xFF553C9A); // Darker purple
  static const Color primaryLightColor = Color(0xFF8B5CF6); // Lighter purple
  static const Color secondaryColor = Color(0xFF06D6A0); // Teal green
  static const Color secondaryDarkColor = Color(0xFF059669); // Darker teal
  static const Color accentColor = Color(0xFF10B981); // Emerald green
  static const Color backgroundColor = Color(0xFFF8FAFC); // Light gray-blue
  static const Color backgroundSecondaryColor = Color(
    0xFFF1F5F9,
  ); // Slightly darker
  static const Color textColor = Color(0xFF0F172A); // Dark slate
  static const Color textSecondaryColor = Color(0xFF64748B); // Slate gray
  static const Color borderColor = Color(0xFFE2E8F0); // Light slate
  static const Color cardColor = Colors.white;
  static const Color errorColor = Color(0xFFEF4444); // Red
  static const Color successColor = Color(0xFF10B981); // Emerald
  static const Color warningColor = Color(0xFFF59E0B); // Amber

  // Gradients - Matching your logo
  static const List<Color> splashGradient = [
    Color(0xFF6B46C1), // Purple
    Color(0xFF8B5CF6), // Light purple
    Color(0xFF06D6A0), // Teal
  ];

  static const List<Color> primaryGradient = [
    Color(0xFF6B46C1), // Purple
    Color(0xFF8B5CF6), // Light purple
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF8B5CF6), // Light purple
    Color(0xFF06D6A0), // Teal
  ];

  static const List<Color> cardGradient = [
    Color(0xFF6B46C1), // Purple
    Color(0xFF7C3AED), // Violet
  ];

  static const List<Color> accentGradient = [
    Color(0xFF06D6A0), // Teal
    Color(0xFF10B981), // Emerald
  ];

  static const List<Color> logoGradient = [
    Color(0xFF6B46C1), // Purple (top)
    Color(0xFF8B5CF6), // Light purple (middle)
    Color(0xFF06D6A0), // Teal (bottom)
  ];

  // Event-specific gradients
  static const List<Color> eventPrimaryGradient = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Violet
  ];

  static const List<Color> eventSecondaryGradient = [
    Color(0xFF10B981), // Emerald
    Color(0xFF06D6A0), // Teal
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
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.08),
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration gradientContainerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: primaryGradient,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration accentContainerDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: accentGradient,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: secondaryColor.withOpacity(0.3),
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  // Event card decoration
  static BoxDecoration eventCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.1),
        spreadRadius: 0,
        blurRadius: 30,
        offset: const Offset(0, 10),
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
        color: textSecondaryColor.withOpacity(0.5),
      ),
      prefixIcon: Icon(prefixIcon, color: primaryColor, size: 22),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: borderColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: primaryColor, width: 2),
        borderRadius: BorderRadius.circular(16),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: errorColor, width: 2),
        borderRadius: BorderRadius.circular(16),
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
      borderRadius: BorderRadius.circular(16),
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
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          colors: gradientColors ?? primaryGradient,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 6),
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
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child:
            isLoading
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
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.08),
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static BoxDecoration gradientCardDecoration = BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: primaryGradient,
    ),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: primaryColor.withOpacity(0.3),
        spreadRadius: 0,
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
}
