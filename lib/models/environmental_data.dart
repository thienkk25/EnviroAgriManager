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

  factory EnvironmentalData.fromJson(Map<String, dynamic> json) {
    return EnvironmentalData(
      id: json['id'] as String,
      regionId: json['region_id'] as String,
      location: json['location'] as String?,
      temperature: (json['temperature'] as num?)?.toDouble(),
      humidity: (json['humidity'] as num?)?.toDouble(),
      ph: (json['ph'] as num?)?.toDouble(),
      soilMoisture: (json['soil_moisture'] as num?)?.toDouble(),
      lightIntensity: (json['light_intensity'] as num?)?.toDouble(),
      co2Level: (json['co2_level'] as num?)?.toDouble(),
      nitrogen: (json['nitrogen'] as num?)?.toDouble(),
      phosphorus: (json['phosphorus'] as num?)?.toDouble(),
      potassium: (json['potassium'] as num?)?.toDouble(),
      weatherCondition: json['weather_condition'] as String?,
      notes: json['notes'] as String?,
      recordedAt: DateTime.parse(json['recorded_at']),
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'region_id': regionId,
      'location': location,
      'temperature': temperature,
      'humidity': humidity,
      'ph': ph,
      'soil_moisture': soilMoisture,
      'light_intensity': lightIntensity,
      'co2_level': co2Level,
      'nitrogen': nitrogen,
      'phosphorus': phosphorus,
      'potassium': potassium,
      'weather_condition': weatherCondition,
      'notes': notes,
      'recorded_at': recordedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

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
}
