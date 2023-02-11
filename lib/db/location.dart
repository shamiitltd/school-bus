const String dbLocation = 'locations.db';
const String tableLocation = 'locationsInfo';
const int dbVersion = 1;

class LocationFields {
  static final List<String> values = [
    /// Add all fields
    id, latitude, longitude, distanceSoFar, isProcessed, addedDate, processedDate
  ];

  static const String id = '_id';
  static const String latitude = 'latitude';
  static const String longitude = 'longitude';
  static const String distanceSoFar = 'distanceSoFar';
  static const String isProcessed = 'isProcessed';
  static const String addedDate = 'addedDate';
  static const String processedDate = 'processedDate';
}

class Locations {
  final int? id;
  final double latitude;
  final double longitude;
  final double distanceSoFar;
  final bool isProcessed;
  final DateTime addedDate;
  final DateTime? processedDate;

  const Locations({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.distanceSoFar,
    required this.isProcessed,
    required this.addedDate,
    this.processedDate,
  });

  Locations copy({
    int? id,
    double? latitude,
    double? longitude,
    double? distanceSoFar,
    bool? isProcessed,
    DateTime? addedDate,
    DateTime? processedDate,
  }) =>
      Locations(
        id: id ?? this.id,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        distanceSoFar: distanceSoFar ?? this.distanceSoFar,
        isProcessed: isProcessed ?? this.isProcessed,
        addedDate: addedDate ?? this.addedDate,
        processedDate: processedDate ?? this.processedDate,
      );

  static Locations fromJson(Map<String, Object?> json) => Locations(
    id: json[LocationFields.id] as int?,
    latitude: json[LocationFields.latitude] as double,
    longitude: json[LocationFields.longitude] as double,
    distanceSoFar: json[LocationFields.distanceSoFar] as double,
    isProcessed: json[LocationFields.isProcessed] == 1,
    addedDate: DateTime.parse(json[LocationFields.addedDate] as String),
    processedDate: DateTime.now(),
    // processedDate: DateTime.parse((json[LocationFields.processedDate] as String?) !=null ?(json[LocationFields.processedDate] as String) : DateTime.now() as String),
  );

  Map<String, Object?> toJson() => {
    LocationFields.id: id,
    LocationFields.latitude: latitude,
    LocationFields.longitude: longitude,
    LocationFields.distanceSoFar: distanceSoFar,
    LocationFields.isProcessed: isProcessed ? 1 : 0,
    LocationFields.addedDate: addedDate.toIso8601String(),
    LocationFields.processedDate: processedDate?.toIso8601String(),
  };
}