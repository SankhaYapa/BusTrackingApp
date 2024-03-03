class BusLocation {
  final double latitude;
  final double longitude;
  final String name;
  final int timestamp;

  BusLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.timestamp,
  });

  factory BusLocation.fromMap(Map<String, dynamic> map) {
    return BusLocation(
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      name: map['name'] ?? '',
      timestamp: map['timestamp'] ?? 0,
    );
  }
}
