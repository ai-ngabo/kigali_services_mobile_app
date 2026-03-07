import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/filter_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/loading_widget.dart';
import 'listing_detail_screen.dart';
import 'create_edit_listing_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetail(context, listing) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ListingDetailScreen(listing: listing),
      ),
    );
  }

  void _openCreate() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateEditListingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<ListingsProvider>();
    final filter = context.watch<FilterProvider>();
    final auth = context.watch<AppAuthProvider>();
    final theme = Theme.of(context);

    final filtered = listings.filteredListings(
      query: filter.searchQuery,
      category: filter.selectedCategory,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.appName,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                )),
            Text(
              '${listings.listings.length} places in Kigali',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchHint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: filter.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          filter.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: filter.setSearchQuery,
            ),
          ),

          // category chips
          CategoryFilterRow(
            selected: filter.selectedCategory,
            onSelected: filter.setCategory,
          ),
          const SizedBox(height: AppSpacing.sm),

          const Divider(height: 1),

          // listings
          Expanded(
            child: listings.isLoading
                ? const LoadingWidget(message: 'Loading listings...')
                : listings.errorMessage != null
                    ? EmptyStateWidget(
                        icon: Icons.wifi_off_outlined,
                        title: 'Failed to load listings',
                        subtitle: listings.errorMessage,
                      )
                    : filtered.isEmpty
                        ? EmptyStateWidget(
                            icon: Icons.search_off_outlined,
                            title: AppStrings.noListings,
                            subtitle: filter.hasActiveFilter
                                ? 'Try a different search or category'
                                : 'Be the first to add a place!',
                            action: ElevatedButton.icon(
                              onPressed: _openCreate,
                              icon: const Icon(Icons.add),
                              label: const Text(AppStrings.addListing),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            itemCount: filtered.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (ctx, i) => ListingCard(
                              listing: filtered[i],
                              onTap: () => _openDetail(ctx, filtered[i]),
                            ),
                          ),
          ),
        ],
      ),

      // only shown when logged in
      floatingActionButton: auth.isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: _openCreate,
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addListing),
            )
          : null,
    );
  }
}