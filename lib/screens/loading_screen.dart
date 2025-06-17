import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/utils/constants.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  final bool isFullScreen;

  const LoadingScreen({
    super.key,
    this.message = 'Creating amazing events...',
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double containerWidth = screenWidth > 400 ? 360 : screenWidth * 0.85;
    
    final Widget loadingContent = Container(
      width: containerWidth,
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withOpacity(0.15),
            blurRadius: 30,
            spreadRadius: 0,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Static logo container without spinning ring
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppConstants.logoGradient,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppConstants.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.event,
                  color: AppConstants.primaryColor,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // App name without shader mask gradient
          const Text(
            'MegaVent',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          // Loading message
          Text(
            message,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Secondary message
          Text(
            'Please wait...',
            style: AppConstants.bodySmallSecondary.copyWith(
              color: AppConstants.textSecondaryColor.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Animated dots
          const SpinKitThreeBounce(
            color: AppConstants.primaryColor,
            size: 20.0,
          ),
        ],
      ),
    );

    if (isFullScreen) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.7),
              Colors.black.withOpacity(0.5),
            ],
          ),
        ),
        child: Center(child: loadingContent),
      );
    } else {
      return Center(child: loadingContent);
    }
  }
}

// Improved LoadingOverlay with better state management
class LoadingOverlay {
  static OverlayEntry? _overlayEntry;
  static bool _isShowing = false;

  static void show(BuildContext context, {String? message}) {
    // Prevent multiple overlays
    if (_isShowing) {
      debugPrint(
        'LoadingOverlay: Already showing, ignoring duplicate show request',
      );
      return;
    }

    // Ensure we have a valid context
    if (!context.mounted) {
      debugPrint('LoadingOverlay: Context not mounted, cannot show overlay');
      return;
    }

    try {
      _overlayEntry = OverlayEntry(
        builder:
            (context) =>
                LoadingScreen(message: message ?? 'Creating amazing events...'),
      );

      Overlay.of(context).insert(_overlayEntry!);
      _isShowing = true;
      debugPrint('LoadingOverlay: Overlay shown successfully');
    } catch (e) {
      debugPrint('LoadingOverlay: Error showing overlay: $e');
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  static void hide() {
    if (!_isShowing || _overlayEntry == null) {
      debugPrint('LoadingOverlay: No overlay to hide');
      return;
    }

    try {
      _overlayEntry?.remove();
      debugPrint('LoadingOverlay: Overlay hidden successfully');
    } catch (e) {
      debugPrint('LoadingOverlay: Error hiding overlay: $e');
    } finally {
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  // Add this method to force cleanup if needed
  static void forceHide() {
    try {
      _overlayEntry?.remove();
    } catch (e) {
      debugPrint('LoadingOverlay: Error in force hide: $e');
    } finally {
      _overlayEntry = null;
      _isShowing = false;
    }
  }

  // Check if overlay is currently showing
  static bool get isShowing => _isShowing;
}