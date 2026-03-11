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

    // Apply category filter first
    if (category != null) {
      result = result
          .where((l) => l.category == category.name)
          .toList();
    }

    // Then search text - if query is short
    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase();
      result = result.where((l) {
        // Prioritize name matches over address/description
        return l.name.toLowerCase().contains(q) ||
            l.address.toLowerCase().contains(q) ||
            l.description.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }

  // Get top-rated listings for home page showcase
  List<ListingModel> get topRatedListings {
    if (_listings.isEmpty) return [];
    final sorted = List<ListingModel>.from(_listings);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }

  // listen to all listings
  void startListening() {
    _setLoading(true);
    _listingsSub?.cancel();
    
    _listingsSub = _firestoreService.listingsStream().listen(
      (data) {
        debugPrint('Fetched ${data.length} total listings');
        _listings = data;
        _errorMessage = null;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        // Only show error if it's not a network timeout
        final errorMsg = e.toString();
        if (!errorMsg.contains('timeout')) {
          _errorMessage = 'Could not load listings. Please check your connection.';
          debugPrint('Listings stream error: $e');
        }
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // listen to current user's listings
  void startListeningMyListings(String uid) {
    _myListingsSub?.cancel();
    _myListingsSub = _firestoreService.userListingsStream(uid).listen(
      (data) {
        debugPrint('Fetched ${data.length} listings for user $uid');
        _myListings = data;
        notifyListeners();
      },
      onError: (e) {
        debugPrint('Error fetching my listings: $e');
      }
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
      // Validate required fields before creating
      if (name.trim().isEmpty || address.trim().isEmpty) {
        _errorMessage = 'Name and address are required';
        return false;
      }

      final listing = ListingModel(
        id: _uuid.v4(),
        name: name.trim(),
        category: category,
        address: address.trim(),
        contact: contact.trim(),
        description: description.trim(),
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
    } on Exception catch (e) {
      debugPrint('Error creating listing: $e');
      _errorMessage = 'Could not save listing. Try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // rest of the methods (update, delete, etc.) remain same

  Future<bool> updateListing(ListingModel listing) async {
    _setLoading(true);
    try {
      await _firestoreService.updateListing(listing);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update listing.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteListing(String id) async {
    _setLoading(true);
    try {
      await _firestoreService.deleteListing(id);
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete listing.';
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
