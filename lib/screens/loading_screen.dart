import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/utils/constants.dart';

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
                _buildLoadingUI(message ?? 'Creating amazing events...'),
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

  // Force cleanup if needed
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

  // Private method to build the loading UI
  static Widget _buildLoadingUI(String message) {
    return Material(
      color: Colors.transparent,
      child: Container(
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
        child: Center(
          child: Builder(
            builder: (context) {
              final double screenWidth = MediaQuery.of(context).size.width;
              final double containerWidth =
                  screenWidth > 400 ? 360 : screenWidth * 0.85;

              return Container(
                width: containerWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 32,
                ),
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
                    // App Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.6),
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.primaryColor.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 1,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/logo.png',
                          width: 75,
                          height: 75,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // App name
                    Text(
                      'MegaVent',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.primaryColor,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Loading message
                    Text(
                      message,
                      style: AppConstants.bodyMedium.copyWith(
                        color: AppConstants.textColor,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    // Secondary message
                    Text(
                      'Please wait...',
                      style: AppConstants.bodySmallSecondary.copyWith(
                        color: AppConstants.textSecondaryColor.withOpacity(0.7),
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Animated loading indicator
                    const SpinKitThreeBounce(
                      color: AppConstants.primaryColor,
                      size: 20.0,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
