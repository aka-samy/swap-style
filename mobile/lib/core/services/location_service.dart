import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

class LocationData {
  final double latitude;
  final double longitude;

  const LocationData({required this.latitude, required this.longitude});

  /// Cairo default fallback
  static const fallback = LocationData(latitude: 30.0444, longitude: 31.2357);
}

class LocationService {
  Future<LocationData> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return LocationData.fallback;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return LocationData.fallback;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return LocationData.fallback;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      return LocationData.fallback;
    }
  }
}

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final currentLocationProvider = FutureProvider<LocationData>((ref) async {
  return ref.watch(locationServiceProvider).getCurrentLocation();
});
