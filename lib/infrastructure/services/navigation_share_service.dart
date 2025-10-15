import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/waypoint.dart';

/// Service for sharing routes to external navigation apps
class NavigationShareService {
  /// Share route to Google Maps
  Future<bool> shareToGoogleMaps(Waypoint from, Waypoint to) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${from.latitude},${from.longitude}'
      '&destination=${to.latitude},${to.longitude}'
      '&travelmode=driving',
    );

    return await _launchUrl(url);
  }

  /// Share waypoint to Google Maps (single location)
  Future<bool> shareWaypointToGoogleMaps(Waypoint waypoint) async {
    final url = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
      '&query=${waypoint.latitude},${waypoint.longitude}',
    );

    return await _launchUrl(url);
  }

  /// Share route to Apple Maps
  Future<bool> shareToAppleMaps(Waypoint from, Waypoint to) async {
    final url = Uri.parse(
      'http://maps.apple.com/?saddr=${from.latitude},${from.longitude}'
      '&daddr=${to.latitude},${to.longitude}'
      '&dirflg=d',
    );

    return await _launchUrl(url);
  }

  /// Share waypoint to Apple Maps (single location)
  Future<bool> shareWaypointToAppleMaps(Waypoint waypoint) async {
    final url = Uri.parse(
      'http://maps.apple.com/?ll=${waypoint.latitude},${waypoint.longitude}',
    );

    return await _launchUrl(url);
  }

  /// Share route to Waze
  Future<bool> shareToWaze(Waypoint to) async {
    final url = Uri.parse(
      'https://waze.com/ul?ll=${to.latitude},${to.longitude}&navigate=yes',
    );

    return await _launchUrl(url);
  }

  /// Share route to HERE WeGo
  Future<bool> shareToHereWeGo(Waypoint from, Waypoint to) async {
    final url = Uri.parse(
      'https://share.here.com/r/${from.latitude},${from.longitude}'
      ',${to.latitude},${to.longitude}',
    );

    return await _launchUrl(url);
  }

  /// Helper method to launch URL
  Future<bool> _launchUrl(Uri url) async {
    if (await canLaunchUrl(url)) {
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    }
    return false;
  }

  /// Get available navigation app options
  List<NavigationApp> getAvailableApps() {
    return [
      NavigationApp(
        name: 'Google Maps',
        icon: '🗺️',
        id: 'google_maps',
      ),
      NavigationApp(
        name: 'Apple Maps',
        icon: '🍎',
        id: 'apple_maps',
      ),
      NavigationApp(
        name: 'Waze',
        icon: '🚗',
        id: 'waze',
      ),
      NavigationApp(
        name: 'HERE WeGo',
        icon: '🧭',
        id: 'here_wego',
      ),
    ];
  }

  /// Share route to specified app
  Future<bool> shareRoute(String appId, Waypoint from, Waypoint to) async {
    switch (appId) {
      case 'google_maps':
        return await shareToGoogleMaps(from, to);
      case 'apple_maps':
        return await shareToAppleMaps(from, to);
      case 'waze':
        return await shareToWaze(to);
      case 'here_wego':
        return await shareToHereWeGo(from, to);
      default:
        return false;
    }
  }
}

/// Represents a navigation app option
class NavigationApp {
  final String name;
  final String icon;
  final String id;

  NavigationApp({
    required this.name,
    required this.icon,
    required this.id,
  });
}
