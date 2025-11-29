import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/home_location.dart';
import '../../../providers.dart';

/// A widget for selecting a home location using address search or coordinates.
class HomeLocationPicker extends ConsumerStatefulWidget {
  /// Current home location (for editing)
  final HomeLocation? currentLocation;

  /// Callback when a location is selected
  final Function(
          String name, double latitude, double longitude, String? address)
      onLocationSelected;

  /// Scroll controller for the parent DraggableScrollableSheet
  final ScrollController? scrollController;

  const HomeLocationPicker({
    super.key,
    this.currentLocation,
    required this.onLocationSelected,
    this.scrollController,
  });

  @override
  ConsumerState<HomeLocationPicker> createState() => _HomeLocationPickerState();
}

class _HomeLocationPickerState extends ConsumerState<HomeLocationPicker> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _searchController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  bool _isSearching = false;
  bool _useManualCoordinates = false;
  List<_SearchResult> _searchResults = [];
  _SearchResult? _selectedResult;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.currentLocation?.name ?? 'Home',
    );
    _searchController = TextEditingController(
      text: widget.currentLocation?.address ?? '',
    );
    _latitudeController = TextEditingController(
      text: widget.currentLocation?.latitude.toString() ?? '',
    );
    _longitudeController = TextEditingController(
      text: widget.currentLocation?.longitude.toString() ?? '',
    );

    // If we have an existing location, pre-populate the selected result
    if (widget.currentLocation != null) {
      _selectedResult = _SearchResult(
        name: widget.currentLocation!.name,
        address: widget.currentLocation!.address ?? '',
        latitude: widget.currentLocation!.latitude,
        longitude: widget.currentLocation!.longitude,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResults = [];
    });

    try {
      final mapboxService = ref.read(mapboxServiceProvider);
      final results = await mapboxService.searchPlaces(query);

      if (mounted) {
        setState(() {
          _searchResults = results
              .map((r) => _SearchResult(
                    name: r.placeName.split(',').first,
                    address: r.placeName,
                    latitude: r.latitude,
                    longitude: r.longitude,
                  ))
              .toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error searching: $e')),
        );
      }
    }
  }

  void _selectResult(_SearchResult result) {
    setState(() {
      _selectedResult = result;
      _searchResults = [];
      _searchController.text = result.address;
      _latitudeController.text = result.latitude.toString();
      _longitudeController.text = result.longitude.toString();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isSearching = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);

      // Check permissions
      if (!await locationService.hasPermission()) {
        final granted = await locationService.requestPermission();
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permission denied')),
            );
          }
          setState(() => _isSearching = false);
          return;
        }
      }

      // Get current position
      final position = await locationService.getCurrentLocation();

      // Reverse geocode to get address
      final mapboxService = ref.read(mapboxServiceProvider);
      final address = await mapboxService.reverseGeocode(
        position.latitude,
        position.longitude,
      );

      if (mounted) {
        setState(() {
          _latitudeController.text = position.latitude.toString();
          _longitudeController.text = position.longitude.toString();
          _searchController.text = address ?? 'Current Location';
          _selectedResult = _SearchResult(
            name: 'Current Location',
            address: address ?? 'Current Location',
            latitude: position.latitude,
            longitude: position.longitude,
          );
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Additional validation for non-manual mode
    if (!_useManualCoordinates && _selectedResult == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location')),
      );
      return;
    }

    final name = _nameController.text.trim();
    final latitude = double.parse(_latitudeController.text);
    final longitude = double.parse(_longitudeController.text);
    final address = _searchController.text.trim().isNotEmpty
        ? _searchController.text.trim()
        : null;

    widget.onLocationSelected(name, latitude, longitude, address);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.all(16),
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Text(
              widget.currentLocation != null
                  ? 'Edit Home Location'
                  : 'Set Home Location',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'This location will be used as the default start and end point for your trips.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Location Name',
                hintText: 'e.g., Home, Apartment',
                prefixIcon: Icon(Icons.label),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Toggle for manual coordinates
            SwitchListTile(
              title: const Text('Enter coordinates manually'),
              subtitle: const Text('For precise location entry'),
              value: _useManualCoordinates,
              onChanged: (value) {
                setState(() {
                  _useManualCoordinates = value;
                });
              },
            ),
            const SizedBox(height: 16),

            if (!_useManualCoordinates) ...[
              // Search field
              TextFormField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Search Address',
                  hintText: 'Enter address to search',
                  prefixIcon: const Icon(Icons.search),
                  border: const OutlineInputBorder(),
                  suffixIcon: _isSearching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchAddress,
                        ),
                ),
                onFieldSubmitted: (_) => _searchAddress(),
              ),
              const SizedBox(height: 8),

              // Current location button
              OutlinedButton.icon(
                onPressed: _isSearching ? null : _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Use Current Location'),
              ),
              const SizedBox(height: 16),

              // Search results
              if (_searchResults.isNotEmpty) ...[
                Text(
                  'Search Results',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return ListTile(
                        leading: const Icon(Icons.place),
                        title: Text(
                          result.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          result.address,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => _selectResult(result),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Selected location display
              if (_selectedResult != null) ...[
                Card(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Selected Location',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedResult!.address,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Lat: ${_selectedResult!.latitude.toStringAsFixed(6)}, '
                          'Lng: ${_selectedResult!.longitude.toStringAsFixed(6)}',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer
                                        .withOpacity(0.8),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],

            if (_useManualCoordinates) ...[
              // Manual coordinate entry
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude',
                        hintText: 'e.g., 48.8566',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final lat = double.tryParse(value);
                        if (lat == null || lat < -90 || lat > 90) {
                          return 'Invalid (-90 to 90)';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _longitudeController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude',
                        hintText: 'e.g., 2.3522',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                        signed: true,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Required';
                        }
                        final lng = double.tryParse(value);
                        if (lng == null || lng < -180 || lng > 180) {
                          return 'Invalid (-180 to 180)';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_selectedResult != null || _useManualCoordinates)
                    ? _save
                    : null,
                icon: const Icon(Icons.save),
                label: const Text('Save Home Location'),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Internal class for search results
class _SearchResult {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  _SearchResult({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}
