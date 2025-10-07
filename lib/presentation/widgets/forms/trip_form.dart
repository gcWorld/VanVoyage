import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/trip.dart';
import '../../../domain/enums/trip_status.dart';

/// A form widget for creating and editing trips
class TripForm extends StatefulWidget {
  /// Optional existing trip to edit
  final Trip? trip;
  
  /// Callback when form is submitted
  final Function(String name, String? description, DateTime startDate, DateTime endDate) onSubmit;
  
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
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.trip?.name ?? '');
    _descriptionController = TextEditingController(text: widget.trip?.description ?? '');
    _startDate = widget.trip?.startDate ?? DateTime.now();
    _endDate = widget.trip?.endDate ?? DateTime.now().add(const Duration(days: 7));
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
  
  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(
        _nameController.text.trim(),
        _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        _startDate,
        _endDate,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
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
    );
  }
}
