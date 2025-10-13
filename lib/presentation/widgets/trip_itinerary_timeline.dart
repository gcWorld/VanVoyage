import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/waypoint.dart';
import '../../domain/enums/waypoint_type.dart';

/// A timeline widget that visualizes the trip itinerary with stays and visits
class TripItineraryTimeline extends StatelessWidget {
  final Trip trip;
  final List<Waypoint> waypoints;
  final Function(Waypoint)? onWaypointTap;
  
  const TripItineraryTimeline({
    super.key,
    required this.trip,
    required this.waypoints,
    this.onWaypointTap,
  });

  @override
  Widget build(BuildContext context) {
    // Sort waypoints by arrival date, then by sequence order
    final sortedWaypoints = List<Waypoint>.from(waypoints)
      ..sort((a, b) {
        if (a.arrivalDate != null && b.arrivalDate != null) {
          return a.arrivalDate!.compareTo(b.arrivalDate!);
        } else if (a.arrivalDate != null) {
          return -1;
        } else if (b.arrivalDate != null) {
          return 1;
        }
        return a.sequenceOrder.compareTo(b.sequenceOrder);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTripHeader(context),
        const SizedBox(height: 16),
        if (sortedWaypoints.isEmpty)
          _buildEmptyState(context)
        else
          _buildTimeline(context, sortedWaypoints),
      ],
    );
  }

  Widget _buildTripHeader(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final duration = trip.endDate.difference(trip.startDate).inDays;
    
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trip_origin,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    trip.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.timelapse,
                  size: 16,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  '$duration ${duration == 1 ? 'day' : 'days'}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'No waypoints added yet',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add destinations to see your itinerary',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(BuildContext context, List<Waypoint> sortedWaypoints) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedWaypoints.length,
      itemBuilder: (context, index) {
        final waypoint = sortedWaypoints[index];
        final isLast = index == sortedWaypoints.length - 1;
        
        return _buildTimelineItem(
          context,
          waypoint,
          isLast,
        );
      },
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    Waypoint waypoint,
    bool isLast,
  ) {
    final dateFormat = DateFormat('MMM dd');
    final hasStayInfo = waypoint.arrivalDate != null || 
                       waypoint.departureDate != null || 
                       waypoint.stayDuration != null;
    
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline indicator
          SizedBox(
            width: 60,
            child: Column(
              children: [
                // Timeline circle
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getWaypointColor(context, waypoint),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getWaypointIcon(waypoint),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                // Timeline line
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
          
          // Content
          Expanded(
            child: GestureDetector(
              onTap: onWaypointTap != null ? () => onWaypointTap!(waypoint) : null,
              child: Card(
                margin: const EdgeInsets.only(bottom: 16, right: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Waypoint name and type
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              waypoint.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          _buildTypeChip(context, waypoint),
                        ],
                      ),
                      
                      // Description
                      if (waypoint.description != null && waypoint.description!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          waypoint.description!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      // Stay/Visit information
                      if (hasStayInfo) ...[
                        const SizedBox(height: 12),
                        if (waypoint.waypointType == WaypointType.overnightStay) ...[
                          _buildStayInfo(context, waypoint, dateFormat),
                        ] else if (waypoint.arrivalDate != null) ...[
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(waypoint.arrivalDate!),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                      
                      // Driving info
                      if (waypoint.estimatedDrivingTime != null || waypoint.estimatedDistance != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (waypoint.estimatedDistance != null) ...[
                              Icon(
                                Icons.directions_car,
                                size: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${waypoint.estimatedDistance!.toStringAsFixed(1)} km',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                            if (waypoint.estimatedDrivingTime != null) ...[
                              if (waypoint.estimatedDistance != null) const SizedBox(width: 12),
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${(waypoint.estimatedDrivingTime! / 60).toStringAsFixed(1)} hrs',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStayInfo(BuildContext context, Waypoint waypoint, DateFormat dateFormat) {
    final hasArrival = waypoint.arrivalDate != null;
    final hasDeparture = waypoint.departureDate != null;
    final hasDuration = waypoint.stayDuration != null;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Arrival and departure dates
        if (hasArrival || hasDeparture)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (hasArrival) ...[
                  Icon(
                    Icons.login,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(waypoint.arrivalDate!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (hasArrival && hasDeparture) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 8),
                ],
                if (hasDeparture) ...[
                  Icon(
                    Icons.logout,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateFormat.format(waypoint.departureDate!),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (hasDuration) ...[
                  const Spacer(),
                  Icon(
                    Icons.nights_stay,
                    size: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${waypoint.stayDuration} ${waypoint.stayDuration == 1 ? 'night' : 'nights'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, Waypoint waypoint) {
    String label;
    IconData icon;
    
    switch (waypoint.waypointType) {
      case WaypointType.overnightStay:
        label = 'Stay';
        icon = Icons.hotel;
        break;
      case WaypointType.poi:
        label = 'Visit';
        icon = Icons.place;
        break;
      case WaypointType.transit:
        label = 'Transit';
        icon = Icons.route;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getWaypointColor(context, waypoint).withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: _getWaypointColor(context, waypoint),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getWaypointColor(context, waypoint),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getWaypointIcon(Waypoint waypoint) {
    switch (waypoint.waypointType) {
      case WaypointType.overnightStay:
        return Icons.hotel;
      case WaypointType.poi:
        return Icons.place;
      case WaypointType.transit:
        return Icons.route;
    }
  }

  Color _getWaypointColor(BuildContext context, Waypoint waypoint) {
    switch (waypoint.waypointType) {
      case WaypointType.overnightStay:
        return Colors.blue;
      case WaypointType.poi:
        return Colors.green;
      case WaypointType.transit:
        return Colors.orange;
    }
  }
}
