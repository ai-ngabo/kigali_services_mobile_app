import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/loading_widget.dart';
import '../auth/login_screen.dart';
import '../directory/create_edit_listing_screen.dart';
import '../directory/listing_detail_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AppAuthProvider>().firebaseUser?.uid;
      if (uid != null) {
        context.read<ListingsProvider>().startListeningMyListings(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final listings = context.watch<ListingsProvider>();
    final theme = Theme.of(context);

    // Not logged in
    if (!auth.isLoggedIn) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.navMyListings)),
        body: EmptyStateWidget(
          icon: Icons.lock_outline,
          title: 'Sign in to manage your listings',
          subtitle: 'Create an account or log in to add and edit places.',
          action: ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
            child: const Text(AppStrings.login),
          ),
        ),
      );
    }

    final myListings = listings.myListings;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(AppStrings.navMyListings),
            Text(
              '${myListings.length} listing${myListings.length == 1 ? '' : 's'}',
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: Colors.white70),
            ),
          ],
        ),
      ),
      body: listings.isLoading
          ? const LoadingWidget(message: 'Loading your listings...')
          : myListings.isEmpty
              ? EmptyStateWidget(
                  icon: Icons.bookmark_border_outlined,
                  title: 'No listings yet',
                  subtitle:
                      'You haven\'t added any places. Tap the button to create your first listing.',
                  action: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CreateEditListingScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text(AppStrings.addListing),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: myListings.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (ctx, i) {
                    final listing = myListings[i];
                    return ListingCard(
                      listing: listing,
                      onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                          builder: (_) =>
                              ListingDetailScreen(listing: listing),
                        ),
                      ),
                    );
                  },
                ),
      // FAB removed from here, now managed by MainShell in main.dart
    );
  }
}
