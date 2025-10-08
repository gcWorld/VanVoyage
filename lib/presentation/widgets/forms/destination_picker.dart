import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
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
  double? _selectedLatitude;
  double? _selectedLongitude;
  WaypointType _selectedType = WaypointType.poi;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLatitude = widget.initialLocation!.latitude;
      _selectedLongitude = widget.initialLocation!.longitude;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
  
  void _onMapCreated(MapboxMap mapboxMap) {
    // TODO: Implement map tap gesture handling
    // The current Mapbox Flutter SDK version has changed gesture APIs
    // For now, users can manually enter coordinates or use search
  }
  
  void _selectLocationManually() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Coordinates'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Latitude',
                hintText: 'e.g., 37.7749',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                _selectedLatitude = double.tryParse(value);
              },
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Longitude',
                hintText: 'e.g., -122.4194',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                _selectedLongitude = double.tryParse(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Set Location'),
          ),
        ],
      ),
    );
  }
  
  void _confirmSelection() {
    if (_selectedLatitude == null || _selectedLongitude == null) {
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
      _selectedLatitude!,
      _selectedLongitude!,
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
              
              // Manual coordinate entry button
              OutlinedButton.icon(
                onPressed: _selectLocationManually,
                icon: const Icon(Icons.edit_location),
                label: const Text('Enter Coordinates Manually'),
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
              
              if (_selectedLatitude != null && _selectedLongitude != null) ...[
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
                        Text('Lat: ${_selectedLatitude!.toStringAsFixed(6)}'),
                        Text('Lng: ${_selectedLongitude!.toStringAsFixed(6)}'),
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
                key: const ValueKey('destinationPickerMap'),
                cameraOptions: CameraOptions(
                  center: widget.initialLocation != null
                      ? {
                          'lng': widget.initialLocation!.longitude,
                          'lat': widget.initialLocation!.latitude,
                        }
                      : {'lng': -122.4194, 'lat': 37.7749}, // SF default
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
                            'Use "Enter Coordinates Manually" button above to select a location',
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