import 'package:cloud_firestore/cloud_firestore.dart';

// Data structure for user info

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
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      listingCount: data['listingCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'displayName': displayName,
      'email': email,
      if (photoUrl != null) 'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'listingCount': listingCount,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? email,
    String? photoUrl,
    int? listingCount,
  }) {
    return UserModel(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt,
      listingCount: listingCount ?? this.listingCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is UserModel && other.uid == uid;

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() => 'UserModel(uid: $uid, displayName: $displayName)';
}