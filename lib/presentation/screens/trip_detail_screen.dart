import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/waypoint.dart';
import '../../providers.dart';
import 'trip_planning_screen.dart';
import 'waypoint_detail_screen.dart';
import 'trip_itinerary_screen.dart';
import 'package:intl/intl.dart';

/// Screen that displays detailed information about a specific trip
class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;

  const TripDetailScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  Trip? _trip;
  List<Waypoint> _waypoints = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final tripRepo = await ref.read(tripRepositoryProvider.future);
      final waypointRepo = await ref.read(waypointRepositoryProvider.future);

      final trip = await tripRepo.findById(widget.tripId);
      final waypoints = await waypointRepo.findByTripId(widget.tripId);

      if (mounted) {
        setState(() {
          _trip = trip;
          _waypoints = waypoints;
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

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripPlanningScreen(tripId: widget.tripId),
      ),
    );

    // Reload data after returning from edit
    if (result != null && mounted) {
      _loadData();
    }
  }

  void _navigateToItinerary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TripItineraryScreen(tripId: widget.tripId),
      ),
    );
  }

  void _navigateToWaypointDetail(Waypoint waypoint) async {
    final result = await Navigator.push<Waypoint>(
      context,
      MaterialPageRoute(
        builder: (context) => WaypointDetailScreen(waypoint: waypoint),
      ),
    );

    // If waypoint was updated, reload data
    if (result != null && mounted) {
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _navigateToEdit,
            tooltip: 'Edit Trip',
          ),
        ],
      ),
      body: _buildBody(),
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
              'Error loading trip',
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
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_trip == null) {
      return const Center(
        child: Text('Trip not found'),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const Divider(height: 1),
          _buildSummaryCard(),
          const Divider(height: 1),
          _buildWaypointsList(),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final duration = _trip!.endDate.difference(_trip!.startDate).inDays + 1;

    return Container(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _trip!.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
          ),
          const SizedBox(height: 8),
          if (_trip!.description != null && _trip!.description!.isNotEmpty) ...[
            Text(
              _trip!.description!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
            ),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '${dateFormat.format(_trip!.startDate)} - ${dateFormat.format(_trip!.endDate)}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.timelapse,
                size: 18,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Text(
                '$duration days',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final overnightStays = _waypoints
        .where((w) => w.waypointType.toString().contains('overnight'))
        .length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Summary',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                    icon: Icons.location_on,
                    label: 'Waypoints',
                    value: '${_waypoints.length}',
                  ),
                  _buildSummaryItem(
                    icon: Icons.hotel,
                    label: 'Overnight Stays',
                    value: '$overnightStays',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWaypointsList() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Waypoints',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (_waypoints.isNotEmpty)
                TextButton.icon(
                  onPressed: _navigateToItinerary,
                  icon: const Icon(Icons.timeline, size: 18),
                  label: const Text('View Timeline'),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (_waypoints.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.location_off,
                      size: 64,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No waypoints yet',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add waypoints to start planning your route',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _waypoints.length,
              itemBuilder: (context, index) {
                final waypoint = _waypoints[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text('${index + 1}'),
                    ),
                    title: Text(waypoint.name),
                    subtitle: Text(
                      '${waypoint.latitude.toStringAsFixed(4)}, ${waypoint.longitude.toStringAsFixed(4)}',
                    ),
                    trailing: Icon(
                      _getWaypointIcon(waypoint),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onTap: () => _navigateToWaypointDetail(waypoint),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  IconData _getWaypointIcon(Waypoint waypoint) {
    final typeStr = waypoint.waypointType.toString().toLowerCase();
    if (typeStr.contains('overnight')) {
      return Icons.hotel;
    } else if (typeStr.contains('poi')) {
      return Icons.place;
    } else if (typeStr.contains('transit')) {
      return Icons.transfer_within_a_station;
    }
    return Icons.location_on;
  }
}
