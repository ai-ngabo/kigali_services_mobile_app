import 'package:flutter/material.dart';

// initiating global colors
class AppColors {
  AppColors._();

  // Rwanda flag color initiation - 1st blue
  static const Color primary = Color(0xFF0D47A1);
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primaryDark = Color(0xFF0A2E6E);

  // 2ndgreen
  static const Color secondary = Color(0xFF2E7D32);
  static const Color secondaryLight = Color(0xFF43A047);

  // 3rd Rwanda flag gold/yellow
  static const Color accent = Color(0xFFFFC107);
  static const Color accentDark = Color(0xFFF9A825);

  // Background colors
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color cardBg = Color(0xFFFFFFFF);

  // Text colors
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF5A6474);
  static const Color textHint = Color(0xFFADB5BD);

  // colors for Status mark
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF0288D1);

  // color for Divider / border
  static const Color divider = Color(0xFFE0E6F0);
  static const Color border = Color(0xFFCDD5E0);

  // color for Category per category
  static const Color catHospital = Color(0xFFE53935);
  static const Color catPolice = Color(0xFF1565C0);
  static const Color catRIB = Color(0xFF283593);
  static const Color catLibrary = Color(0xFF6A1B9A);
  static const Color catSupermarket = Color(0xFF00838F);
  static const Color catRestaurant = Color(0xFFE65100);
  static const Color catCafe = Color(0xFF795548);
  static const Color catPark = Color(0xFF2E7D32);
  static const Color catTourist = Color(0xFFF9A825);
  static const Color catTransport = Color(0xFF0277BD);
  static const Color catUtility = Color(0xFF558B2F);
  static const Color catGovernment = Color(0xFF37474F);
  static const Color catBank = Color(0xFF1B5E20);
  static const Color catEducation = Color(0xFF4527A0);
  static const Color catOther = Color(0xFF546E7A);
}

// initiating global spacing and sizing
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const double cardRadius = 16.0;
  static const double buttonRadius = 12.0;
  static const double chipRadius = 20.0;
  static const double inputRadius = 12.0;
}

// initiating global Texts
class AppStrings {
  AppStrings._();

  static const String appName = 'Kigali Services';
  static const String tagline = 'Find services & places in Kigali';

  // Navigation labeling
  static const String navDirectory = 'Directory';
  static const String navMyListings = 'My Listings';
  static const String navMap = 'Map';
  static const String navSettings = 'Settings';

  // Authentication specification
  static const String login = 'Log In';
  static const String signup = 'Sign Up';
  static const String logout = 'Log Out';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String verifyEmail = 'Verify Your Email';
  static const String verifyEmailMsg =
      'A verification link has been sent to your email. Please check your inbox and verify before continuing.';

  // Directory defaulting
  static const String searchHint = 'Search places & services...';
  static const String allCategories = 'All';
  static const String noListings = 'No listings found';
  static const String addListing = 'Add Listing';
  static const String editListing = 'Edit Listing';
  static const String deleteListing = 'Delete Listing';

  // Detail specification
  static const String getDirections = 'Get Directions';
  static const String callNow = 'Call Now';
  static const String reviews = 'Reviews';
  static const String writeReview = 'Write a Review';

  // Settings specification
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String notifications = 'Location Notifications';
  static const String notificationsSubtitle =
      'Get alerts for nearby services';
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String about = 'About';

  // Map specification
  static const String mapView = 'Map View';
  static const String myLocation = 'My Location';

  // Errors handlers
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Check your internet connection.';
}

// Services categories initiation (relevant to Rwanda's context)
enum AppCategory {
  hospital,
  police,
  rib,
  library,
  supermarket,
  restaurant,
  cafe, 
  park,
  tourist,
  transport,
  utility,
  government,
  bank,
  education,
  other,
}

class AppCategoryInfo {
  final String label;
  final String icon; 
  final IconData iconData;
  final Color color;

  const AppCategoryInfo({
    required this.label,
    required this.icon,
    required this.iconData,
    required this.color,
  });
}

const Map<AppCategory, AppCategoryInfo> kCategoryMeta = {
  AppCategory.hospital: AppCategoryInfo(
    label: 'Hospital & Health',
    icon: '🏥',
    iconData: Icons.local_hospital,
    color: AppColors.catHospital,
  ),
  AppCategory.police: AppCategoryInfo(
    label: 'Police Station',
    icon: '🚔',
    iconData: Icons.local_police,
    color: AppColors.catPolice,
  ),
  AppCategory.rib: AppCategoryInfo(
    label: 'RIB Station',
    icon: '🔎',
    iconData: Icons.security,
    color: AppColors.catRIB,
  ),
  AppCategory.library: AppCategoryInfo(
    label: 'Public Library',
    icon: '📚',
    iconData: Icons.local_library,
    color: AppColors.catLibrary,
  ),
  AppCategory.supermarket: AppCategoryInfo(
    label: 'Supermarket',
    icon: '🛒',
    iconData: Icons.shopping_cart,
    color: AppColors.catSupermarket,
  ),
  AppCategory.restaurant: AppCategoryInfo(
    label: 'Restaurant',
    icon: '🍽️',
    iconData: Icons.restaurant,
    color: AppColors.catRestaurant,
  ),
  AppCategory.cafe: AppCategoryInfo(
    label: 'Café',
    icon: '☕',
    iconData: Icons.local_cafe,
    color: AppColors.catCafe,
  ),
  AppCategory.park: AppCategoryInfo(
    label: 'Park & Recreation',
    icon: '🌳',
    iconData: Icons.park,
    color: AppColors.catPark,
  ),
  AppCategory.tourist: AppCategoryInfo(
    label: 'Tourist Attraction',
    icon: '🗺️',
    iconData: Icons.tour,
    color: AppColors.catTourist,
  ),
  AppCategory.transport: AppCategoryInfo(
    label: 'Transportation',
    icon: '🚌',
    iconData: Icons.directions_bus,
    color: AppColors.catTransport,
  ),
  AppCategory.utility: AppCategoryInfo(
    label: 'Utility Office',
    icon: '⚡',
    iconData: Icons.electric_bolt,
    color: AppColors.catUtility,
  ),
  AppCategory.government: AppCategoryInfo(
    label: 'Government Office',
    icon: '🏛️',
    iconData: Icons.account_balance,
    color: AppColors.catGovernment,
  ),
  AppCategory.bank: AppCategoryInfo(
    label: 'Bank & Finance',
    icon: '🏦',
    iconData: Icons.account_balance_wallet,
    color: AppColors.catBank,
  ),
  AppCategory.education: AppCategoryInfo(
    label: 'Education',
    icon: '🎓',
    iconData: Icons.school,
    color: AppColors.catEducation,
  ),
  AppCategory.other: AppCategoryInfo(
    label: 'Other',
    icon: '📍',
    iconData: Icons.place,
    color: AppColors.catOther,
  ),
};

// Helper function to convert string to AppCategory enum
AppCategory categoryFromString(String value) {
  return AppCategory.values.firstWhere(
    (e) => e.name == value,
    orElse: () => AppCategory.other,
  );
}
