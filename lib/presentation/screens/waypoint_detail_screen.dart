import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/waypoint.dart';
import '../../domain/enums/waypoint_type.dart';
import '../../providers.dart';

/// Screen for viewing and editing waypoint details including stay information
class WaypointDetailScreen extends ConsumerStatefulWidget {
  final Waypoint waypoint;

  const WaypointDetailScreen({
    super.key,
    required this.waypoint,
  });

  @override
  ConsumerState<WaypointDetailScreen> createState() =>
      _WaypointDetailScreenState();
}

class _WaypointDetailScreenState extends ConsumerState<WaypointDetailScreen> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _notesController;
  late WaypointType _waypointType;
  DateTime? _arrivalDate;
  DateTime? _departureDate;
  int? _stayDuration;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.waypoint.name);
    _descriptionController =
        TextEditingController(text: widget.waypoint.description ?? '');
    _notesController =
        TextEditingController(text: ''); // Notes could be in Activity
    _waypointType = widget.waypoint.waypointType;
    _arrivalDate = widget.waypoint.arrivalDate;
    _departureDate = widget.waypoint.departureDate;
    _stayDuration = widget.waypoint.stayDuration;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isArrival) async {
    final initialDate = isArrival
        ? _arrivalDate ?? DateTime.now()
        : _departureDate ?? _arrivalDate ?? DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (pickedDate != null) {
      setState(() {
        if (isArrival) {
          _arrivalDate = pickedDate;
          // Auto-calculate stay duration if both dates are set
          if (_departureDate != null) {
            _stayDuration = _departureDate!.difference(_arrivalDate!).inDays;
          }
        } else {
          _departureDate = pickedDate;
          // Auto-calculate stay duration if both dates are set
          if (_arrivalDate != null) {
            _stayDuration = _departureDate!.difference(_arrivalDate!).inDays;
          }
        }
      });
    }
  }

  Future<void> _saveWaypoint() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a waypoint name')),
      );
      return;
    }

    // Validate dates for overnight stays
    if (_waypointType == WaypointType.overnightStay) {
      if (_stayDuration == null || _stayDuration! < 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Overnight stays must have a duration of at least 1 day')),
        );
        return;
      }
    }

    if (_arrivalDate != null && _departureDate != null) {
      if (_departureDate!.isBefore(_arrivalDate!)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Departure date must be after arrival date')),
        );
        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final repo = await ref.read(waypointRepositoryProvider.future);

      final updatedWaypoint = widget.waypoint.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        waypointType: _waypointType,
        arrivalDate: _arrivalDate,
        departureDate: _departureDate,
        stayDuration: _stayDuration,
      );

      await repo.update(updatedWaypoint);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waypoint updated successfully')),
        );

        Navigator.of(context).pop(updatedWaypoint);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving waypoint: $e')),
        );
      }
    }
  }

  Widget _buildViewMode() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(_getWaypointIcon(),
                          size: 32,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.waypoint.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getWaypointTypeLabel(),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (widget.waypoint.description != null &&
                      widget.waypoint.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(widget.waypoint.description!),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Location Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Location',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (widget.waypoint.address != null)
                    Text(widget.waypoint.address!)
                  else
                    Text(
                      '${widget.waypoint.latitude.toStringAsFixed(6)}, ${widget.waypoint.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stay Details Card (for overnight stays)
          if (_waypointType == WaypointType.overnightStay) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.hotel,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Stay Details',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Arrival',
                      _arrivalDate != null
                          ? dateFormat.format(_arrivalDate!)
                          : 'Not set',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.event,
                      'Departure',
                      _departureDate != null
                          ? dateFormat.format(_departureDate!)
                          : 'Not set',
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.nights_stay,
                      'Duration',
                      _stayDuration != null
                          ? '$_stayDuration ${_stayDuration == 1 ? 'night' : 'nights'}'
                          : 'Not set',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Schedule Card (for non-overnight waypoints)
          if (_waypointType != WaypointType.overnightStay &&
              (_arrivalDate != null || _departureDate != null)) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.schedule,
                            color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Schedule',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_arrivalDate != null)
                      _buildInfoRow(
                        Icons.calendar_today,
                        'Visit Date',
                        dateFormat.format(_arrivalDate!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildEditMode() {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name Field
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Waypoint Name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            textCapitalization: TextCapitalization.words,
          ),

          const SizedBox(height: 16),

          // Description Field
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 16),

          // Waypoint Type
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Waypoint Type',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<WaypointType>(
                    segments: const [
                      ButtonSegment(
                        value: WaypointType.overnightStay,
                        label: Text('Stay'),
                        icon: Icon(Icons.hotel),
                      ),
                      ButtonSegment(
                        value: WaypointType.poi,
                        label: Text('Visit'),
                        icon: Icon(Icons.place),
                      ),
                      ButtonSegment(
                        value: WaypointType.transit,
                        label: Text('Transit'),
                        icon: Icon(Icons.route),
                      ),
                    ],
                    selected: {_waypointType},
                    onSelectionChanged: (Set<WaypointType> newSelection) {
                      setState(() {
                        _waypointType = newSelection.first;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Stay Details (for overnight stays)
          if (_waypointType == WaypointType.overnightStay) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stay Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),

                    // Arrival Date
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Arrival Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _arrivalDate != null
                              ? dateFormat.format(_arrivalDate!)
                              : 'Select arrival date',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Departure Date
                    InkWell(
                      onTap: () => _selectDate(context, false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Departure Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.event),
                        ),
                        child: Text(
                          _departureDate != null
                              ? dateFormat.format(_departureDate!)
                              : 'Select departure date',
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Stay Duration (auto-calculated or manual)
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Stay Duration (nights)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.nights_stay),
                        helperText:
                            'Auto-calculated from dates, or enter manually',
                      ),
                      keyboardType: TextInputType.number,
                      controller: TextEditingController(
                        text: _stayDuration?.toString() ?? '',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _stayDuration = int.tryParse(value);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_waypointType == WaypointType.poi) ...[
            // Visit Date for POI
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visit Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context, true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Visit Date (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          _arrivalDate != null
                              ? dateFormat.format(_arrivalDate!)
                              : 'Select visit date',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          const SizedBox(height: 24),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _saveWaypoint,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_isSaving ? 'Saving...' : 'Save Changes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getWaypointIcon() {
    switch (_waypointType) {
      case WaypointType.overnightStay:
        return Icons.hotel;
      case WaypointType.poi:
        return Icons.place;
      case WaypointType.transit:
        return Icons.route;
    }
  }

  String _getWaypointTypeLabel() {
    switch (_waypointType) {
      case WaypointType.overnightStay:
        return 'Overnight Stay';
      case WaypointType.poi:
        return 'Point of Interest';
      case WaypointType.transit:
        return 'Transit Point';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Waypoint' : 'Waypoint Details'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              tooltip: 'Edit',
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset to original values
                  _nameController.text = widget.waypoint.name;
                  _descriptionController.text =
                      widget.waypoint.description ?? '';
                  _waypointType = widget.waypoint.waypointType;
                  _arrivalDate = widget.waypoint.arrivalDate;
                  _departureDate = widget.waypoint.departureDate;
                  _stayDuration = widget.waypoint.stayDuration;
                });
              },
              tooltip: 'Cancel',
            ),
        ],
      ),
      body: _isEditing ? _buildEditMode() : _buildViewMode(),
    );
  }
}
