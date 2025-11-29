import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../../domain/entities/waypoint.dart';
import '../../../domain/enums/waypoint_type.dart';
import '../../../infrastructure/services/mapbox_service.dart';
import '../../../providers.dart';
import '../waypoint_list.dart';

/// A widget for picking destinations with map integration
class DestinationPicker extends ConsumerStatefulWidget {
  /// Callback when a location is selected
  final Function(
          String name, double latitude, double longitude, WaypointType type)
      onLocationSelected;

  /// Initial location to display (optional)
  final ({double latitude, double longitude})? initialLocation;

  /// List of existing waypoints
  final List<Waypoint> waypoints;

  /// Callback when waypoints are reordered
  final Function(int oldIndex, int newIndex)? onReorder;

  /// Callback when a waypoint is deleted
  final Function(Waypoint)? onDelete;

  /// Callback when waypoints should be optimized
  final Function()? onOptimize;

  const DestinationPicker({
    super.key,
    required this.onLocationSelected,
    this.initialLocation,
    this.waypoints = const [],
    this.onReorder,
    this.onDelete,
    this.onOptimize,
  });

  @override
  ConsumerState<DestinationPicker> createState() => _DestinationPickerState();
}

class _DestinationPickerState extends ConsumerState<DestinationPicker> {
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();
  double? _selectedLatitude;
  double? _selectedLongitude;
  WaypointType _selectedType = WaypointType.poi;
  List<MapboxLocation> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;
  MapboxMap? _mapboxMap;

  @override
  void initState() {
    super.initState();
    if (widget.initialLocation != null) {
      _selectedLatitude = widget.initialLocation!.latitude;
      _selectedLongitude = widget.initialLocation!.longitude;
    }
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.isNotEmpty) {
        _performSearch(_searchController.text);
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final mapboxService = ref.read(mapboxServiceProvider);
      final results = await mapboxService.searchPlaces(query);

      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  void _selectSearchResult(MapboxLocation location) {
    setState(() {
      _selectedLatitude = location.latitude;
      _selectedLongitude = location.longitude;
      _nameController.text = location.placeName;
      _searchController.clear();
      _searchResults = [];
    });

    // Update map camera to show selected location
    if (_mapboxMap != null) {
      _mapboxMap!.flyTo(
        CameraOptions(
          center: Point(
            coordinates: Position(location.longitude, location.latitude),
          ),
          zoom: 14.0,
        ),
        MapAnimationOptions(duration: 1000),
      );
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    _mapboxMap = mapboxMap;
  }

  Future<void> _onMapTap(Offset screenPosition) async {
    if (_mapboxMap == null) return;

    try {
      // Convert screen coordinates to geographic coordinates using Mapbox SDK
      final point = await _mapboxMap!.coordinateForPixel(
        ScreenCoordinate(x: screenPosition.dx, y: screenPosition.dy),
      );

      setState(() {
        _selectedLatitude = point.coordinates.lat.toDouble();
        _selectedLongitude = point.coordinates.lng.toDouble();
      });

      // Optionally reverse geocode to get place name
      _reverseGeocode(
          point.coordinates.lat.toDouble(), point.coordinates.lng.toDouble());
    } catch (e) {
      // Handle error silently
      debugPrint('Error converting tap to coordinates: $e');
    }
  }

  Future<void> _reverseGeocode(double lat, double lng) async {
    try {
      final mapboxService = ref.read(mapboxServiceProvider);
      final placeName = await mapboxService.reverseGeocode(lat, lng);

      if (mounted && placeName != null && _nameController.text.isEmpty) {
        setState(() {
          _nameController.text = placeName;
        });
      }
    } catch (e) {
      // Silently fail - user can still enter name manually
      debugPrint('Error reverse geocoding: $e');
    }
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
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
    return Row(
      children: [
        // Left side: Waypoint list
        if (widget.waypoints.isNotEmpty)
          SizedBox(
            width: 300,
            child: WaypointList(
              waypoints: widget.waypoints,
              onReorder: widget.onReorder,
              onDelete: widget.onDelete,
              onOptimize: widget.onOptimize,
            ),
          ),

        // Divider
        if (widget.waypoints.isNotEmpty) const VerticalDivider(width: 1),

        // Right side: Destination picker (existing functionality)
        Expanded(
          child: Column(
            children: [
              // Location search and name input
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search field with autocomplete
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search Location',
                        hintText: 'Search for a place...',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                      });
                                    },
                                  )
                                : null,
                      ),
                    ),

                    // Search results dropdown
                    if (_searchResults.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                          color: Theme.of(context).cardColor,
                        ),
                        constraints: const BoxConstraints(maxHeight: 200),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _searchResults.length,
                          itemBuilder: (context, index) {
                            final location = _searchResults[index];
                            return ListTile(
                              leading: const Icon(Icons.location_on),
                              title: Text(
                                location.placeName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              onTap: () => _selectSearchResult(location),
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 16),

                    // Location name input (after search)
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Location Name',
                        hintText: 'Enter or confirm destination name',
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

                    if (_selectedLatitude != null &&
                        _selectedLongitude != null) ...[
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
                              Text(
                                  'Lat: ${_selectedLatitude!.toStringAsFixed(6)}'),
                              Text(
                                  'Lng: ${_selectedLongitude!.toStringAsFixed(6)}'),
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
                    GestureDetector(
                      onTapDown: (TapDownDetails details) {
                        _onMapTap(details.localPosition);
                      },
                      child: MapWidget(
                        key: const ValueKey('destinationPickerMap'),
                        cameraOptions: CameraOptions(
                          center: widget.initialLocation != null
                              ? Point(
                                  coordinates: Position(
                                    widget.initialLocation!.longitude,
                                    widget.initialLocation!.latitude,
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
                                  'Search for a location above or tap on the map to select',
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
          ),
        ),
      ],
    );
  }
}
