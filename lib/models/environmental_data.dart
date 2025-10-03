class EnvironmentalData {
  final String id;
  final String productId;
  final double temperature; // Nhiệt độ
  final double humidity; // Độ ẩm
  final double ph; // Độ pH
  final double soilMoisture; // Độ ẩm đất
  final double lightIntensity; // Cường độ ánh sáng
  final double co2Level; // Nồng độ CO2
  final double nitrogen; // Nồng độ Nitơ
  final double phosphorus; // Nồng độ Phốt pho
  final double potassium; // Nồng độ Kali
  final String weatherCondition; // Điều kiện thời tiết
  final String location; // Vị trí
  final DateTime recordedAt;
  final String notes;

  EnvironmentalData({
    required this.id,
    required this.productId,
    required this.temperature,
    required this.humidity,
    required this.ph,
    required this.soilMoisture,
    required this.lightIntensity,
    required this.co2Level,
    required this.nitrogen,
    required this.phosphorus,
    required this.potassium,
    required this.weatherCondition,
    required this.location,
    required this.recordedAt,
    this.notes = '',
  });

  /// Parse từ JSON Supabase (snake_case)
  factory EnvironmentalData.fromJson(Map<String, dynamic> json) {
    return EnvironmentalData(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      temperature: (json['temperature'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? 0).toDouble(),
      ph: (json['ph'] ?? 0).toDouble(),
      soilMoisture: (json['soil_moisture'] ?? 0).toDouble(),
      lightIntensity: (json['light_intensity'] ?? 0).toDouble(),
      co2Level: (json['co2_level'] ?? 0).toDouble(),
      nitrogen: (json['nitrogen'] ?? 0).toDouble(),
      phosphorus: (json['phosphorus'] ?? 0).toDouble(),
      potassium: (json['potassium'] ?? 0).toDouble(),
      weatherCondition: json['weather_condition'] ?? '',
      location: json['location'] ?? '',
      recordedAt:
          DateTime.tryParse(json['recorded_at'] ?? '') ?? DateTime.now(),
      notes: json['notes'] ?? '',
    );
  }

  /// Convert về JSON để insert/update Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
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
      'location': location,
      'recorded_at': recordedAt.toIso8601String(),
      'notes': notes,
    };
  }

  EnvironmentalData copyWith({
    String? id,
    String? productId,
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
    String? location,
    DateTime? recordedAt,
    String? notes,
  }) {
    return EnvironmentalData(
      id: id ?? this.id,
      productId: productId ?? this.productId,
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
      location: location ?? this.location,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
    );
  }
}
