import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String listingId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  const ReviewModel({
    required this.id,
    required this.listingId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      listingId: data['listingId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      timestamp:
          (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'listingId': listingId,
        'userId': userId,
        'userName': userName,
        'rating': rating,
        'comment': comment,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  ReviewModel copyWith({
    String? id,
    String? listingId,
    String? userId,
    String? userName,
    double? rating,
    String? comment,
    DateTime? timestamp,
  }) =>
      ReviewModel(
        id: id ?? this.id,
        listingId: listingId ?? this.listingId,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        timestamp: timestamp ?? this.timestamp,
      );
}
