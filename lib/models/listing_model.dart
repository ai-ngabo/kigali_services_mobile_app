import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

// Data structure with a collection 'Listing'

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

  // helper functions
  AppCategory get categoryEnum => categoryFromString(category);

  AppCategoryInfo get categoryInfo =>
      kCategoryMeta[categoryEnum] ?? kCategoryMeta[AppCategory.other]!;

  bool get hasRatings => ratingCount > 0;

  // data serialization
  factory ListingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
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
      timestamp: data['timestamp'] != null
          ? (data['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      ratingCount: data['ratingCount'] as int? ?? 0,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
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
  }

  // function to create a copy of the listing with updated fields
  ListingModel copyWith({
    String? id,
    String? name,
    String? category,
    String? address,
    String? contact,
    String? description,
    double? latitude,
    double? longitude,
    String? createdBy,
    String? createdByName,
    DateTime? timestamp,
    double? rating,
    int? ratingCount,
    String? imageUrl,
  }) {
    return ListingModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      timestamp: timestamp ?? this.timestamp,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ListingModel && other.id == id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ListingModel(id: $id, name: $name, category: $category)';
}
