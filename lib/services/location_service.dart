import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';

class LocationService {
  
  /// Get coordinates for an event location using geocoding
  Future<LatLng?> getEventCoordinates(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get event coordinates: $e');
    }
  }

  /// Get user's current position
  Future<LatLng?> getCurrentPosition() async {
    try {
      final position = await _determinePosition();
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      throw Exception('Failed to get current position: $e');
    }
  }

  /// Determine user's current position with permission handling
  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Calculate distance between two coordinates
  String calculateDistance(LatLng from, LatLng to) {
    final distance = Geolocator.distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );

    if (distance < 1000) {
      return '${distance.round()}m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)}km away';
    }
  }

  /// Open directions in Google Maps
  Future<bool> openDirections(LatLng coordinates) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${coordinates.latitude},${coordinates.longitude}'
      '&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Share location details
  void shareLocation(String locationName, LatLng coordinates) {
    final shareText = '''
📍 $locationName

View on map: https://www.openstreetmap.org/?mlat=${coordinates.latitude}&mlon=${coordinates.longitude}&zoom=15

Get directions: https://www.google.com/maps/dir/?api=1&destination=${coordinates.latitude},${coordinates.longitude}
''';

    Share.share(shareText);
  }

  /// Get timezone information based on location
  String getTimezone(String location) {
    final loc = location.toLowerCase();

    // Kenya and East Africa
    if (loc.contains('nakuru') ||
        loc.contains('nyeri') ||
        loc.contains('nairobi') ||
        loc.contains('kenya') ||
        loc.contains('kampala') ||
        loc.contains('dar es salaam')) {
      return 'EAT (UTC+3)';
    }
    // US East Coast
    else if (loc.contains('new york') ||
        loc.contains('ny') ||
        loc.contains('miami') ||
        loc.contains('atlanta')) {
      return 'EST (UTC-5)';
    }
    // US West Coast
    else if (loc.contains('los angeles') ||
        loc.contains('california') ||
        loc.contains('san francisco')) {
      return 'PST (UTC-8)';
    }
    // UK
    else if (loc.contains('london') ||
        loc.contains('manchester') ||
        loc.contains('birmingham')) {
      return 'GMT (UTC+0)';
    }
    // Japan
    else if (loc.contains('tokyo') ||
        loc.contains('osaka') ||
        loc.contains('kyoto')) {
      return 'JST (UTC+9)';
    }
    // South Africa
    else if (loc.contains('cape town') ||
        loc.contains('johannesburg') ||
        loc.contains('durban')) {
      return 'SAST (UTC+2)';
    }
    // Nigeria
    else if (loc.contains('lagos') ||
        loc.contains('abuja') ||
        loc.contains('nigeria')) {
      return 'WAT (UTC+1)';
    }
    // Default fallback
    else {
      return 'Local Time';
    }
  }
}