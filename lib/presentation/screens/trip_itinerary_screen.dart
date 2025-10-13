import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/waypoint.dart';
import '../../providers.dart';
import '../widgets/trip_itinerary_timeline.dart';
import 'waypoint_detail_screen.dart';

/// Screen that displays the trip itinerary in a timeline format
class TripItineraryScreen extends ConsumerStatefulWidget {
  final String tripId;
  
  const TripItineraryScreen({
    super.key,
    required this.tripId,
  });

  @override
  ConsumerState<TripItineraryScreen> createState() => _TripItineraryScreenState();
}

class _TripItineraryScreenState extends ConsumerState<TripItineraryScreen> {
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

  Future<void> _navigateToWaypointDetail(Waypoint waypoint) async {
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
        title: const Text('Trip Itinerary'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Refresh',
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
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                'Error loading itinerary',
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
        ),
      );
    }

    if (_trip == null) {
      return const Center(
        child: Text('Trip not found'),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: TripItineraryTimeline(
        trip: _trip!,
        waypoints: _waypoints,
        onWaypointTap: _navigateToWaypointDetail,
      ),
    );
  }
}
