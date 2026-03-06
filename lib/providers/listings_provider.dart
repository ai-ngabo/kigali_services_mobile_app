import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/listing_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class ListingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final _uuid = const Uuid();

  List<ListingModel> _listings = [];
  List<ListingModel> _myListings = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription<List<ListingModel>>? _listingsSub;
  StreamSubscription<List<ListingModel>>? _myListingsSub;

  // getters
  List<ListingModel> get listings => _listings;
  List<ListingModel> get myListings => _myListings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // filter listings by search 
  List<ListingModel> filteredListings({
    required String query,
    AppCategory? category,
  }) {
    var result = _listings;

    if (category != null) {
      result = result
          .where((l) => l.category == category.name)
          .toList();
    }

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((l) {
        return l.name.toLowerCase().contains(q) ||
            l.address.toLowerCase().contains(q) ||
            l.description.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  // listern to all listings
  void startListening() {
    _listingsSub?.cancel();
    _listingsSub = _firestoreService.listingsStream().listen(
      (data) {
        _listings = data;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = 'Failed to load listings.';
        notifyListeners();
      },
    );
  }

  // listern to current user's listings
  void startListeningMyListings(String uid) {
    _myListingsSub?.cancel();
    _myListingsSub = _firestoreService.userListingsStream(uid).listen(
      (data) {
        _myListings = data;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _listingsSub?.cancel();
    _myListingsSub?.cancel();
    _listingsSub = null;
    _myListingsSub = null;
  }

  // create new listing
  Future<bool> createListing({
    required String name,
    required String category,
    required String address,
    required String contact,
    required String description,
    required double latitude,
    required double longitude,
    required String createdBy,
    required String createdByName,
    String? imageUrl,
  }) async {
    _setLoading(true);
    try {
      final listing = ListingModel(
        id: _uuid.v4(),
        name: name,
        category: category,
        address: address,
        contact: contact,
        description: description,
        latitude: latitude,
        longitude: longitude,
        createdBy: createdBy,
        createdByName: createdByName,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
      );
      await _firestoreService.createListing(listing);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to create listing. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // update existing listing
  Future<bool> updateListing(ListingModel listing) async {
    _setLoading(true);
    try {
      await _firestoreService.updateListing(listing);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update listing. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // delete listing
  Future<bool> deleteListing(String id) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteListing(id);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete listing. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}