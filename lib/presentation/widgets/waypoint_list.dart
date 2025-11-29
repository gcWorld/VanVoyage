import 'package:flutter/material.dart';
import '../../domain/entities/waypoint.dart';
import '../../domain/enums/waypoint_type.dart';

/// A reorderable list widget for displaying and managing waypoints
class WaypointList extends StatelessWidget {
  final List<Waypoint> waypoints;
  final Function(int oldIndex, int newIndex)? onReorder;
  final Function(Waypoint)? onDelete;
  final Function(Waypoint)? onEdit;
  final Function()? onOptimize;

  const WaypointList({
    super.key,
    required this.waypoints,
    this.onReorder,
    this.onDelete,
    this.onEdit,
    this.onOptimize,
  });

  IconData _getWaypointIcon(WaypointType type) {
    switch (type) {
      case WaypointType.poi:
        return Icons.place;
      case WaypointType.overnightStay:
        return Icons.hotel;
      case WaypointType.transit:
        return Icons.navigation;
    }
  }

  Color _getWaypointColor(BuildContext context, WaypointType type) {
    switch (type) {
      case WaypointType.poi:
        return Theme.of(context).colorScheme.primary;
      case WaypointType.overnightStay:
        return Theme.of(context).colorScheme.secondary;
      case WaypointType.transit:
        return Theme.of(context).colorScheme.tertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (waypoints.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_location_alt,
                size: 64,
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No destinations yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add destinations using the form below',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with optimize button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Destinations (${waypoints.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (waypoints.length > 2 && onOptimize != null)
                TextButton.icon(
                  onPressed: onOptimize,
                  icon: const Icon(Icons.route, size: 18),
                  label: const Text('Optimize'),
                ),
            ],
          ),
        ),
        // Reorderable list
        Expanded(
          child: ReorderableListView.builder(
            itemCount: waypoints.length,
            onReorder: (oldIndex, newIndex) {
              if (onReorder != null) {
                onReorder!(oldIndex, newIndex);
              }
            },
            itemBuilder: (context, index) {
              final waypoint = waypoints[index];
              return Card(
                key: ValueKey(waypoint.id),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getWaypointColor(context, waypoint.waypointType),
                    child: Icon(
                      _getWaypointIcon(waypoint.waypointType),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    waypoint.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    '${waypoint.latitude.toStringAsFixed(4)}, ${waypoint.longitude.toStringAsFixed(4)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (onEdit != null)
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed: () => onEdit!(waypoint),
                          tooltip: 'Edit waypoint',
                        ),
                      if (onDelete != null)
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          onPressed: () => onDelete!(waypoint),
                          tooltip: 'Delete waypoint',
                        ),
                      const Icon(Icons.drag_handle),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
