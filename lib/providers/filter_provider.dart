import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class FilterProvider extends ChangeNotifier {
  String _searchQuery = '';
  AppCategory? _selectedCategory; // no category selected by default

  String get searchQuery => _searchQuery;
  AppCategory? get selectedCategory => _selectedCategory;
  bool get hasActiveFilter =>
      _searchQuery.isNotEmpty || _selectedCategory != null;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCategory(AppCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    notifyListeners();
  }
}