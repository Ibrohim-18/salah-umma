import 'dart:math';

class QiblaService {
  // Kaaba coordinates
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla direction (azimuth) from user's location to Kaaba
  /// Returns angle in degrees (0-360)
  static double calculateQiblaDirection({
    required double userLatitude,
    required double userLongitude,
  }) {
    // Convert to radians
    final lat1 = _toRadians(userLatitude);
    final lon1 = _toRadians(userLongitude);
    final lat2 = _toRadians(kaabaLatitude);
    final lon2 = _toRadians(kaabaLongitude);

    // Calculate azimuth using spherical geometry
    final dLon = lon2 - lon1;

    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);

    var azimuth = atan2(y, x);

    // Convert to degrees
    azimuth = _toDegrees(azimuth);

    // Normalize to 0-360
    azimuth = (azimuth + 360) % 360;

    return azimuth;
  }

  /// Calculate distance to Kaaba in kilometers
  static double calculateDistanceToKaaba({
    required double userLatitude,
    required double userLongitude,
  }) {
    const earthRadius = 6371.0; // km

    final lat1 = _toRadians(userLatitude);
    final lon1 = _toRadians(userLongitude);
    final lat2 = _toRadians(kaabaLatitude);
    final lon2 = _toRadians(kaabaLongitude);

    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  /// Check if device is pointing towards Qibla
  /// Returns true if within tolerance (default 5 degrees)
  static bool isPointingToQibla({
    required double qiblaDirection,
    required double deviceHeading,
    double tolerance = 5.0,
  }) {
    final diff = _normalizeAngle(qiblaDirection - deviceHeading);
    return diff.abs() <= tolerance;
  }

  /// Calculate the difference between two angles
  /// Returns value between -180 and 180
  static double _normalizeAngle(double angle) {
    angle = angle % 360;
    if (angle > 180) {
      angle -= 360;
    } else if (angle < -180) {
      angle += 360;
    }
    return angle;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  static double _toDegrees(double radians) {
    return radians * 180 / pi;
  }

  /// Get compass direction name from angle
  static String getCompassDirection(double angle) {
    const directions = [
      'N',
      'NNE',
      'NE',
      'ENE',
      'E',
      'ESE',
      'SE',
      'SSE',
      'S',
      'SSW',
      'SW',
      'WSW',
      'W',
      'WNW',
      'NW',
      'NNW'
    ];
    final index = ((angle + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }
}

