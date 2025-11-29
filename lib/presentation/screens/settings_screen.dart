import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/home_location.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/enums/fuel_type.dart';
import '../../providers.dart';
import '../widgets/forms/home_location_picker.dart';
import '../widgets/forms/vehicle_form.dart';

/// Screen for managing application settings including home location and vehicles.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  AppSettings? _settings;
  List<Vehicle> _vehicles = [];
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
      final settingsRepo = await ref.read(settingsRepositoryProvider.future);
      final vehicleRepo = await ref.read(vehicleRepositoryProvider.future);

      final settings = await settingsRepo.getSettings();
      final vehicles = await vehicleRepo.findAll();

      if (mounted) {
        setState(() {
          _settings = settings;
          _vehicles = vehicles;
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

  void _showHomeLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => HomeLocationPicker(
          currentLocation: _settings?.homeLocation,
          onLocationSelected: _onHomeLocationSelected,
          scrollController: scrollController,
        ),
      ),
    );
  }

  Future<void> _onHomeLocationSelected(
    String name,
    double latitude,
    double longitude,
    String? address,
  ) async {
    Navigator.of(context).pop();

    try {
      final settingsRepo = await ref.read(settingsRepositoryProvider.future);
      await settingsRepo.updateHomeLocation(
        HomeLocation(
          name: name,
          latitude: latitude,
          longitude: longitude,
          address: address,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Home location updated')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating home location: $e')),
        );
      }
    }
  }

  Future<void> _clearHomeLocation() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Home Location'),
        content:
            const Text('Are you sure you want to remove your home location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final settingsRepo = await ref.read(settingsRepositoryProvider.future);
        await settingsRepo.clearHomeLocation();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Home location cleared')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing home location: $e')),
          );
        }
      }
    }
  }

  void _showVehicleForm({Vehicle? vehicle}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => VehicleForm(
          vehicle: vehicle,
          onSave: (savedVehicle) =>
              _onVehicleSaved(savedVehicle, vehicle == null),
          scrollController: scrollController,
        ),
      ),
    );
  }

  Future<void> _onVehicleSaved(Vehicle vehicle, bool isNew) async {
    Navigator.of(context).pop();

    try {
      final vehicleRepo = await ref.read(vehicleRepositoryProvider.future);

      if (isNew) {
        await vehicleRepo.insert(vehicle);
      } else {
        await vehicleRepo.update(vehicle);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNew ? 'Vehicle added' : 'Vehicle updated'),
          ),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving vehicle: $e')),
        );
      }
    }
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text('Are you sure you want to delete "${vehicle.name}"?'),
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
        final vehicleRepo = await ref.read(vehicleRepositoryProvider.future);
        await vehicleRepo.delete(vehicle.id);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted vehicle: ${vehicle.name}')),
          );
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting vehicle: $e')),
          );
        }
      }
    }
  }

  Future<void> _setDefaultVehicle(Vehicle vehicle) async {
    try {
      final vehicleRepo = await ref.read(vehicleRepositoryProvider.future);
      final settingsRepo = await ref.read(settingsRepositoryProvider.future);

      await vehicleRepo.setAsDefault(vehicle.id);
      await settingsRepo.setDefaultVehicle(vehicle.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${vehicle.name} set as default')),
        );
        _loadData();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error setting default vehicle: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
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
              'Error loading settings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center),
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Home Location Section
          _buildSectionHeader('Home Location'),
          const SizedBox(height: 8),
          _buildHomeLocationCard(),
          const SizedBox(height: 24),

          // Vehicles Section
          _buildSectionHeader('Vehicles'),
          const SizedBox(height: 8),
          _buildVehiclesSection(),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader('About'),
          const SizedBox(height: 8),
          _buildAboutCard(),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildHomeLocationCard() {
    final homeLocation = _settings?.homeLocation;

    return Card(
      child: homeLocation != null
          ? ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.home),
              ),
              title: Text(homeLocation.name),
              subtitle: Text(
                homeLocation.address ??
                    '${homeLocation.latitude.toStringAsFixed(4)}, ${homeLocation.longitude.toStringAsFixed(4)}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: _showHomeLocationPicker,
                    tooltip: 'Edit',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: _clearHomeLocation,
                    tooltip: 'Clear',
                  ),
                ],
              ),
            )
          : ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.home_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              title: const Text('No home location set'),
              subtitle:
                  const Text('Set a default start/end location for trips'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: _showHomeLocationPicker,
                tooltip: 'Set home location',
              ),
            ),
    );
  }

  Widget _buildVehiclesSection() {
    return Column(
      children: [
        if (_vehicles.isEmpty)
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.directions_car_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              title: const Text('No vehicles added'),
              subtitle: const Text('Add your vehicle for route planning'),
              trailing: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showVehicleForm(),
                tooltip: 'Add vehicle',
              ),
            ),
          )
        else
          ...List.generate(_vehicles.length, (index) {
            final vehicle = _vehicles[index];
            return _buildVehicleCard(vehicle);
          }),
        const SizedBox(height: 8),
        if (_vehicles.isNotEmpty)
          OutlinedButton.icon(
            onPressed: () => _showVehicleForm(),
            icon: const Icon(Icons.add),
            label: const Text('Add Vehicle'),
          ),
      ],
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showVehicleForm(vehicle: vehicle),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getVehicleIcon(vehicle),
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vehicle.name,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            if (vehicle.isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Default',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${vehicle.fuelType.displayName} • ${vehicle.fuelConsumption.toStringAsFixed(1)} L/100km',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showVehicleForm(vehicle: vehicle);
                          break;
                        case 'default':
                          _setDefaultVehicle(vehicle);
                          break;
                        case 'delete':
                          _deleteVehicle(vehicle);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit),
                          title: Text('Edit'),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      if (!vehicle.isDefault)
                        const PopupMenuItem(
                          value: 'default',
                          child: ListTile(
                            leading: Icon(Icons.star),
                            title: Text('Set as default'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
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
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (vehicle.hasDimensionConstraints) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 16,
                  runSpacing: 4,
                  children: [
                    if (vehicle.height != null)
                      _buildDimensionChip('Height', '${vehicle.height}m'),
                    if (vehicle.width != null)
                      _buildDimensionChip('Width', '${vehicle.width}m'),
                    if (vehicle.weight != null)
                      _buildDimensionChip('Weight', '${vehicle.weight}t'),
                    if (vehicle.maxSpeed != null)
                      _buildDimensionChip(
                          'Max Speed', '${vehicle.maxSpeed} km/h'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDimensionChip(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(Vehicle vehicle) {
    switch (vehicle.fuelType) {
      case FuelType.electric:
        return Icons.electric_car;
      case FuelType.hybrid:
        return Icons.eco;
      default:
        return Icons.directions_car;
    }
  }

  Widget _buildAboutCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Vehicle Routing Constraints'),
            subtitle: const Text(
              'Vehicle dimensions (height, width, weight) are used by Mapbox to avoid roads with restrictions.',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.route),
            title: const Text('Mapbox Integration'),
            subtitle: const Text(
              'Routes are calculated using Mapbox Directions API with support for vehicle-specific routing.',
            ),
          ),
        ],
      ),
    );
  }
}
