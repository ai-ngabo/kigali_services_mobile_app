import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final int listingCount;

  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    this.listingCount = 0,
  });

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.isEmpty) return '?';
    return parts.length == 1 
        ? parts[0][0].toUpperCase()
        : '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }

  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      listingCount: data['listingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'displayName': displayName,
    'email': email,
    'createdAt': Timestamp.fromDate(createdAt),
    'listingCount': listingCount,
    if (hasProfilePhoto) 'photoUrl': photoUrl,
  };

  // Builder for profile updates (only needed fields)
  UserModel updateProfile({
    String? displayName,
    String? photoUrl,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      listingCount: listingCount,
    );
  }
}