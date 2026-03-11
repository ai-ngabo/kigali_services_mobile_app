import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class ListingModel {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contact;
  final String description;
  final double latitude;
  final double longitude;
  final String createdBy; 
  final String createdByName;
  final DateTime timestamp;
  final double rating;
  final int ratingCount;
  final String? imageUrl;

  const ListingModel({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contact,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.createdBy,
    required this.createdByName,
    required this.timestamp,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.imageUrl,
  });

  AppCategory get categoryEnum => categoryFromString(category);
  AppCategoryInfo get categoryInfo =>
      kCategoryMeta[categoryEnum] ?? kCategoryMeta[AppCategory.other]!;
  bool get hasRatings => ratingCount > 0;
  double get avgRating => hasRatings ? rating : 0.0;

  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    
    return ListingModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      category: data['category'] as String? ?? AppCategory.other.name,
      address: data['address'] as String? ?? '',
      contact: data['contact'] as String? ?? '',
      description: data['description'] as String? ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? -1.9441,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 30.0619,
      createdBy: data['createdBy'] as String? ?? '',
      createdByName: data['createdByName'] as String? ?? 'Unknown',
      timestamp: timestamp,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['ratingCount'] as int? ?? 0,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => <String, dynamic>{
    'name': name,
    'category': category,
    'address': address,
    'contact': contact,
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'createdBy': createdBy,
    'createdByName': createdByName,
    'timestamp': Timestamp.fromDate(timestamp),
    'rating': rating,
    'ratingCount': ratingCount,
    if (imageUrl != null) 'imageUrl': imageUrl,
  };

  // Check if listing has valid location data for maps
  bool get isValidLocation => 
      latitude != 0.0 && longitude != 0.0 && 
      latitude.abs() < 90 && longitude.abs() < 180;

  String get shortInfo => '$name • $address';

  // Update specific fields without recreating everything
  ListingModel updateFields({
    String? name,
    String? category,
    String? address,
    String? contact,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) => ListingModel(
    id: id,
    name: name ?? this.name,
    category: category ?? this.category,
    address: address ?? this.address,
    contact: contact ?? this.contact,
    description: description ?? this.description,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    createdBy: createdBy,
    createdByName: createdByName,
    timestamp: timestamp,
    rating: rating,
    ratingCount: ratingCount,
    imageUrl: imageUrl ?? this.imageUrl,
  );

  // Alias for updateFields (used in edit mode)
  ListingModel copyWith({
    String? name,
    String? category,
    String? address,
    String? contact,
    String? description,
    double? latitude,
    double? longitude,
    String? imageUrl,
  }) => updateFields(
    name: name,
    category: category,
    address: address,
    contact: contact,
    description: description,
    latitude: latitude,
    longitude: longitude,
    imageUrl: imageUrl,
  );
}

