import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/trip.dart';

/// A form widget for creating and editing trips
class TripForm extends StatefulWidget {
  /// Optional existing trip to edit
  final Trip? trip;
  
  /// Callback when form is submitted
  final Function(
    String name, 
    String? description, 
    DateTime startDate, 
    DateTime endDate,
    DateTime? transitStartDate,
    DateTime? transitEndDate,
    DateTime? locationStartDate,
    DateTime? locationEndDate,
  ) onSubmit;
  
  const TripForm({
    super.key,
    this.trip,
    required this.onSubmit,
  });

  @override
  State<TripForm> createState() => _TripFormState();
}

class _TripFormState extends State<TripForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _usePhaseDates = false;
  DateTime? _transitStartDate;
  DateTime? _transitEndDate;
  DateTime? _locationStartDate;
  DateTime? _locationEndDate;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trip?.name ?? '');
    _descriptionController = TextEditingController(text: widget.trip?.description ?? '');
    _startDate = widget.trip?.startDate ?? DateTime.now();
    _endDate = widget.trip?.endDate ?? DateTime.now().add(const Duration(days: 7));
    
    // Initialize phase dates if they exist
    _transitStartDate = widget.trip?.transitStartDate;
    _transitEndDate = widget.trip?.transitEndDate;
    _locationStartDate = widget.trip?.locationStartDate;
    _locationEndDate = widget.trip?.locationEndDate;
    
    // Enable phase dates if any are set
    _usePhaseDates = _transitStartDate != null || _transitEndDate != null ||
                     _locationStartDate != null || _locationEndDate != null;
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          // Ensure end date is after start date
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectPhaseDate(BuildContext context, String type) async {
    DateTime? initialDate;
    switch (type) {
      case 'transitStart':
        initialDate = _transitStartDate ?? _startDate;
        break;
      case 'transitEnd':
        initialDate = _transitEndDate ?? _transitStartDate ?? _startDate;
        break;
      case 'locationStart':
        initialDate = _locationStartDate ?? _transitEndDate ?? _startDate;
        break;
      case 'locationEnd':
        initialDate = _locationEndDate ?? _locationStartDate ?? _endDate;
        break;
    }
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate!,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    
    if (picked != null) {
      setState(() {
        switch (type) {
          case 'transitStart':
            _transitStartDate = picked;
            break;
          case 'transitEnd':
            _transitEndDate = picked;
            break;
          case 'locationStart':
            _locationStartDate = picked;
            break;
          case 'locationEnd':
            _locationEndDate = picked;
            break;
        }
      });
    }
  }
  
  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _nameController.text.trim(),
        _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        _startDate,
        _endDate,
        _usePhaseDates ? _transitStartDate : null,
        _usePhaseDates ? _transitEndDate : null,
        _usePhaseDates ? _locationStartDate : null,
        _usePhaseDates ? _locationEndDate : null,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Trip name field
            TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Trip Name',
              hintText: 'Enter trip name',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a trip name';
              }
              if (value.trim().length < 3) {
                return 'Trip name must be at least 3 characters';
              }
              return null;
            },
            textCapitalization: TextCapitalization.words,
          ),
          
          const SizedBox(height: 16),
          
          // Description field
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (Optional)',
              hintText: 'Enter trip description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.description),
            ),
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          
          const SizedBox(height: 24),
          
          // Start date picker
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Start Date'),
              subtitle: Text(dateFormat.format(_startDate)),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectDate(context, true),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // End date picker
          Card(
            child: ListTile(
              leading: const Icon(Icons.event),
              title: const Text('End Date'),
              subtitle: Text(dateFormat.format(_endDate)),
              trailing: const Icon(Icons.edit),
              onTap: () => _selectDate(context, false),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Trip duration info
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timelapse),
                  const SizedBox(width: 8),
                  Text(
                    'Duration: ${_endDate.difference(_startDate).inDays + 1} days',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Phase-based planning toggle
          Card(
            child: SwitchListTile(
              title: const Text('Separate Transit & Vacation Phases'),
              subtitle: const Text('Configure different dates for travel to/from destination'),
              value: _usePhaseDates,
              onChanged: (value) {
                setState(() {
                  _usePhaseDates = value;
                  if (value) {
                    // Initialize with reasonable defaults
                    _transitStartDate ??= _startDate;
                    _transitEndDate ??= _startDate.add(const Duration(days: 2));
                    _locationStartDate ??= _transitEndDate;
                    _locationEndDate ??= _endDate.subtract(const Duration(days: 2));
                  }
                });
              },
            ),
          ),
          
          // Phase date pickers (only shown if enabled)
          if (_usePhaseDates) ...[
            const SizedBox(height: 16),
            Text(
              'Transit Phase (Outbound)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.flight_takeoff),
                title: const Text('Transit Start'),
                subtitle: Text(_transitStartDate != null 
                    ? dateFormat.format(_transitStartDate!) 
                    : 'Not set'),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectPhaseDate(context, 'transitStart'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_on),
                title: const Text('Arrive at Destination'),
                subtitle: Text(_transitEndDate != null 
                    ? dateFormat.format(_transitEndDate!) 
                    : 'Not set'),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectPhaseDate(context, 'transitEnd'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Vacation Phase (On Location)',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.explore),
                title: const Text('Vacation Start'),
                subtitle: Text(_locationStartDate != null 
                    ? dateFormat.format(_locationStartDate!) 
                    : 'Not set'),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectPhaseDate(context, 'locationStart'),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.beach_access),
                title: const Text('Vacation End'),
                subtitle: Text(_locationEndDate != null 
                    ? dateFormat.format(_locationEndDate!) 
                    : 'Not set'),
                trailing: const Icon(Icons.edit),
                onTap: () => _selectPhaseDate(context, 'locationEnd'),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Return Transit Phase',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Card(
              color: Theme.of(context).colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.flight_land),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Return transit: ${_locationEndDate != null ? "${dateFormat.format(_locationEndDate!)} - ${dateFormat.format(_endDate)}" : "Not set"}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 32),
          
          // Submit button
          ElevatedButton.icon(
            onPressed: _submit,
            icon: Icon(widget.trip == null ? Icons.add : Icons.save),
            label: Text(widget.trip == null ? 'Create Trip' : 'Save Changes'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16.0),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
