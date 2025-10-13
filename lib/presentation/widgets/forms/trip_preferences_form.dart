import 'package:flutter/material.dart';
import '../../../domain/entities/trip_preferences.dart';
import '../../../domain/entities/constraint_violation.dart';
import '../../../domain/entities/travel_constraint.dart';
import '../../../domain/services/travel_constraint_validator.dart';

/// A form widget for configuring trip planning preferences and travel constraints
class TripPreferencesForm extends StatefulWidget {
  /// Optional existing preferences to edit
  final TripPreferences? preferences;
  
  /// Callback when preferences are saved
  final Function(
    int maxDailyDrivingDistance,
    int maxDailyDrivingTime,
    int preferredDrivingSpeed,
    bool includeRestStops,
    int? restStopInterval,
    bool avoidTolls,
    bool avoidHighways,
    bool preferScenicRoutes,
  ) onSave;
  
  const TripPreferencesForm({
    super.key,
    this.preferences,
    required this.onSave,
  });

  @override
  State<TripPreferencesForm> createState() => _TripPreferencesFormState();
}

class _TripPreferencesFormState extends State<TripPreferencesForm> {
  late double _maxDailyDistance;
  late double _maxDailyTime;
  late double _preferredSpeed;
  late bool _includeRestStops;
  late double _restStopInterval;
  late bool _avoidTolls;
  late bool _avoidHighways;
  late bool _preferScenicRoutes;
  
  final _validator = const TravelConstraintValidator();
  List<ConstraintViolation> _violations = [];
  
  @override
  void initState() {
    super.initState();
    _maxDailyDistance = (widget.preferences?.maxDailyDrivingDistance ?? 300).toDouble();
    _maxDailyTime = (widget.preferences?.maxDailyDrivingTime ?? 240).toDouble();
    _preferredSpeed = (widget.preferences?.preferredDrivingSpeed ?? 80).toDouble();
    _includeRestStops = widget.preferences?.includeRestStops ?? true;
    _restStopInterval = (widget.preferences?.restStopInterval ?? 120).toDouble();
    _avoidTolls = widget.preferences?.avoidTolls ?? false;
    _avoidHighways = widget.preferences?.avoidHighways ?? false;
    _preferScenicRoutes = widget.preferences?.preferScenicRoutes ?? false;
    
    // Perform initial validation without setState since we're in initState
    _violations = _validatePreferencesSync();
  }
  
  List<ConstraintViolation> _validatePreferencesSync() {
    final prefs = TripPreferences(
      id: 'temp',
      tripId: 'temp',
      maxDailyDrivingDistance: _maxDailyDistance.toInt(),
      maxDailyDrivingTime: _maxDailyTime.toInt(),
      preferredDrivingSpeed: _preferredSpeed.toInt(),
      includeRestStops: _includeRestStops,
      restStopInterval: _includeRestStops ? _restStopInterval.toInt() : null,
      avoidTolls: _avoidTolls,
      avoidHighways: _avoidHighways,
      preferScenicRoutes: _preferScenicRoutes,
    );
    
    return _validator.validate(prefs);
  }
  
  void _validatePreferences() {
    setState(() {
      _violations = _validatePreferencesSync();
    });
  }
  
  void _save() {
    widget.onSave(
      _maxDailyDistance.toInt(),
      _maxDailyTime.toInt(),
      _preferredSpeed.toInt(),
      _includeRestStops,
      _includeRestStops ? _restStopInterval.toInt() : null,
      _avoidTolls,
      _avoidHighways,
      _preferScenicRoutes,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Driving Preferences Section
          Text(
          'Driving Preferences',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        // Max daily driving distance
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Max Daily Distance'),
                    Text(
                      '${_maxDailyDistance.toInt()} km',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Slider(
                  value: _maxDailyDistance,
                  min: 100,
                  max: 800,
                  divisions: 70,
                  label: '${_maxDailyDistance.toInt()} km',
                  onChanged: (value) {
                    setState(() {
                      _maxDailyDistance = value;
                    });
                    _validatePreferences();
                  },
                ),
                Text(
                  'Recommended: 300-500 km per day',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Max daily driving time
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Max Daily Driving Time'),
                    Text(
                      '${(_maxDailyTime / 60).toStringAsFixed(1)} hrs',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Slider(
                  value: _maxDailyTime,
                  min: 60,
                  max: 600,
                  divisions: 54,
                  label: '${(_maxDailyTime / 60).toStringAsFixed(1)} hrs',
                  onChanged: (value) {
                    setState(() {
                      _maxDailyTime = value;
                    });
                    _validatePreferences();
                  },
                ),
                Text(
                  'Recommended: 3-6 hours per day',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Preferred driving speed
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Preferred Driving Speed'),
                    Text(
                      '${_preferredSpeed.toInt()} km/h',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                Slider(
                  value: _preferredSpeed,
                  min: 50,
                  max: 120,
                  divisions: 70,
                  label: '${_preferredSpeed.toInt()} km/h',
                  onChanged: (value) {
                    setState(() {
                      _preferredSpeed = value;
                    });
                    _validatePreferences();
                  },
                ),
                Text(
                  'Used for travel time calculations',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Route Preferences Section
        Text(
          'Route Preferences',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Avoid Tolls'),
                subtitle: const Text('Prefer routes without toll roads'),
                value: _avoidTolls,
                onChanged: (value) {
                  setState(() {
                    _avoidTolls = value;
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Avoid Highways'),
                subtitle: const Text('Take smaller roads when possible'),
                value: _avoidHighways,
                onChanged: (value) {
                  setState(() {
                    _avoidHighways = value;
                  });
                },
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: const Text('Prefer Scenic Routes'),
                subtitle: const Text('Prioritize beautiful landscapes'),
                value: _preferScenicRoutes,
                onChanged: (value) {
                  setState(() {
                    _preferScenicRoutes = value;
                  });
                },
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Rest Stop Settings Section
        Text(
          'Rest Stop Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        
        Card(
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Include Rest Stops'),
                subtitle: const Text('Factor in breaks during long drives'),
                value: _includeRestStops,
                onChanged: (value) {
                  setState(() {
                    _includeRestStops = value;
                  });
                  _validatePreferences();
                },
              ),
              if (_includeRestStops) ...[
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Rest Stop Interval'),
                          Text(
                            '${(_restStopInterval / 60).toStringAsFixed(1)} hrs',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      Slider(
                        value: _restStopInterval,
                        min: 60,
                        max: 300,
                        divisions: 24,
                        label: '${(_restStopInterval / 60).toStringAsFixed(1)} hrs',
                        onChanged: (value) {
                          setState(() {
                            _restStopInterval = value;
                          });
                          _validatePreferences();
                        },
                      ),
                      Text(
                        'Recommended: 2-3 hours between breaks',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Constraint Violations Section
        if (_violations.isNotEmpty) ...[
          Text(
            'Travel Constraint Warnings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ..._violations.map((violation) => _buildViolationCard(context, violation)),
          const SizedBox(height: 24),
        ],
        
        // Save button
        ElevatedButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save),
          label: const Text('Save Preferences'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16.0),
          ),
        ),
        ],
      ),
    );
  }
  
  Widget _buildViolationCard(BuildContext context, ConstraintViolation violation) {
    Color backgroundColor;
    Color iconColor;
    IconData icon;
    
    switch (violation.severity) {
      case ViolationSeverity.error:
        backgroundColor = Theme.of(context).colorScheme.errorContainer;
        iconColor = Theme.of(context).colorScheme.error;
        icon = Icons.error_outline;
        break;
      case ViolationSeverity.warning:
        backgroundColor = Colors.orange.shade50;
        iconColor = Colors.orange.shade700;
        icon = Icons.warning_amber_outlined;
        break;
      case ViolationSeverity.info:
        backgroundColor = Theme.of(context).colorScheme.primaryContainer;
        iconColor = Theme.of(context).colorScheme.primary;
        icon = Icons.info_outline;
        break;
    }
    
    return Card(
      color: backgroundColor,
      margin: const EdgeInsets.only(bottom: 12.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    violation.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (violation.expectedValue != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Expected: ${violation.expectedValue}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: iconColor.withOpacity(0.8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
