import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:megavent/utils/constants.dart';

class LoadingScreen extends StatelessWidget {
  final String message;
  final bool isFullScreen;

  const LoadingScreen({
    super.key,
    this.message = 'Processing your request...',
    this.isFullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final Widget loadingContent = Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Custom SpinKit animation
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppConstants.primaryLightColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Padding(
              padding: EdgeInsets.all(5.0),
              child: SpinKitDoubleBounce(
                color: AppConstants.primaryColor,
                size: 70.0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: AppConstants.bodyMedium.copyWith(
              color: AppConstants.textColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Please wait...',
            style: AppConstants.bodySmallSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    if (isFullScreen) {
      return Container(
        color: Colors.black.withOpacity(0.5),
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
                LoadingScreen(message: message ?? 'Processing your request...'),
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
