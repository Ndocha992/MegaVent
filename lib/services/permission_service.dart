import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static final PermissionService _instance = PermissionService._internal();
  factory PermissionService() => _instance;
  PermissionService._internal();

  /// Request all necessary permissions when app starts
  Future<void> requestAllPermissions(BuildContext context) async {
    // List of permissions your app needs
    final permissions = [
      Permission.camera,
      Permission.location,
      Permission.locationWhenInUse,
    ];

    // Check which permissions are not granted
    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    // Handle each permission status
    for (Permission permission in permissions) {
      PermissionStatus status = statuses[permission] ?? PermissionStatus.denied;
      
      if (status.isPermanentlyDenied) {
        // Show dialog to open settings
        _showPermissionDialog(context, permission);
      }
    }
  }

  /// Request specific permission
  Future<bool> requestPermission(Permission permission) async {
    PermissionStatus status = await permission.status;
    
    if (status.isDenied) {
      status = await permission.request();
    }
    
    return status.isGranted;
  }

  /// Check if permission is granted
  Future<bool> isPermissionGranted(Permission permission) async {
    return await permission.isGranted;
  }

  /// Show dialog for permanently denied permissions
  void _showPermissionDialog(BuildContext context, Permission permission) {
    String permissionName = _getPermissionName(permission);
    String permissionReason = _getPermissionReason(permission);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionName Permission Required'),
          content: Text(permissionReason),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  /// Get human-readable permission name
  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera';
      case Permission.location:
      case Permission.locationWhenInUse:
        return 'Location';
      case Permission.microphone:
        return 'Microphone';
      case Permission.storage:
        return 'Storage';
      case Permission.photos:
        return 'Photos';
      default:
        return 'Permission';
    }
  }

  /// Get permission usage reason
  String _getPermissionReason(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'This app needs camera access to scan QR codes for event check-ins.';
      case Permission.location:
      case Permission.locationWhenInUse:
        return 'This app needs location access to show nearby events and venues.';
      case Permission.microphone:
        return 'This app needs microphone access for voice features.';
      case Permission.storage:
        return 'This app needs storage access to save event data and images.';
      case Permission.photos:
        return 'This app needs photo access to upload event images.';
      default:
        return 'This permission is required for the app to function properly.';
    }
  }

  /// Show permission rationale before requesting
  Future<bool> showPermissionRationale(
    BuildContext context,
    Permission permission,
  ) async {
    String permissionName = _getPermissionName(permission);
    String permissionReason = _getPermissionReason(permission);

    bool shouldRequest = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$permissionName Access'),
          content: Text(permissionReason),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Allow'),
            ),
          ],
        );
      },
    ) ?? false;

    return shouldRequest;
  }

  /// Request camera permission specifically
  Future<bool> requestCameraPermission() async {
    return await requestPermission(Permission.camera);
  }

  /// Request location permission specifically
  Future<bool> requestLocationPermission() async {
    return await requestPermission(Permission.locationWhenInUse);
  }

  /// Check all permissions status
  Future<Map<Permission, PermissionStatus>> checkAllPermissions() async {
    final permissions = [
      Permission.camera,
      Permission.location,
      Permission.locationWhenInUse,
    ];

    Map<Permission, PermissionStatus> statuses = {};
    for (Permission permission in permissions) {
      statuses[permission] = await permission.status;
    }

    return statuses;
  }
}