import 'package:equatable/equatable.dart';

/// Represents a travel constraint rule with validation thresholds
class TravelConstraint extends Equatable {
  /// Minimum safe daily driving distance (km)
  final int minDailyDistance;
  
  /// Maximum safe daily driving distance (km)
  final int maxDailyDistance;
  
  /// Minimum daily driving time (minutes)
  final int minDailyTime;
  
  /// Maximum safe daily driving time (minutes)
  final int maxDailyTime;
  
  /// Minimum driving speed (km/h)
  final int minSpeed;
  
  /// Maximum driving speed (km/h)
  final int maxSpeed;
  
  /// Minimum rest stop interval (minutes)
  final int minRestInterval;
  
  /// Maximum rest stop interval (minutes)
  final int maxRestInterval;
  
  /// Recommended minimum daily distance (km)
  final int recommendedMinDistance;
  
  /// Recommended maximum daily distance (km)
  final int recommendedMaxDistance;
  
  /// Recommended minimum daily time (minutes)
  final int recommendedMinTime;
  
  /// Recommended maximum daily time (minutes)
  final int recommendedMaxTime;
  
  /// Recommended minimum rest interval (minutes)
  final int recommendedMinRestInterval;
  
  /// Recommended maximum rest interval (minutes)
  final int recommendedMaxRestInterval;

  const TravelConstraint({
    this.minDailyDistance = 50,
    this.maxDailyDistance = 1000,
    this.minDailyTime = 30,
    this.maxDailyTime = 720,
    this.minSpeed = 40,
    this.maxSpeed = 130,
    this.minRestInterval = 30,
    this.maxRestInterval = 360,
    this.recommendedMinDistance = 300,
    this.recommendedMaxDistance = 500,
    this.recommendedMinTime = 180,
    this.recommendedMaxTime = 360,
    this.recommendedMinRestInterval = 120,
    this.recommendedMaxRestInterval = 180,
  });

  /// Default travel constraints for safe and comfortable van travel
  factory TravelConstraint.defaults() {
    return const TravelConstraint();
  }

  @override
  List<Object?> get props => [
        minDailyDistance,
        maxDailyDistance,
        minDailyTime,
        maxDailyTime,
        minSpeed,
        maxSpeed,
        minRestInterval,
        maxRestInterval,
        recommendedMinDistance,
        recommendedMaxDistance,
        recommendedMinTime,
        recommendedMaxTime,
        recommendedMinRestInterval,
        recommendedMaxRestInterval,
      ];
}
