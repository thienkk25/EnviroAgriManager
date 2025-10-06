// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class EnvironmentalData {
  final String id;
  final String regionId;
  final String? location;

  final double? temperature;
  final double? humidity;
  final double? ph;
  final double? soilMoisture;
  final double? lightIntensity;
  final double? co2Level;
  final double? nitrogen;
  final double? phosphorus;
  final double? potassium;

  final String? weatherCondition;
  final String? notes;

  final DateTime recordedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  EnvironmentalData({
    required this.id,
    required this.regionId,
    this.location,
    this.temperature,
    this.humidity,
    this.ph,
    this.soilMoisture,
    this.lightIntensity,
    this.co2Level,
    this.nitrogen,
    this.phosphorus,
    this.potassium,
    this.weatherCondition,
    this.notes,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  EnvironmentalData copyWith({
    String? id,
    String? regionId,
    String? location,
    double? temperature,
    double? humidity,
    double? ph,
    double? soilMoisture,
    double? lightIntensity,
    double? co2Level,
    double? nitrogen,
    double? phosphorus,
    double? potassium,
    String? weatherCondition,
    String? notes,
    DateTime? recordedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EnvironmentalData(
      id: id ?? this.id,
      regionId: regionId ?? this.regionId,
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      ph: ph ?? this.ph,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      co2Level: co2Level ?? this.co2Level,
      nitrogen: nitrogen ?? this.nitrogen,
      phosphorus: phosphorus ?? this.phosphorus,
      potassium: potassium ?? this.potassium,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      notes: notes ?? this.notes,
      recordedAt: recordedAt ?? this.recordedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'regionId': regionId,
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'ph': ph,
      'soilMoisture': soilMoisture,
      'lightIntensity': lightIntensity,
      'co2Level': co2Level,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'weatherCondition': weatherCondition,
      'notes': notes,
      'recordedAt': recordedAt.millisecondsSinceEpoch,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory EnvironmentalData.fromMap(Map<String, dynamic> map) {
    return EnvironmentalData(
      id: map['id'] as String,
      regionId: map['regionId'] as String,
      location: map['location'] != null ? map['location'] as String : null,
      temperature: map['temperature'] != null
          ? map['temperature'] as double
          : null,
      humidity: map['humidity'] != null ? map['humidity'] as double : null,
      ph: map['ph'] != null ? map['ph'] as double : null,
      soilMoisture: map['soilMoisture'] != null
          ? map['soilMoisture'] as double
          : null,
      lightIntensity: map['lightIntensity'] != null
          ? map['lightIntensity'] as double
          : null,
      co2Level: map['co2Level'] != null ? map['co2Level'] as double : null,
      nitrogen: map['nitrogen'] != null ? map['nitrogen'] as double : null,
      phosphorus: map['phosphorus'] != null
          ? map['phosphorus'] as double
          : null,
      potassium: map['potassium'] != null ? map['potassium'] as double : null,
      weatherCondition: map['weatherCondition'] != null
          ? map['weatherCondition'] as String
          : null,
      notes: map['notes'] != null ? map['notes'] as String : null,
      recordedAt: DateTime.fromMillisecondsSinceEpoch(map['recordedAt'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt'] as int),
    );
  }

  String toJson() => json.encode(toMap());

  factory EnvironmentalData.fromJson(String source) =>
      EnvironmentalData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'EnvironmentalData(id: $id, regionId: $regionId, location: $location, temperature: $temperature, humidity: $humidity, ph: $ph, soilMoisture: $soilMoisture, lightIntensity: $lightIntensity, co2Level: $co2Level, nitrogen: $nitrogen, phosphorus: $phosphorus, potassium: $potassium, weatherCondition: $weatherCondition, notes: $notes, recordedAt: $recordedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(covariant EnvironmentalData other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.regionId == regionId &&
        other.location == location &&
        other.temperature == temperature &&
        other.humidity == humidity &&
        other.ph == ph &&
        other.soilMoisture == soilMoisture &&
        other.lightIntensity == lightIntensity &&
        other.co2Level == co2Level &&
        other.nitrogen == nitrogen &&
        other.phosphorus == phosphorus &&
        other.potassium == potassium &&
        other.weatherCondition == weatherCondition &&
        other.notes == notes &&
        other.recordedAt == recordedAt &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        regionId.hashCode ^
        location.hashCode ^
        temperature.hashCode ^
        humidity.hashCode ^
        ph.hashCode ^
        soilMoisture.hashCode ^
        lightIntensity.hashCode ^
        co2Level.hashCode ^
        nitrogen.hashCode ^
        phosphorus.hashCode ^
        potassium.hashCode ^
        weatherCondition.hashCode ^
        notes.hashCode ^
        recordedAt.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
