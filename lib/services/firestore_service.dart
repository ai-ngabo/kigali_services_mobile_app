import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
import '../models/review_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // collection references
  CollectionReference<Map<String, dynamic>> get _listings =>
      _db.collection('listings');

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  // all listings stream for home page
  Stream<List<ListingModel>> listingsStream() {
    return _listings
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromFirestore).toList());
  }

  // listings stream for a specific user
  Stream<List<ListingModel>> userListingsStream(String uid) {
    return _listings
        .where('createdBy', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromFirestore).toList());
  }

  // create listing
  Future<void> createListing(ListingModel listing) async {
    await _listings.doc(listing.id).set(listing.toFirestore());
  }

  // update listing
  Future<void> updateListing(ListingModel listing) async {
    await _listings.doc(listing.id).update(listing.toFirestore());
  }

  // delete listing
  Future<void> deleteListing(String id) async {
    await _listings.doc(id).delete();
  }

  // fetch one listing by id
  Future<ListingModel?> getListing(String id) async {
    final doc = await _listings.doc(id).get();
    if (!doc.exists) return null;
    return ListingModel.fromFirestore(doc);
  }

  // user profile operations
  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<void> updateUser(UserModel user) async {
    await _users.doc(user.uid).update(user.toFirestore());
  }

  // update listing rating after a review is submitted
  Future<void> updateRating(String listingId, double newRating, int newCount) async {
    await _listings.doc(listingId).update({
      'rating': newRating,
      'ratingCount': newCount,
    });
  }

  // reviews collection 

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _db.collection('reviews');

  // reviews stream for a specific listing
  Stream<List<ReviewModel>> reviewsStream(String listingId) {
    return _reviews
        .where('listingId', isEqualTo: listingId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ReviewModel.fromFirestore).toList());
  }

  // fetch a user's review for a specific listing (if exists)
  Future<ReviewModel?> getUserReview(String listingId, String userId) async {
    final snap = await _reviews
        .where('listingId', isEqualTo: listingId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return ReviewModel.fromFirestore(snap.docs.first);
  }

  // updates the listing rating atomically using a transaction
  Future<void> addReview(ReviewModel review) async {
    await _db.runTransaction((tx) async {
      final listingRef = _listings.doc(review.listingId);
      final listingSnap = await tx.get(listingRef);
      if (!listingSnap.exists) throw Exception('Listing not found');

      final data = listingSnap.data()!;
      final currentRating = (data['rating'] as num?)?.toDouble() ?? 0.0;
      final currentCount = (data['ratingCount'] as num?)?.toInt() ?? 0;
      final newCount = currentCount + 1;
      final newRating =
          ((currentRating * currentCount) + review.rating) / newCount;

      tx.set(_reviews.doc(review.id), review.toFirestore());
      tx.update(listingRef, {'rating': newRating, 'ratingCount': newCount});
    });
  }

  // deletes a review and updates the listing rating
  Future<void> deleteReview(String reviewId, String listingId) async {
    await _db.runTransaction((tx) async {
      final reviewRef = _reviews.doc(reviewId);
      final listingRef = _listings.doc(listingId);

      final reviewSnap = await tx.get(reviewRef);
      final listingSnap = await tx.get(listingRef);
      if (!reviewSnap.exists || !listingSnap.exists) return;

      final reviewRating =
          (reviewSnap.data()!['rating'] as num?)?.toDouble() ?? 0.0;
      final listingData = listingSnap.data()!;
      final currentRating = (listingData['rating'] as num?)?.toDouble() ?? 0.0;
      final currentCount = (listingData['ratingCount'] as num?)?.toInt() ?? 0;

      tx.delete(reviewRef);

      if (currentCount <= 1) {
        tx.update(listingRef, {'rating': 0.0, 'ratingCount': 0});
      } else {
        final newCount = currentCount - 1;
        final newRating =
            ((currentRating * currentCount) - reviewRating) / newCount;
        tx.update(listingRef, {'rating': newRating, 'ratingCount': newCount});
      }
    });
  }

  // Get top-rated listings
  Future<List<ListingModel>> getTopRatedListings({int limit = 10}) async {
    final snap = await _listings
        .where('ratingCount', isGreaterThanOrEqualTo: 2)
        .orderBy('rating', descending: true)
        .orderBy('ratingCount', descending: true)
        .limit(limit)
        .get();
    
    return snap.docs.map(ListingModel.fromFirestore).toList();
  }

  // Search by name with matching fallback
  Future<List<ListingModel>> searchByName(String query) async {
    if (query.trim().isEmpty) return [];
    
    final snap = await _listings.limit(100).get();
    final allListings = snap.docs.map(ListingModel.fromFirestore).toList();
    
    // Filter locally for better search UX
    final q = query.toLowerCase();
    return allListings
        .where((l) => l.name.toLowerCase().contains(q))
        .toList();
  }

  // Get listings created this month
  Stream<List<ListingModel>> getRecentListings({int daysBack = 30}) {
    final pastDate = DateTime.now().subtract(Duration(days: daysBack));
    return _listings
        .where('timestamp', isGreaterThan: Timestamp.fromDate(pastDate))
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ListingModel.fromFirestore).toList());
  }
}
