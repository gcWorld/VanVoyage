import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/waypoint.dart';
import '../../domain/enums/waypoint_type.dart';
import 'trip_route_screen.dart';

/// Demo screen showing how to use route calculation features
class RouteDemoScreen extends ConsumerWidget {
  const RouteDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Example waypoints for demo
    final demoWaypoints = [
      Waypoint.create(
        tripId: 'demo-trip',
        name: 'San Francisco',
        latitude: 37.7749,
        longitude: -122.4194,
        waypointType: WaypointType.overnightStay,
        sequenceOrder: 0,
        address: 'San Francisco, CA',
      ),
      Waypoint.create(
        tripId: 'demo-trip',
        name: 'Yosemite National Park',
        latitude: 37.8651,
        longitude: -119.5383,
        waypointType: WaypointType.poi,
        sequenceOrder: 1,
        address: 'Yosemite Valley, CA',
      ),
      Waypoint.create(
        tripId: 'demo-trip',
        name: 'Lake Tahoe',
        latitude: 39.0968,
        longitude: -120.0324,
        waypointType: WaypointType.overnightStay,
        sequenceOrder: 2,
        address: 'Lake Tahoe, CA',
      ),
      Waypoint.create(
        tripId: 'demo-trip',
        name: 'Sacramento',
        latitude: 38.5816,
        longitude: -121.4944,
        waypointType: WaypointType.transit,
        sequenceOrder: 3,
        address: 'Sacramento, CA',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Demo'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header
          Text(
            'Route Calculation Demo',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'This demo shows route calculation and visualization features.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),

          // Demo trip card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Demo Trip: California Adventure',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Waypoints:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...demoWaypoints.asMap().entries.map((entry) {
                    final index = entry.key;
                    final waypoint = entry.value;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            child: Text('${index + 1}'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  waypoint.name,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Text(
                                  waypoint.address ?? 'No address',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          _getWaypointIcon(waypoint.waypointType),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Features:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem(
                    context,
                    Icons.route,
                    'Route Calculation',
                    'Automatic route calculation between waypoints',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.alt_route,
                    'Alternative Routes',
                    'View and compare alternative route options',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.share,
                    'Share to Navigation Apps',
                    'Share individual legs to Google Maps, Apple Maps, Waze, etc.',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.map,
                    'Route Visualization',
                    'See routes on an interactive map',
                  ),
                  _buildFeatureItem(
                    context,
                    Icons.cached,
                    'Smart Caching',
                    'Routes cached for 7 days to reduce API calls',
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TripRouteScreen(
                              tripId: 'demo-trip',
                              waypoints: demoWaypoints,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.map),
                      label: const Text('View Route on Map'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Usage instructions
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Use',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildStep(
                    context,
                    1,
                    'Tap "View Route on Map" to see the calculated route',
                  ),
                  _buildStep(
                    context,
                    2,
                    'The route will be displayed on the map with blue lines',
                  ),
                  _buildStep(
                    context,
                    3,
                    'View route summary at the top (distance and duration)',
                  ),
                  _buildStep(
                    context,
                    4,
                    'Scroll the bottom panel to see individual route segments',
                  ),
                  _buildStep(
                    context,
                    5,
                    'Tap a segment to view alternative routes',
                  ),
                  _buildStep(
                    context,
                    6,
                    'Use the share button to open the route in a navigation app',
                  ),
                  _buildStep(
                    context,
                    7,
                    'Tap refresh to recalculate routes with current traffic',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, int number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Icon _getWaypointIcon(WaypointType type) {
    switch (type) {
      case WaypointType.overnightStay:
        return const Icon(Icons.hotel, size: 20);
      case WaypointType.poi:
        return const Icon(Icons.place, size: 20);
      case WaypointType.transit:
        return const Icon(Icons.navigation, size: 20);
    }
  }
}
