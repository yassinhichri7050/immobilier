import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyModel {
  final String id;
  final String title;
  final String description;
  final double price;
  final String type; // "Maison", "Appartement", "Terrain"
  final double surface;
  final String location;
  final double latitude;
  final double longitude;
  final List<String> images;
  final String userId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int rooms;
  final bool isFeatured;

  PropertyModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.type,
    required this.surface,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.images,
    required this.userId,
    required this.createdAt,
    this.updatedAt,
    required this.rooms,
    this.isFeatured = false,
  });

  factory PropertyModel.fromMap(Map<String, dynamic> map, String id) {
    return PropertyModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      type: map['type'] ?? 'Appartement',
      surface: (map['surface'] ?? 0).toDouble(),
      location: map['location'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      rooms: map['rooms'] ?? 0,
      isFeatured: map['isFeatured'] ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'description': description,
        'price': price,
        'type': type,
        'surface': surface,
        'location': location,
        'latitude': latitude,
        'longitude': longitude,
        'images': images,
        'userId': userId,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'rooms': rooms,
        'isFeatured': isFeatured,
      };
}
