import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../domain/entities/route.dart' as domain;

/// Widget to visualize routes on the map
class MapRouteLayer {
  static const String routeSourceId = 'route-source';
  static const String routeLayerId = 'route-layer';

  /// Add route to map
  static Future<void> addRouteToMap(
    MapboxMap mapController,
    domain.Route route, {
    Color color = Colors.blue,
    double width = 5.0,
  }) async {
    try {
      // Parse geometry
      final geometryJson = json.decode(route.geometry);
      
      // Remove existing route layer and source if present
      await removeRouteFromMap(mapController);

      // Add GeoJSON source
      await mapController.style.addSource(
        GeoJsonSource(
          id: routeSourceId,
          data: json.encode({
            'type': 'Feature',
            'geometry': geometryJson,
          }),
        ),
      );

      // Add line layer
      await mapController.style.addLayer(
        LineLayer(
          id: routeLayerId,
          sourceId: routeSourceId,
          lineColor: color.value,
          lineWidth: width,
          lineJoin: LineJoin.ROUND,
          lineCap: LineCap.ROUND,
        ),
      );
    } catch (e) {
      debugPrint('Error adding route to map: $e');
    }
  }

  /// Add multiple routes to map with different colors
  static Future<void> addMultipleRoutesToMap(
    MapboxMap mapController,
    List<domain.Route> routes, {
    List<Color>? colors,
  }) async {
    try {
      // Remove existing routes
      await removeRouteFromMap(mapController);

      for (int i = 0; i < routes.length; i++) {
        final route = routes[i];
        final geometryJson = json.decode(route.geometry);
        final sourceId = '$routeSourceId-$i';
        final layerId = '$routeLayerId-$i';
        
        // Determine color
        Color color;
        if (colors != null && i < colors.length) {
          color = colors[i];
        } else if (i == 0) {
          color = Colors.blue;
        } else {
          color = Colors.grey;
        }

        // Add source
        await mapController.style.addSource(
          GeoJsonSource(
            id: sourceId,
            data: json.encode({
              'type': 'Feature',
              'geometry': geometryJson,
            }),
          ),
        );

        // Add layer
        await mapController.style.addLayer(
          LineLayer(
            id: layerId,
            sourceId: sourceId,
            lineColor: color.value,
            lineWidth: i == 0 ? 5.0 : 3.0,
            lineJoin: LineJoin.ROUND,
            lineCap: LineCap.ROUND,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding multiple routes to map: $e');
    }
  }

  /// Remove route from map
  static Future<void> removeRouteFromMap(MapboxMap mapController) async {
    try {
      // Try to remove main route layer
      try {
        await mapController.style.removeStyleLayer(routeLayerId);
      } catch (e) {
        // Layer might not exist
      }

      // Try to remove main route source
      try {
        await mapController.style.removeStyleSource(routeSourceId);
      } catch (e) {
        // Source might not exist
      }

      // Remove alternative route layers (up to 5)
      for (int i = 0; i < 5; i++) {
        try {
          await mapController.style.removeStyleLayer('$routeLayerId-$i');
        } catch (e) {
          // Layer might not exist
        }

        try {
          await mapController.style.removeStyleSource('$routeSourceId-$i');
        } catch (e) {
          // Source might not exist
        }
      }
    } catch (e) {
      debugPrint('Error removing route from map: $e');
    }
  }

  /// Fit map to route bounds
  static Future<void> fitMapToRoute(
    MapboxMap mapController,
    domain.Route route, {
    EdgeInsets padding = const EdgeInsets.all(50),
  }) async {
    try {
      final geometryJson = json.decode(route.geometry);
      final coordinates = geometryJson['coordinates'] as List;

      if (coordinates.isEmpty) return;

      // Calculate bounds
      double minLng = double.infinity;
      double maxLng = -double.infinity;
      double minLat = double.infinity;
      double maxLat = -double.infinity;

      for (final coord in coordinates) {
        final lng = coord[0] as double;
        final lat = coord[1] as double;

        if (lng < minLng) minLng = lng;
        if (lng > maxLng) maxLng = lng;
        if (lat < minLat) minLat = lat;
        if (lat > maxLat) maxLat = lat;
      }

      // Create camera options with bounds
      final southwest = Point(coordinates: Position(minLng, minLat));
      final northeast = Point(coordinates: Position(maxLng, maxLat));

      // Note: Mapbox Flutter SDK doesn't support direct bounds fitting yet
      // Using center point instead

      await mapController.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(
              (minLng + maxLng) / 2,
              (minLat + maxLat) / 2,
            ),
          ),
        ),
      );

      // Note: Mapbox Flutter SDK might not support direct bounds fitting
      // This is a simplified approach
    } catch (e) {
      debugPrint('Error fitting map to route: $e');
    }
  }
}
