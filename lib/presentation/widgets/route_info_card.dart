import 'package:flutter/material.dart';
import '../../domain/entities/route.dart' as domain;
import '../../domain/entities/waypoint.dart';
import '../../infrastructure/services/navigation_share_service.dart';

/// Widget to display route information with sharing options
class RouteInfoCard extends StatelessWidget {
  final domain.Route route;
  final Waypoint fromWaypoint;
  final Waypoint toWaypoint;
  final VoidCallback? onTap;

  const RouteInfoCard({
    super.key,
    required this.route,
    required this.fromWaypoint,
    required this.toWaypoint,
    this.onTap,
  });

  String _formatDistance(double distanceKm) {
    if (distanceKm >= 1) {
      return '${distanceKm.toStringAsFixed(1)} km';
    }
    return '${(distanceKm * 1000).toStringAsFixed(0)} m';
  }

  String _formatDuration(int durationMinutes) {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  Future<void> _showShareDialog(BuildContext context) async {
    final navigationService = NavigationShareService();
    final apps = navigationService.getAvailableApps();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Share Route to Navigation App',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ...apps.map((app) => ListTile(
                  leading: Text(
                    app.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(app.name),
                  onTap: () async {
                    Navigator.pop(context);
                    final success = await navigationService.shareRoute(
                      app.id,
                      fromWaypoint,
                      toWaypoint,
                    );

                    if (context.mounted && !success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not open ${app.name}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.route, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fromWaypoint.name,
                          style: Theme.of(context).textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.arrow_downward, size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                toWaypoint.name,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share),
                    tooltip: 'Share to navigation app',
                    onPressed: () => _showShareDialog(context),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.straighten, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatDistance(route.distance),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.schedule, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _formatDuration(route.duration),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
