import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/listing_model.dart';
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
}
