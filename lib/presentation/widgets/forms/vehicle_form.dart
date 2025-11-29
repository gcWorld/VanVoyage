import 'package:flutter/material.dart';
import '../../../domain/entities/vehicle.dart';
import '../../../domain/enums/fuel_type.dart';

/// A form widget for creating or editing vehicle information.
class VehicleForm extends StatefulWidget {
  /// Optional existing vehicle to edit
  final Vehicle? vehicle;

  /// Callback when vehicle is saved
  final Function(Vehicle vehicle) onSave;

  /// Scroll controller for the parent DraggableScrollableSheet
  final ScrollController? scrollController;

  const VehicleForm({
    super.key,
    this.vehicle,
    required this.onSave,
    this.scrollController,
  });

  @override
  State<VehicleForm> createState() => _VehicleFormState();
}

class _VehicleFormState extends State<VehicleForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _fuelConsumptionController;
  late TextEditingController _heightController;
  late TextEditingController _widthController;
  late TextEditingController _lengthController;
  late TextEditingController _weightController;
  late TextEditingController _maxSpeedController;

  late FuelType _selectedFuelType;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.vehicle?.name ?? '');
    _fuelConsumptionController = TextEditingController(
      text: widget.vehicle?.fuelConsumption.toString() ?? '10.0',
    );
    _heightController = TextEditingController(
      text: widget.vehicle?.height?.toString() ?? '',
    );
    _widthController = TextEditingController(
      text: widget.vehicle?.width?.toString() ?? '',
    );
    _lengthController = TextEditingController(
      text: widget.vehicle?.length?.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: widget.vehicle?.weight?.toString() ?? '',
    );
    _maxSpeedController = TextEditingController(
      text: widget.vehicle?.maxSpeed?.toString() ?? '',
    );

    _selectedFuelType = widget.vehicle?.fuelType ?? FuelType.diesel;
    _isDefault = widget.vehicle?.isDefault ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fuelConsumptionController.dispose();
    _heightController.dispose();
    _widthController.dispose();
    _lengthController.dispose();
    _weightController.dispose();
    _maxSpeedController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final vehicle = widget.vehicle != null
          ? widget.vehicle!.copyWith(
              name: _nameController.text.trim(),
              fuelType: _selectedFuelType,
              fuelConsumption: double.parse(_fuelConsumptionController.text),
              height: _parseOptionalDouble(_heightController.text),
              width: _parseOptionalDouble(_widthController.text),
              length: _parseOptionalDouble(_lengthController.text),
              weight: _parseOptionalDouble(_weightController.text),
              maxSpeed: _parseOptionalInt(_maxSpeedController.text),
              isDefault: _isDefault,
              updatedAt: DateTime.now(),
            )
          : Vehicle.create(
              name: _nameController.text.trim(),
              fuelType: _selectedFuelType,
              fuelConsumption: double.parse(_fuelConsumptionController.text),
              height: _parseOptionalDouble(_heightController.text),
              width: _parseOptionalDouble(_widthController.text),
              length: _parseOptionalDouble(_lengthController.text),
              weight: _parseOptionalDouble(_weightController.text),
              maxSpeed: _parseOptionalInt(_maxSpeedController.text),
              isDefault: _isDefault,
            );

      widget.onSave(vehicle);
    }
  }

  double? _parseOptionalDouble(String value) {
    if (value.trim().isEmpty) return null;
    return double.tryParse(value);
  }

  int? _parseOptionalInt(String value) {
    if (value.trim().isEmpty) return null;
    return int.tryParse(value);
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
              widget.vehicle != null ? 'Edit Vehicle' : 'Add Vehicle',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),

            // Basic Information Section
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Name',
                hintText: 'e.g., My Camper Van',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a vehicle name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Fuel Type dropdown
            DropdownButtonFormField<FuelType>(
              value: _selectedFuelType,
              decoration: const InputDecoration(
                labelText: 'Fuel Type',
                prefixIcon: Icon(Icons.local_gas_station),
                border: OutlineInputBorder(),
              ),
              items: FuelType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFuelType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Fuel consumption field
            TextFormField(
              controller: _fuelConsumptionController,
              decoration: InputDecoration(
                labelText: _selectedFuelType == FuelType.electric
                    ? 'Energy Consumption (kWh/100km)'
                    : 'Fuel Consumption (L/100km)',
                hintText: _selectedFuelType == FuelType.electric
                    ? 'e.g., 20.0'
                    : 'e.g., 10.0',
                prefixIcon: const Icon(Icons.speed),
                border: const OutlineInputBorder(),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter fuel consumption';
                }
                final parsed = double.tryParse(value);
                if (parsed == null || parsed <= 0) {
                  return 'Please enter a valid positive number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Dimensions Section
            Text(
              'Vehicle Dimensions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Optional: Used by Mapbox to avoid roads with vehicle restrictions.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Height and Width row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (m)',
                      hintText: 'e.g., 2.8',
                      prefixIcon: Icon(Icons.height),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0 || parsed > 10) {
                          return 'Invalid (0-10m)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _widthController,
                    decoration: const InputDecoration(
                      labelText: 'Width (m)',
                      hintText: 'e.g., 2.2',
                      prefixIcon: Icon(Icons.swap_horiz),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0 || parsed > 10) {
                          return 'Invalid (0-10m)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Length and Weight row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _lengthController,
                    decoration: const InputDecoration(
                      labelText: 'Length (m)',
                      hintText: 'e.g., 6.0',
                      prefixIcon: Icon(Icons.straighten),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0 || parsed > 30) {
                          return 'Invalid (0-30m)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (t)',
                      hintText: 'e.g., 3.5',
                      prefixIcon: Icon(Icons.scale),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        final parsed = double.tryParse(value);
                        if (parsed == null || parsed <= 0 || parsed > 100) {
                          return 'Invalid (0-100t)';
                        }
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Max Speed
            TextFormField(
              controller: _maxSpeedController,
              decoration: const InputDecoration(
                labelText: 'Maximum Speed (km/h)',
                hintText: 'e.g., 100',
                prefixIcon: Icon(Icons.speed),
                border: OutlineInputBorder(),
                helperText: 'Optional: Recommended cruising speed',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final parsed = int.tryParse(value);
                  if (parsed == null || parsed <= 0 || parsed > 200) {
                    return 'Please enter a valid speed (1-200 km/h)';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Default switch
            SwitchListTile(
              title: const Text('Set as default vehicle'),
              subtitle: const Text('Use this vehicle for new trips'),
              value: _isDefault,
              onChanged: (value) {
                setState(() {
                  _isDefault = value;
                });
              },
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: Text(
                    widget.vehicle != null ? 'Update Vehicle' : 'Add Vehicle'),
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
