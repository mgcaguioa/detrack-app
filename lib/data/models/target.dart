class Target {
  final String id;
  final double targetLat;
  final double targetLng;

  const Target({
    required this.id,
    required this.targetLat,
    required this.targetLng,
  });

  factory Target.fromJson(Map<String, dynamic> json) {
    return Target(
      id: json['id'] as String,
      targetLat: (json['targetLat'] as num).toDouble(),
      targetLng: (json['targetLng'] as num).toDouble(),
    );
  }
}
