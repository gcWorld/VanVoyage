import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/waypoint.dart';
import '../../domain/enums/trip_status.dart';
import '../../providers.dart';
import 'trip_planning_screen.dart';
import 'trip_detail_screen.dart';
import 'route_demo_screen.dart';
import 'trip_route_screen.dart';
import 'package:intl/intl.dart';

/// Screen that displays a list of all trips
class TripListScreen extends ConsumerStatefulWidget {
  const TripListScreen({super.key});

  @override
  ConsumerState<TripListScreen> createState() => _TripListScreenState();
}

class _TripListScreenState extends ConsumerState<TripListScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;
  String? _error;
  TripStatus? _filterStatus;

  @override
  void initState() {
    super.initState();
    _loadTrips();
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tripRepo = await ref.read(tripRepositoryProvider.future);
      
      List<Trip> trips;
      if (_filterStatus != null) {
        trips = await tripRepo.findByStatus(_filterStatus!);
      } else {
        trips = await tripRepo.findAll();
      }

      if (mounted) {
        setState(() {
          _trips = trips;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToCreateTrip() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TripPlanningScreen(),
      ),
    );

    // Reload trips after returning from trip creation
    if (result != null && mounted) {
      _loadTrips();
    }
  }

  void _navigateToTripDetail(Trip trip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripDetailScreen(tripId: trip.id),
      ),
    );

    // Reload trips after returning from trip detail
    if (result != null && mounted) {
      _loadTrips();
    }
  }

  void _navigateToEditTrip(Trip trip) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPlanningScreen(tripId: trip.id),
      ),
    );

    // Reload trips after returning from trip editing
    if (result != null && mounted) {
      _loadTrips();
    }
  }

  Future<void> _navigateToRouteMap(Trip trip) async {
    try {
      final waypointRepo = await ref.read(waypointRepositoryProvider.future);
      final waypoints = await waypointRepo.findByTripId(trip.id);

      if (!mounted) return;

      if (waypoints.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Need at least 2 waypoints to view route on map'),
          ),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TripRouteScreen(
            tripId: trip.id,
            waypoints: waypoints,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading waypoints: $e')),
        );
      }
    }
  }

  Future<void> _deleteTrip(Trip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: Text('Are you sure you want to delete "${trip.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final tripRepo = await ref.read(tripRepositoryProvider.future);
        await tripRepo.delete(trip.id);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted trip: ${trip.name}')),
          );
          _loadTrips();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting trip: $e')),
          );
        }
      }
    }
  }

  void _setStatusFilter(TripStatus? status) {
    setState(() {
      _filterStatus = status;
    });
    _loadTrips();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trips'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RouteDemoScreen(),
                ),
              );
            },
            tooltip: 'Route Demo',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTrips,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterStatus == null,
                  onSelected: (selected) => _setStatusFilter(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Planning'),
                  selected: _filterStatus == TripStatus.planning,
                  onSelected: (selected) => _setStatusFilter(
                    selected ? TripStatus.planning : null,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Active'),
                  selected: _filterStatus == TripStatus.active,
                  onSelected: (selected) => _setStatusFilter(
                    selected ? TripStatus.active : null,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _filterStatus == TripStatus.completed,
                  onSelected: (selected) => _setStatusFilter(
                    selected ? TripStatus.completed : null,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Archived'),
                  selected: _filterStatus == TripStatus.archived,
                  onSelected: (selected) => _setStatusFilter(
                    selected ? TripStatus.archived : null,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Trip list
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateTrip,
        icon: const Icon(Icons.add),
        label: const Text('Create Trip'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading trips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadTrips,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_trips.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.directions_car,
              size: 100,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No trips yet',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first trip to get started',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _navigateToCreateTrip,
              icon: const Icon(Icons.add),
              label: const Text('Create Your First Trip'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _trips.length,
        itemBuilder: (context, index) {
          final trip = _trips[index];
          return _buildTripCard(trip);
        },
      ),
    );
  }

  Widget _buildTripCard(Trip trip) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final duration = trip.endDate.difference(trip.startDate).inDays + 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToTripDetail(trip),
        onLongPress: () => _showQuickActions(trip),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      trip.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  _buildStatusBadge(trip.status),
                ],
              ),
              if (trip.description != null && trip.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  trip.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(trip.startDate)} - ${dateFormat.format(trip.endDate)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.timelapse,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$duration days',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _navigateToRouteMap(trip),
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text('Route'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _navigateToEditTrip(trip),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                  ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () => _navigateToTripDetail(trip),
                    icon: const Icon(Icons.arrow_forward, size: 18),
                    label: const Text('View'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TripStatus status) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case TripStatus.planning:
        color = Colors.blue;
        icon = Icons.edit;
        label = 'Planning';
        break;
      case TripStatus.active:
        color = Colors.green;
        icon = Icons.directions_car;
        label = 'Active';
        break;
      case TripStatus.completed:
        color = Colors.grey;
        icon = Icons.check_circle;
        label = 'Completed';
        break;
      case TripStatus.archived:
        color = Colors.orange;
        icon = Icons.archive;
        label = 'Archived';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(Trip trip) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View'),
              onTap: () {
                Navigator.pop(context);
                _navigateToTripDetail(trip);
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('View Route Map'),
              onTap: () {
                Navigator.pop(context);
                _navigateToRouteMap(trip);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditTrip(trip);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _deleteTrip(trip);
              },
            ),
          ],
        ),
      ),
    );
  }
}
