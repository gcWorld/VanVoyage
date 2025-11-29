import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/trip.dart';
import '../../domain/entities/trip_preferences.dart';
import '../../domain/entities/waypoint.dart';
import '../../domain/enums/trip_status.dart';
import '../../domain/enums/waypoint_type.dart';
import '../../domain/services/route_optimizer.dart';
import '../widgets/forms/trip_form.dart';
import '../widgets/forms/destination_picker.dart';
import '../widgets/forms/trip_preferences_form.dart';
import '../widgets/trip_itinerary_timeline.dart';
import 'waypoint_detail_screen.dart';
import 'package:vanvoyage/providers.dart';

/// Main screen for creating and editing trip plans
class TripPlanningScreen extends ConsumerStatefulWidget {
  /// Optional trip ID to edit existing trip
  final String? tripId;

  const TripPlanningScreen({
    super.key,
    this.tripId,
  });

  @override
  ConsumerState<TripPlanningScreen> createState() => _TripPlanningScreenState();
}

class _TripPlanningScreenState extends ConsumerState<TripPlanningScreen> {
  int _currentStep = 0;
  Trip? _trip;
  final List<Waypoint> _waypoints = [];
  TripPreferences? _preferences;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.tripId != null) {
      _loadTrip();
    }
  }

  Future<void> _loadTrip() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tripRepo = await ref.read(tripRepositoryProvider.future);
      final waypointRepo = await ref.read(waypointRepositoryProvider.future);

      final trip = await tripRepo.findById(widget.tripId!);
      final waypoints = await waypointRepo.findByTripId(widget.tripId!);

      if (mounted) {
        setState(() {
          _trip = trip;
          _waypoints.clear();
          _waypoints.addAll(waypoints);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading trip: $e')),
        );
      }
    }
  }

  Future<void> _onTripFormSubmit(
    String name,
    String? description,
    DateTime startDate,
    DateTime endDate,
    DateTime? transitStartDate,
    DateTime? transitEndDate,
    DateTime? locationStartDate,
    DateTime? locationEndDate,
  ) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tripRepo = await ref.read(tripRepositoryProvider.future);

      if (_trip == null) {
        // Create new trip
        _trip = Trip.create(
          name: name,
          description: description,
          startDate: startDate,
          endDate: endDate,
          transitStartDate: transitStartDate,
          transitEndDate: transitEndDate,
          locationStartDate: locationStartDate,
          locationEndDate: locationEndDate,
          status: TripStatus.planning,
        );
        await tripRepo.insert(_trip!);
      } else {
        // Update existing trip
        _trip = _trip!.copyWith(
          name: name,
          description: description,
          startDate: startDate,
          endDate: endDate,
          transitStartDate: transitStartDate,
          transitEndDate: transitEndDate,
          locationStartDate: locationStartDate,
          locationEndDate: locationEndDate,
        );
        await tripRepo.update(_trip!);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentStep = 1; // Move to destination picker
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving trip: $e')),
        );
      }
    }
  }

  Future<void> _onLocationSelected(
    String name,
    double latitude,
    double longitude,
    WaypointType type,
  ) async {
    if (_trip == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final waypointRepo = await ref.read(waypointRepositoryProvider.future);

      final waypoint = Waypoint.create(
        tripId: _trip!.id,
        name: name,
        latitude: latitude,
        longitude: longitude,
        waypointType: type,
        sequenceOrder: _waypoints.length,
      );

      await waypointRepo.insert(waypoint);

      if (mounted) {
        setState(() {
          _waypoints.add(waypoint);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added waypoint: $name'),
            action: SnackBarAction(
              label: 'Next Step',
              onPressed: () {
                setState(() {
                  _currentStep = 2; // Move to preferences
                });
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding waypoint: $e')),
        );
      }
    }
  }

  Future<void> _onWaypointReorder(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final waypointRepo = await ref.read(waypointRepositoryProvider.future);

      // Reorder in memory
      final waypoint = _waypoints.removeAt(oldIndex);
      _waypoints.insert(newIndex, waypoint);

      // Update sequence orders and save to database
      for (int i = 0; i < _waypoints.length; i++) {
        final updated = _waypoints[i].copyWith(sequenceOrder: i);
        _waypoints[i] = updated;
        await waypointRepo.update(updated);
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waypoint order updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reordering waypoints: $e')),
        );
      }
    }
  }

  Future<void> _onWaypointDelete(Waypoint waypoint) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Waypoint'),
        content: Text('Are you sure you want to delete "${waypoint.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final waypointRepo = await ref.read(waypointRepositoryProvider.future);
      await waypointRepo.delete(waypoint.id);

      if (mounted) {
        setState(() {
          _waypoints.removeWhere((w) => w.id == waypoint.id);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted waypoint: ${waypoint.name}')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting waypoint: $e')),
        );
      }
    }
  }

  Future<void> _onWaypointOptimize() async {
    if (_waypoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Need at least 3 waypoints to optimize'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final optimizer = RouteOptimizer();
      final optimized = optimizer.optimizeRoute(_waypoints);

      // Fetch repository once before the loop
      final waypointRepo = await ref.read(waypointRepositoryProvider.future);

      // Update sequence orders and save to database
      for (int i = 0; i < optimized.length; i++) {
        final updated = optimized[i].copyWith(sequenceOrder: i);
        optimized[i] = updated;
        await waypointRepo.update(updated);
      }

      if (mounted) {
        setState(() {
          _waypoints.clear();
          _waypoints.addAll(optimized);
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Route optimized! Waypoints reordered for minimal distance.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error optimizing route: $e')),
        );
      }
    }
  }

  void _onPreferencesSave(
    int maxDailyDrivingDistance,
    int maxDailyDrivingTime,
    int preferredDrivingSpeed,
    bool includeRestStops,
    int? restStopInterval,
    bool avoidTolls,
    bool avoidHighways,
    bool preferScenicRoutes,
    int? transitMaxDailyDrivingDistance,
    int? transitMaxDailyDrivingTime,
    int? vacationMaxDailyDrivingDistance,
    int? vacationMaxDailyDrivingTime,
  ) {
    if (_trip == null) return;

    // Create preferences (would be saved to database in real implementation)
    _preferences = TripPreferences.create(
      tripId: _trip!.id,
      maxDailyDrivingDistance: maxDailyDrivingDistance,
      maxDailyDrivingTime: maxDailyDrivingTime,
      preferredDrivingSpeed: preferredDrivingSpeed,
      includeRestStops: includeRestStops,
      restStopInterval: restStopInterval,
      avoidTolls: avoidTolls,
      avoidHighways: avoidHighways,
      preferScenicRoutes: preferScenicRoutes,
      transitMaxDailyDrivingDistance: transitMaxDailyDrivingDistance,
      transitMaxDailyDrivingTime: transitMaxDailyDrivingTime,
      vacationMaxDailyDrivingDistance: vacationMaxDailyDrivingDistance,
      vacationMaxDailyDrivingTime: vacationMaxDailyDrivingTime,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Trip preferences saved!'),
        action: SnackBarAction(
          label: 'View Itinerary',
          onPressed: () {
            setState(() {
              _currentStep = 3; // Move to itinerary view
            });
          },
        ),
      ),
    );
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
      await _loadTrip();
    }
  }

  void _finishPlanning() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Trip planning completed!'),
      ),
    );
    // Return true to signal that the trip list should refresh
    Navigator.of(context).pop(true);
  }

  List<Step> _buildSteps() {
    return [
      Step(
        title: const Text('Trip Details'),
        content: TripForm(
          trip: _trip,
          onSubmit: _onTripFormSubmit,
        ),
        isActive: _currentStep >= 0,
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      Step(
        title: const Text('Add Destinations'),
        subtitle: Text('${_waypoints.length} waypoints added'),
        content: SizedBox(
          height: 500,
          child: DestinationPicker(
            onLocationSelected: _onLocationSelected,
            waypoints: _waypoints,
            onReorder: _onWaypointReorder,
            onDelete: _onWaypointDelete,
            onOptimize: _onWaypointOptimize,
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1
            ? StepState.complete
            : _currentStep == 1
                ? StepState.indexed
                : StepState.disabled,
      ),
      Step(
        title: const Text('Travel Constraints'),
        content: TripPreferencesForm(
          preferences: _preferences,
          onSave: _onPreferencesSave,
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2
            ? StepState.complete
            : _currentStep == 2
                ? StepState.indexed
                : StepState.disabled,
      ),
      Step(
        title: const Text('Review Itinerary'),
        subtitle: const Text('Configure stays and review timeline'),
        content: _trip != null
            ? SizedBox(
                height: 500,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: TripItineraryTimeline(
                          trip: _trip!,
                          waypoints: _waypoints,
                          onWaypointTap: _navigateToWaypointDetail,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _finishPlanning,
                        icon: const Icon(Icons.check),
                        label: const Text('Finish Planning'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const Center(child: Text('Create trip first')),
        isActive: _currentStep >= 3,
        state: _currentStep == 3 ? StepState.indexed : StepState.disabled,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.tripId != null ? 'Edit Trip' : 'Create Trip'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tripId != null ? 'Edit Trip' : 'Create Trip'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stepper(
        currentStep: _currentStep,
        onStepTapped: (step) {
          // Only allow going to previous steps or current step
          if (step <= _currentStep || (_trip != null && step == 1)) {
            setState(() {
              _currentStep = step;
            });
          }
        },
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() {
              _currentStep += 1;
            });
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          } else {
            Navigator.of(context).pop();
          }
        },
        controlsBuilder: (context, details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                if (_currentStep < 3 && _trip != null)
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    child: const Text('Continue'),
                  ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: details.onStepCancel,
                  child: Text(_currentStep == 0 ? 'Cancel' : 'Back'),
                ),
              ],
            ),
          );
        },
        steps: _buildSteps(),
      ),
    );
  }
}
