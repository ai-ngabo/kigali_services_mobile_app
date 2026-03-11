import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class FilterProvider extends ChangeNotifier {
  String _searchQuery = '';
  AppCategory? _selectedCategory; 
  final int _maxResults = 50; // Limit results

  String get searchQuery => _searchQuery;
  AppCategory? get selectedCategory => _selectedCategory;
  int get maxResults => _maxResults;
  
  bool get hasActiveFilter =>
      _searchQuery.trim().isNotEmpty || _selectedCategory != null;

  // filter description
  String get filterDescription {
    final parts = <String>[];
    
    if (_selectedCategory != null) {
      final info = kCategoryMeta[_selectedCategory];
      parts.add(info?.label ?? 'Unknown');
    }
    
    if (_searchQuery.trim().isNotEmpty) {
      parts.add('"${_searchQuery.trim()}"');
    }
    
    if (parts.isEmpty) {
      return 'No filters applied';
    }
    
    return 'Showing: ${parts.join(' • ')}';
  }

  void setSearchQuery(String query) {
    // Normalize to remove extra spaces
    _searchQuery = query.replaceAll(RegExp(r'\s+'), ' ').trim();
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

  //method to clear only search but keep category
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
