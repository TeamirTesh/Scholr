class RoomModel {
  final String id;
  final String name;
  final String location;
  final int capacity;
  final List<String> availableSlots;
  final Map<String, String> bookedBy;
  final List<String> amenities;

  const RoomModel({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.availableSlots,
    required this.bookedBy,
    required this.amenities,
  });

  factory RoomModel.fromMap(String id, Map<String, dynamic> map) {
    return RoomModel(
      id: id,
      name: map['name'] as String,
      location: map['location'] as String,
      capacity: (map['capacity'] as num).toInt(),
      availableSlots: List<String>.from(map['availableSlots'] ?? const []),
      bookedBy: Map<String, String>.from(map['bookedBy'] ?? const {}),
      amenities: List<String>.from(map['amenities'] ?? const []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
      'capacity': capacity,
      'availableSlots': availableSlots,
      'bookedBy': bookedBy,
      'amenities': amenities,
    };
  }
}
