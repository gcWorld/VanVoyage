import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import '../../infrastructure/services/location_service.dart';

/// Interactive map screen with Mapbox GL integration
class InteractiveMapScreen extends ConsumerStatefulWidget {
  const InteractiveMapScreen({super.key});

  @override
  ConsumerState<InteractiveMapScreen> createState() =>
      _InteractiveMapScreenState();
}

class _InteractiveMapScreenState extends ConsumerState<InteractiveMapScreen> {
  MapboxMap? _mapController;
  final LocationService _locationService = LocationService();
  geolocator.Position? _currentPosition;
  bool _isTrackingLocation = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
        _updateUserLocation(position);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  void _updateUserLocation(geolocator.Position position) {
    if (_mapController != null) {
      _mapController!.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position(position.longitude, position.latitude),
          ),
          zoom: 14.0,
        ),
      );
    }
  }

  Future<void> _centerOnLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      _updateUserLocation(position);
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get location: $e')),
        );
      }
    }
  }

  void _toggleLocationTracking() {
    setState(() {
      _isTrackingLocation = !_isTrackingLocation;
    });

    if (_isTrackingLocation) {
      _locationService.getLocationStream().listen((position) {
        if (_isTrackingLocation && mounted) {
          setState(() {
            _currentPosition = position;
          });
          _updateUserLocation(position);
        }
      });
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

    // Initialize with current location if available
    if (_currentPosition != null) {
      _updateUserLocation(_currentPosition!);
    }
  }

  void _zoomIn() {
    _mapController?.getCameraState().then((cameraState) {
      _mapController!.setCamera(
        CameraOptions(
          zoom: (cameraState.zoom) + 1.0,
        ),
      );
    });
  }

  void _zoomOut() {
    _mapController?.getCameraState().then((cameraState) {
      _mapController!.setCamera(
        CameraOptions(
          zoom: (cameraState.zoom) - 1.0,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Stack(
        children: [
          // Map widget
          MapWidget(
            key: const ValueKey('mapWidget'),
            cameraOptions: CameraOptions(
              center: _currentPosition != null
                  ? Point(
                      coordinates: Position(
                        _currentPosition!.longitude,
                        _currentPosition!.latitude,
                      ),
                    )
                  : Point(
                      coordinates: Position(-122.4194, 37.7749),
                    ), // SF default
              zoom: 12.0,
            ),
            styleUri: MapboxStyles.OUTDOORS,
            onMapCreated: _onMapCreated,
          ),

          // Map controls
          Positioned(
            right: 16,
            bottom: 100,
            child: Column(
              children: [
                // Zoom in button
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: _zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                // Zoom out button
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: _zoomOut,
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(height: 8),
                // Center on location button
                FloatingActionButton(
                  heroTag: 'center_location',
                  mini: true,
                  onPressed: _centerOnLocation,
                  backgroundColor: _isTrackingLocation
                      ? Theme.of(context).colorScheme.primary
                      : null,
                  child: const Icon(Icons.my_location),
                ),
                const SizedBox(height: 8),
                // Toggle tracking button
                FloatingActionButton(
                  heroTag: 'toggle_tracking',
                  mini: true,
                  onPressed: _toggleLocationTracking,
                  backgroundColor: _isTrackingLocation ? Colors.green : null,
                  child: Icon(
                    _isTrackingLocation
                        ? Icons.location_searching
                        : Icons.location_disabled,
                  ),
                ),
              ],
            ),
          ),

          // Location info overlay
          if (_currentPosition != null)
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
                      Text(
                        'Current Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Accuracy: ${_currentPosition!.accuracy.toStringAsFixed(1)}m',
                        style: Theme.of(context).textTheme.bodySmall,
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
