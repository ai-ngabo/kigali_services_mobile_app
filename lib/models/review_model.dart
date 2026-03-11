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
    final ts = data['timestamp'] as Timestamp?;
    
    return ReviewModel(
      id: doc.id,
      listingId: data['listingId'] as String? ?? '',
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      comment: data['comment'] as String? ?? '',
      timestamp: ts?.toDate() ?? DateTime.now(),
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

  // Quick check if review is still recent (within 30 days)
  bool get isRecent => 
      DateTime.now().difference(timestamp).inDays < 30;

  String get ratingText => 
      rating == 5.0 ? 'Excellent' :
      rating >= 4.0 ? 'Very Good' :
      rating >= 3.0 ? 'Good' :
      rating >= 2.0 ? 'Fair' :
      'Poor';
}

