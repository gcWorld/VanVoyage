import '../entities/waypoint.dart';
import 'dart:math' as math;

/// Service for optimizing waypoint order to minimize travel distance.
class RouteOptimizer {
  /// Earth radius in kilometers for Haversine distance calculation.
  static const double earthRadiusKm = 6371.0;

  /// Optimizes the order of waypoints using a greedy nearest neighbor algorithm.
  ///
  /// Respects waypoints with fixed dates (arrivalDate or departureDate set).
  List<Waypoint> optimizeRoute(List<Waypoint> waypoints) {
    if (waypoints.length <= 2) {
      return waypoints; // No optimization needed for 2 or fewer waypoints
    }

    // Separate waypoints into fixed (with dates) and flexible
    final fixed = <int, Waypoint>{};
    final flexible = <Waypoint>[];
    
    for (int i = 0; i < waypoints.length; i++) {
      final waypoint = waypoints[i];
      if (waypoint.arrivalDate != null || waypoint.departureDate != null) {
        fixed[i] = waypoint;
      } else {
        flexible.add(waypoint);
      }
    }

    // If all waypoints are fixed or flexible, return sorted appropriately
    if (fixed.isEmpty) {
      return _optimizeFlexibleWaypoints(flexible);
    }
    
    if (flexible.isEmpty) {
      // Sort fixed waypoints by date
      final sortedFixed = fixed.entries.toList()
        ..sort((a, b) {
          final dateA = a.value.arrivalDate ?? a.value.departureDate!;
          final dateB = b.value.arrivalDate ?? b.value.departureDate!;
          return dateA.compareTo(dateB);
        });
      return sortedFixed.map((e) => e.value).toList();
    }

    // Mixed case: insert flexible waypoints optimally between fixed ones
    return _optimizeMixedWaypoints(fixed, flexible, waypoints.length);
  }

  /// Optimizes a list of flexible waypoints using nearest neighbor algorithm
  List<Waypoint> _optimizeFlexibleWaypoints(List<Waypoint> waypoints) {
    if (waypoints.isEmpty) return [];
    
    final optimized = <Waypoint>[];
    final remaining = List<Waypoint>.from(waypoints);
    
    // Start with the first waypoint
    optimized.add(remaining.removeAt(0));
    
    // Greedily add nearest neighbor
    while (remaining.isNotEmpty) {
      final current = optimized.last;
      int nearestIndex = 0;
      double minDistance = _calculateDistance(
        current.latitude,
        current.longitude,
        remaining[0].latitude,
        remaining[0].longitude,
      );
      
      for (int i = 1; i < remaining.length; i++) {
        final distance = _calculateDistance(
          current.latitude,
          current.longitude,
          remaining[i].latitude,
          remaining[i].longitude,
        );
        
        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }
      
      optimized.add(remaining.removeAt(nearestIndex));
    }
    
    return optimized;
  }

  /// Optimizes mixed waypoints (fixed + flexible)
  List<Waypoint> _optimizeMixedWaypoints(
    Map<int, Waypoint> fixed,
    List<Waypoint> flexible,
    int totalCount,
  ) {
    // Sort fixed waypoints by their original position or date
    final sortedFixed = fixed.entries.toList()
      ..sort((a, b) {
        final dateA = a.value.arrivalDate ?? a.value.departureDate;
        final dateB = b.value.arrivalDate ?? b.value.departureDate;
        if (dateA != null && dateB != null) {
          return dateA.compareTo(dateB);
        }
        return a.key.compareTo(b.key);
      });

    final result = <Waypoint>[];
    int flexIndex = 0;
    
    for (int i = 0; i < sortedFixed.length; i++) {
      final fixedEntry = sortedFixed[i];
      
      // Calculate how many flexible waypoints should be inserted before this fixed waypoint
      // Based on the gap between consecutive fixed waypoint positions in the original list
      final flexibleToAdd = _calculateFlexibleWaypointsToInsert(
        i, sortedFixed, totalCount, fixedEntry.key);
      
      
      // Insert optimized flexible waypoints
      if (flexIndex < flexible.length && flexibleToAdd > 0) {
        final toOptimize = flexible.skip(flexIndex).take(flexibleToAdd).toList();
        if (result.isNotEmpty) {
          // Optimize based on distance from last waypoint
          final optimized = _optimizeFromPoint(result.last, toOptimize);
          result.addAll(optimized);
        } else {
          result.addAll(toOptimize);
        }
        flexIndex += flexibleToAdd;
      }
      
      // Add the fixed waypoint
      result.add(fixedEntry.value);
    }
    
    // Add any remaining flexible waypoints at the end
    if (flexIndex < flexible.length) {
      final remaining = flexible.skip(flexIndex).toList();
      if (result.isNotEmpty) {
        final optimized = _optimizeFromPoint(result.last, remaining);
        result.addAll(optimized);
      } else {
        result.addAll(remaining);
      }
    }
    
    return result;
  }

  /// Calculates the number of flexible waypoints to insert before a fixed waypoint.
  ///
  /// This determines how many flexible waypoints should be placed before a fixed
  /// waypoint based on the gap from the previous fixed waypoint (or start).
  int _calculateFlexibleWaypointsToInsert(
    int currentIndex,
    List<MapEntry<int, Waypoint>> sortedFixed,
    int totalCount,
    int currentFixedPos,
  ) {
    // Get position of previous fixed waypoint (or -1 if this is the first)
    // For the first fixed waypoint, this gives us the count of flexible waypoints before it
    final previousFixedPos = currentIndex > 0
        ? sortedFixed[currentIndex - 1].key
        : -1;
    
    // Calculate gap: number of positions between previous and current fixed waypoint
    // This gives us how many flexible waypoints should be inserted before this fixed one
    return math.max(0, currentFixedPos - previousFixedPos - 1);
  }

  /// Optimizes waypoints starting from a specific point
  List<Waypoint> _optimizeFromPoint(Waypoint start, List<Waypoint> waypoints) {
    if (waypoints.isEmpty) return [];
    
    final optimized = <Waypoint>[];
    final remaining = List<Waypoint>.from(waypoints);
    Waypoint current = start;
    
    while (remaining.isNotEmpty) {
      int nearestIndex = 0;
      double minDistance = _calculateDistance(
        current.latitude,
        current.longitude,
        remaining[0].latitude,
        remaining[0].longitude,
      );
      
      for (int i = 1; i < remaining.length; i++) {
        final distance = _calculateDistance(
          current.latitude,
          current.longitude,
          remaining[i].latitude,
          remaining[i].longitude,
        );
        
        if (distance < minDistance) {
          minDistance = distance;
          nearestIndex = i;
        }
      }
      
      current = remaining.removeAt(nearestIndex);
      optimized.add(current);
    }
    
    return optimized;
  }

  /// Calculates the Haversine distance between two points in kilometers
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
