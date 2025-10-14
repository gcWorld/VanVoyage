import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../domain/entities/route.dart' as domain;
import '../../domain/entities/waypoint.dart';
import '../../infrastructure/services/mapbox_service.dart';
import '../../providers.dart';
import '../widgets/map_route_layer.dart';
import '../widgets/route_info_card.dart';

/// Screen to display trip route with waypoints and route visualization
class TripRouteScreen extends ConsumerStatefulWidget {
  final String tripId;
  final List<Waypoint> waypoints;

  const TripRouteScreen({
    super.key,
    required this.tripId,
    required this.waypoints,
  });

  @override
  ConsumerState<TripRouteScreen> createState() => _TripRouteScreenState();
}

class _TripRouteScreenState extends ConsumerState<TripRouteScreen> {
  MapboxMap? _mapController;
  List<domain.Route> _routes = [];
  bool _isLoadingRoutes = false;
  bool _showingAlternatives = false;
  int _selectedRouteIndex = 0;
  String? _errorMessage;
  RoutingProfile _selectedProfile = RoutingProfile.driving;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    if (widget.waypoints.length < 2) {
      setState(() {
        _errorMessage = 'Need at least 2 waypoints to calculate route';
      });
      return;
    }

    setState(() {
      _isLoadingRoutes = true;
      _errorMessage = null;
    });

    try {
      final routeService = ref.read(routeServiceProvider);
      final routes = await routeService.calculateTripRoute(
        widget.tripId,
        widget.waypoints,
        forceRefresh: false,
        profile: _selectedProfile,
      );

      if (mounted) {
        setState(() {
          _routes = routes;
          _isLoadingRoutes = false;
        });

        // Visualize routes on map
        if (_routes.isNotEmpty && _mapController != null) {
          await _visualizeRoutes();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRoutes = false;
          _errorMessage = 'Failed to load routes: $e';
        });
      }
    }
  }

  Future<void> _loadAlternativeRoutes(Waypoint from, Waypoint to) async {
    setState(() {
      _isLoadingRoutes = true;
      _errorMessage = null;
      _showingAlternatives = true;
    });

    try {
      final routeService = ref.read(routeServiceProvider);
      final alternatives = await routeService.calculateRouteWithAlternatives(
        widget.tripId,
        from,
        to,
        profile: _selectedProfile,
      );

      if (mounted) {
        setState(() {
          _routes = alternatives;
          _isLoadingRoutes = false;
        });

        // Visualize alternatives on map
        if (_routes.isNotEmpty && _mapController != null) {
          await MapRouteLayer.addMultipleRoutesToMap(
            _mapController!,
            _routes,
            colors: [
              Colors.blue,
              Colors.grey.shade600,
              Colors.grey.shade400,
            ],
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRoutes = false;
          _errorMessage = 'Failed to load alternative routes: $e';
        });
      }
    }
  }

  Future<void> _visualizeRoutes() async {
    if (_routes.isEmpty || _mapController == null) return;

    try {
      if (_showingAlternatives) {
        await MapRouteLayer.addMultipleRoutesToMap(
          _mapController!,
          _routes,
          colors: [
            Colors.blue,
            Colors.grey.shade600,
            Colors.grey.shade400,
          ],
        );
      } else {
        // Show single route or connected route segments
        for (final route in _routes) {
          await MapRouteLayer.addRouteToMap(
            _mapController!,
            route,
            color: Colors.blue,
          );
        }
      }

      // Fit map to show all waypoints
      if (widget.waypoints.isNotEmpty) {
        await _fitMapToWaypoints();
      }
    } catch (e) {
      debugPrint('Error visualizing routes: $e');
    }
  }

  Future<void> _fitMapToWaypoints() async {
    if (_mapController == null || widget.waypoints.isEmpty) return;

    try {
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      for (final waypoint in widget.waypoints) {
        if (waypoint.latitude < minLat) minLat = waypoint.latitude;
        if (waypoint.latitude > maxLat) maxLat = waypoint.latitude;
        if (waypoint.longitude < minLng) minLng = waypoint.longitude;
        if (waypoint.longitude > maxLng) maxLng = waypoint.longitude;
      }

      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;

      await _mapController!.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(centerLng, centerLat),
          ),
          zoom: 8.0,
        ),
      );
    } catch (e) {
      debugPrint('Error fitting map to waypoints: $e');
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapController = mapboxMap;

    // Enable location component
    _mapController!.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,
      ),
    );

    // Visualize routes if already loaded
    if (_routes.isNotEmpty) {
      _visualizeRoutes();
    }
  }

  Future<void> _refreshRoutes() async {
    if (widget.waypoints.length < 2) return;

    setState(() {
      _isLoadingRoutes = true;
      _errorMessage = null;
      _showingAlternatives = false;
    });

    try {
      final routeService = ref.read(routeServiceProvider);
      final routes = await routeService.calculateTripRoute(
        widget.tripId,
        widget.waypoints,
        forceRefresh: true,
        profile: _selectedProfile,
      );

      if (mounted) {
        setState(() {
          _routes = routes;
          _isLoadingRoutes = false;
        });

        if (_routes.isNotEmpty && _mapController != null) {
          await _visualizeRoutes();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingRoutes = false;
          _errorMessage = 'Failed to refresh routes: $e';
        });
      }
    }
  }

  String _formatTotalDistance() {
    if (_routes.isEmpty) return '0 km';
    final total = _routes.fold<double>(0, (sum, route) => sum + route.distance);
    return '${total.toStringAsFixed(1)} km';
  }

  String _formatTotalDuration() {
    if (_routes.isEmpty) return '0 min';
    final total = _routes.fold<int>(0, (sum, route) => sum + route.duration);
    final hours = total ~/ 60;
    final minutes = total % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    }
    return '${minutes}min';
  }

  String _getProfileLabel(RoutingProfile profile) {
    switch (profile) {
      case RoutingProfile.driving:
        return 'Fastest';
      case RoutingProfile.drivingTraffic:
        return 'Traffic';
      case RoutingProfile.walking:
        return 'Walking';
      case RoutingProfile.cycling:
        return 'Cycling';
    }
  }

  IconData _getProfileIcon(RoutingProfile profile) {
    switch (profile) {
      case RoutingProfile.driving:
        return Icons.directions_car;
      case RoutingProfile.drivingTraffic:
        return Icons.traffic;
      case RoutingProfile.walking:
        return Icons.directions_walk;
      case RoutingProfile.cycling:
        return Icons.directions_bike;
    }
  }

  void _showProfileSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Select Route Type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Divider(height: 1),
            ...RoutingProfile.values.map((profile) => ListTile(
                  leading: Icon(_getProfileIcon(profile)),
                  title: Text(_getProfileLabel(profile)),
                  subtitle: Text(_getProfileDescription(profile)),
                  trailing: _selectedProfile == profile
                      ? const Icon(Icons.check, color: Colors.blue)
                      : null,
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedProfile = profile;
                      _showingAlternatives = false;
                    });
                    _refreshRoutes();
                  },
                )),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _getProfileDescription(RoutingProfile profile) {
    switch (profile) {
      case RoutingProfile.driving:
        return 'Fastest route by car';
      case RoutingProfile.drivingTraffic:
        return 'Route considering current traffic';
      case RoutingProfile.walking:
        return 'Walking route';
      case RoutingProfile.cycling:
        return 'Cycling route';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Route'),
        actions: [
          IconButton(
            icon: Icon(_getProfileIcon(_selectedProfile)),
            tooltip: 'Route type: ${_getProfileLabel(_selectedProfile)}',
            onPressed: _isLoadingRoutes ? null : _showProfileSelector,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh routes',
            onPressed: _isLoadingRoutes ? null : _refreshRoutes,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map
          MapWidget(
            key: const ValueKey('tripRouteMap'),
            cameraOptions: CameraOptions(
              center: widget.waypoints.isNotEmpty
                  ? Point(
                      coordinates: Position(
                        widget.waypoints.first.longitude,
                        widget.waypoints.first.latitude,
                      ),
                    )
                  : Point(
                      coordinates: Position(-122.4194, 37.7749),
                    ),
              zoom: 8.0,
            ),
            styleUri: MapboxStyles.OUTDOORS,
            onMapCreated: _onMapCreated,
          ),

          // Route info panel
          if (_routes.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Route Summary',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (_showingAlternatives)
                            TextButton(
                              onPressed: _loadRoutes,
                              child: const Text('Back to main route'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.straighten, size: 16),
                          const SizedBox(width: 4),
                          Text(_formatTotalDistance()),
                          const SizedBox(width: 16),
                          const Icon(Icons.schedule, size: 16),
                          const SizedBox(width: 4),
                          Text(_formatTotalDuration()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Route segments list
          if (_routes.isNotEmpty && !_showingAlternatives)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                constraints: const BoxConstraints(maxHeight: 300),
                child: Card(
                  margin: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text(
                          'Route Segments',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Divider(),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _routes.length,
                          itemBuilder: (context, index) {
                            final route = _routes[index];
                            final fromWaypoint = widget.waypoints.firstWhere(
                              (w) => w.id == route.fromWaypointId,
                            );
                            final toWaypoint = widget.waypoints.firstWhere(
                              (w) => w.id == route.toWaypointId,
                            );

                            return RouteInfoCard(
                              route: route,
                              fromWaypoint: fromWaypoint,
                              toWaypoint: toWaypoint,
                              onTap: () {
                                // Show alternatives for this segment
                                _loadAlternativeRoutes(fromWaypoint, toWaypoint);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Alternative routes selector
          if (_showingAlternatives && _routes.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Card(
                margin: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Alternative Routes',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ...List.generate(_routes.length, (index) {
                        final route = _routes[index];
                        final isSelected = index == _selectedRouteIndex;
                        
                        return Card(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : null,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: index == 0
                                  ? Colors.blue
                                  : Colors.grey,
                              child: Text('${index + 1}'),
                            ),
                            title: Text('${route.distance.toStringAsFixed(1)} km'),
                            subtitle: Text(
                              '${route.duration ~/ 60}h ${route.duration % 60}min',
                            ),
                            trailing: index == 0
                                ? const Chip(label: Text('Fastest'))
                                : null,
                            onTap: () {
                              setState(() {
                                _selectedRouteIndex = index;
                              });
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

          // Loading indicator
          if (_isLoadingRoutes)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Error message
          if (_errorMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController = null;
    super.dispose();
  }
}
