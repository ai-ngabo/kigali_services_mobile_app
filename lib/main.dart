import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/listings_provider.dart';
import 'providers/filter_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/directory/directory_screen.dart';
import 'screens/directory/create_edit_listing_screen.dart';
import 'screens/my_listings/my_listings_screen.dart';
import 'screens/map/map_view_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const KigaliServicesApp());
}

class KigaliServicesApp extends StatelessWidget {
  const KigaliServicesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => ListingsProvider()),
        ChangeNotifierProvider(create: (_) => FilterProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

// Authentication handler - Route to appropriate screen based on auth state
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    // Show loading while Firebase initializes auth state
    if (!auth.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Not logged in - show login screen
    if (auth.firebaseUser == null) {
      return const LoginScreen();
    }

    // Logged in but email not verified - require verification first
    if (!auth.isEmailVerified) {
      return const VerifyEmailScreen();
    }

    // All checks passed - show main app
    return const MainShell();
  }
}

// Main app shell with bottom navigation
// Loads all provider listeners here and coordinates navigation
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Lazy-load screens to avoid excessive memory usage
  static const List<Widget> _screens = [
    DirectoryScreen(),    // Browse all listings
    MyListingsScreen(),   // User's own listings
    MapViewScreen(),      // Map view
    SettingsScreen(),     // User settings
  ];

  void _onFabPressed() {
    // Only allow creating listings from Directory or My Listings tabs
    if (_currentIndex == 0 || _currentIndex == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CreateEditListingScreen()),
      );
    }
    // Map and Settings tabs handle their own actions
  }

  @override
  void initState() {
    super.initState();
    // Start listening to listings when app goes foreground
    final listings = context.read<ListingsProvider>();
    listings.startListening();

    final uid = context.read<AppAuthProvider>().firebaseUser?.uid;
    if (uid != null) {
      listings.startListeningMyListings(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    
    // Determine if we should show
    Widget? fab;
    if (auth.isLoggedIn) {
      if (_currentIndex == 0 || _currentIndex == 1) {
        fab = FloatingActionButton.extended(
          onPressed: _onFabPressed,
          icon: const Icon(Icons.add),
          label: const Text(AppStrings.addListing),
        );
      }
.
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: fab,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: AppStrings.navDirectory,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_outline),
            activeIcon: Icon(Icons.bookmark),
            label: AppStrings.navMyListings,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: AppStrings.navMap,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: AppStrings.navSettings,
          ),
        ],
      ),
    );
  }
}
