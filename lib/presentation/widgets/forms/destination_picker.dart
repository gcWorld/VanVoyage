import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../secrets.dart';
import '../../../domain/enums/waypoint_type.dart';

/// A widget for picking destinations with map integration
class DestinationPicker extends StatefulWidget {
  /// Callback when a location is selected
  final Function(String name, double latitude, double longitude, WaypointType type) onLocationSelected;
  
  /// Initial location to display (optional)
  final ({double latitude, double longitude})? initialLocation;
  
  const DestinationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
  });

  @override
  State<DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends State<DestinationPicker> {
  final _nameController = TextEditingController();
  MapboxMap? _mapboxMap;
  Position? _selectedPosition;
  WaypointType _selectedType = WaypointType.poi;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedPosition = Position(
        widget.initialLocation!.longitude,
        widget.initialLocation!.latitude,
      );
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
    
    // Add tap listener to select location
    _mapboxMap!.gestures.addOnMapClickListener(_onMapClick);
  }
  
  Future<void> _onMapClick(MapContentGestureContext context) async {
    setState(() {
      _selectedPosition = context.point.coordinates;
    });
    
    // Show selected location indicator
    _updateMarker();
    
    return true;
  }
  
  Future<void> _updateMarker() async {
    if (_selectedPosition == null) return;
    
    // Create annotation manager if needed
    final annotationManager = await _mapboxMap!.annotations.createPointAnnotationManager();
    
    // Clear existing annotations
    await annotationManager.deleteAll();
    
    // Add marker at selected position
    final options = PointAnnotationOptions(
      geometry: Point(coordinates: _selectedPosition!),
      iconImage: 'marker',
      iconSize: 1.5,
    );
    
    await annotationManager.create(options);
  }
  
  void _confirmSelection() {
    if (_selectedPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location on the map')),
      );
      return;
    }
    
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a location name')),
      );
      return;
    }
    
    widget.onLocationSelected(
      _nameController.text.trim(),
      _selectedPosition!.coordinates.lat.toDouble(),
      _selectedPosition!.coordinates.lng.toDouble(),
      _selectedType,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Location name input
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Location Name',
                  hintText: 'Enter destination name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.place),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Waypoint type selector
              SegmentedButton<WaypointType>(
                segments: const [
                  ButtonSegment(
                    value: WaypointType.poi,
                    label: Text('POI'),
                    icon: Icon(Icons.place),
                  ),
                  ButtonSegment(
                    value: WaypointType.overnightStay,
                    label: Text('Stay'),
                    icon: Icon(Icons.hotel),
                  ),
                  ButtonSegment(
                    value: WaypointType.transit,
                    label: Text('Transit'),
                    icon: Icon(Icons.navigation),
                  ),
                ],
                selected: {_selectedType},
                onSelectionChanged: (Set<WaypointType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                  });
                },
              ),
              
              if (_selectedPosition != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Coordinates',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 4),
                        Text('Lat: ${_selectedPosition!.coordinates.lat.toStringAsFixed(6)}'),
                        Text('Lng: ${_selectedPosition!.coordinates.lng.toStringAsFixed(6)}'),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Map view
        Expanded(
          child: Stack(
            children: [
              MapWidget(
                resourceOptions: ResourceOptions(accessToken: mapboxApiKey),
                cameraOptions: CameraOptions(
                  center: widget.initialLocation != null
                      ? Point(
                          coordinates: Position(
                            widget.initialLocation!.longitude,
                            widget.initialLocation!.latitude,
                          ),
                        )
                      : Point(coordinates: Position(-122.4194, 37.7749)), // SF default
                  zoom: 12.0,
                ),
                styleUri: MapboxStyles.OUTDOORS,
                onMapCreated: _onMapCreated,
              ),
              
              // Instruction overlay
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        const Icon(Icons.touch_app, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tap on the map to select a location',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Confirm button
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: _confirmSelection,
            icon: const Icon(Icons.check),
            label: const Text('Confirm Location'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
            ),
          ),
        ),
      ],
    );
  }
}
