import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/listing_model.dart';
import '../../models/review_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../services/firestore_service.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';
import '../../widgets/category_chip.dart';
import 'create_edit_listing_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  final ListingModel listing;
  const ListingDetailScreen({super.key, required this.listing});

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  final _firestoreService = FirestoreService();

  ReviewModel? _userReview;
  bool _reviewsLoading = true;

  LatLng get _position =>
      LatLng(widget.listing.latitude, widget.listing.longitude);

  Set<Marker> get _markers => {
        Marker(
          markerId: const MarkerId('place'),
          position: _position,
          infoWindow: InfoWindow(title: widget.listing.name),
        ),
      };

  @override
  void initState() {
    super.initState();
    _loadUserReview();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserReview() async {
    final uid = context.read<AppAuthProvider>().firebaseUser?.uid;
    if (uid == null) {
      setState(() => _reviewsLoading = false);
      return;
    }
    final review =
        await _firestoreService.getUserReview(widget.listing.id, uid);
    if (mounted) {
      setState(() {
        _userReview = review;
        _reviewsLoading = false;
      });
    }
  }

  void _getDirections() {
    AppHelpers.launchMapsDirections(
      latitude: widget.listing.latitude,
      longitude: widget.listing.longitude,
      label: widget.listing.name,
    );
  }

  void _callNow() => AppHelpers.launchPhone(widget.listing.contact);

  void _editListing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateEditListingScreen(existingListing: widget.listing),
      ),
    );
  }

  Future<void> _deleteListing() async {
    final confirmed = await AppHelpers.showConfirmDialog(
      context,
      title: AppStrings.deleteListing,
      message: 'Are you sure you want to delete "${widget.listing.name}"? This action cannot be undone.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );

    if (!confirmed || !mounted) return;

    final success = await context.read<ListingsProvider>().deleteListing(widget.listing.id);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        AppHelpers.showSnackBar(context, 'Listing deleted successfully.');
      } else {
        AppHelpers.showSnackBar(
          context,
          context.read<ListingsProvider>().errorMessage ?? AppStrings.genericError,
          isError: true,
        );
      }
    }
  }

  void _showReviewSheet() {
    double selectedRating = 5.0;
    final commentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.md,
            right: AppSpacing.md,
            top: AppSpacing.lg,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Write a Review',
                  style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              Center(
                child: RatingBar.builder(
                  initialRating: selectedRating,
                  minRating: 1,
                  itemCount: 5,
                  itemSize: 40,
                  itemPadding:
                      const EdgeInsets.symmetric(horizontal: 4),
                  itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: AppColors.accent),
                  onRatingUpdate: (r) =>
                      setSheetState(() => selectedRating = r),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Share your experience (optional)',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await _submitReview(
                        selectedRating, commentController.text.trim());
                  },
                  child: const Text('Submit Review'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReview(double rating, String comment) async {
    final auth = context.read<AppAuthProvider>();
    final uid = auth.firebaseUser?.uid;
    if (uid == null) return;

    final userName = auth.userModel?.displayName ??
        auth.firebaseUser?.displayName ??
        'Anonymous';

    final review = ReviewModel(
      id: const Uuid().v4(),
      listingId: widget.listing.id,
      userId: uid,
      userName: userName,
      rating: rating,
      comment: comment,
      timestamp: DateTime.now(),
    );

    try {
      await _firestoreService.addReview(review);
      if (mounted) {
        setState(() => _userReview = review);
        AppHelpers.showSnackBar(context, 'Review submitted — thank you!');
      }
    } catch (_) {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Failed to submit review.',
            isError: true);
      }
    }
  }

  Future<void> _deleteUserReview() async {
    final review = _userReview;
    if (review == null) return;

    final confirmed = await AppHelpers.showConfirmDialog(
      context,
      title: 'Delete Review',
      message: 'Remove your review for this place?',
      confirmLabel: 'Delete',
    );
    if (!confirmed) return;

    try {
      await _firestoreService.deleteReview(review.id, widget.listing.id);
      if (mounted) {
        setState(() => _userReview = null);
        AppHelpers.showSnackBar(context, 'Review deleted.');
      }
    } catch (_) {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Failed to delete review.',
            isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AppAuthProvider>();
    final listing = widget.listing;
    final isOwner = auth.firebaseUser?.uid == listing.createdBy;
    final isLoggedIn = auth.firebaseUser != null;
    final canReview = isLoggedIn && !isOwner;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // appBar
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: listing.categoryInfo.color,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                listing.name,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Container(
                color: listing.categoryInfo.color,
                child: Icon(
                  listing.categoryInfo.iconData,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ),
            actions: [
              if (isOwner) ...[
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: _editListing,
                  tooltip: AppStrings.editListing,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white),
                  onPressed: _deleteListing,
                  tooltip: AppStrings.deleteListing,
                ),
              ],
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // category & rating
                  Row(
                    children: [
                      CategoryBadge(category: listing.categoryEnum),
                      const Spacer(),
                      if (listing.hasRatings) ...[
                        const Icon(Icons.star,
                            size: 16, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text(
                          '${listing.rating.toStringAsFixed(1)} '
                          '(${listing.ratingCount} reviews)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // action buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getDirections,
                          icon: const Icon(Icons.directions),
                          label: const Text(AppStrings.getDirections),
                        ),
                      ),
                      if (listing.contact.isNotEmpty) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _callNow,
                            icon: const Icon(Icons.phone_outlined),
                            label: const Text(AppStrings.callNow),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // info card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          _InfoRow(
                            icon: Icons.location_on_outlined,
                            label: 'Address',
                            value: listing.address,
                          ),
                          if (listing.contact.isNotEmpty) ...[
                            const Divider(),
                            _InfoRow(
                              icon: Icons.phone_outlined,
                              label: 'Contact',
                              value: AppHelpers.formatPhone(listing.contact),
                            ),
                          ],
                          const Divider(),
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: 'Added by',
                            value: listing.createdByName,
                          ),
                          const Divider(),
                          _InfoRow(
                            icon: Icons.access_time_outlined,
                            label: 'Added on',
                            value: AppHelpers.formatDate(listing.timestamp),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // description
                  if (listing.description.isNotEmpty) ...[
                    Text('About', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.sm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Text(
                          listing.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  // reviews section
                  Row(
                    children: [
                      Text('Reviews', style: theme.textTheme.titleMedium),
                      const Spacer(),
                      if (!_reviewsLoading && canReview)
                        _userReview == null
                            ? TextButton.icon(
                                onPressed: _showReviewSheet,
                                icon: const Icon(
                                    Icons.rate_review_outlined,
                                    size: 16),
                                label: const Text('Write a Review'),
                              )
                            : TextButton.icon(
                                onPressed: _deleteUserReview,
                                icon: Icon(
                                  Icons.delete_outline,
                                  size: 16,
                                  color: theme.colorScheme.error,
                                ),
                                label: Text(
                                  'Delete My Review',
                                  style: TextStyle(
                                      color: theme.colorScheme.error),
                                ),
                              ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  StreamBuilder<List<ReviewModel>>(
                    stream:
                        _firestoreService.reviewsStream(widget.listing.id),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final reviews = snapshot.data ?? [];
                      if (reviews.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          child: Text(
                            'No reviews yet. Be the first!',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(color: AppColors.textHint),
                          ),
                        );
                      }
                      return Column(
                        children: reviews
                            .map((r) => _ReviewCard(review: r))
                            .toList(),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // embedded google map
                  Text('Location', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.sm),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.cardRadius),
                    child: SizedBox(
                      height: 220,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: _position,
                          zoom: 15,
                        ),
                        markers: _markers,
                        myLocationButtonEnabled: false,
                        zoomControlsEnabled: false,
                        onMapCreated: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// review card widget

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: Text(
                    review.userName.isNotEmpty
                        ? review.userName[0].toUpperCase()
                        : '?',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(review.userName,
                          style: theme.textTheme.labelLarge),
                      Text(
                        AppHelpers.timeAgo(review.timestamp),
                        style: theme.textTheme.labelSmall
                            ?.copyWith(color: AppColors.textHint),
                      ),
                    ],
                  ),
                ),
                RatingBarIndicator(
                  rating: review.rating,
                  itemCount: 5,
                  itemSize: 14,
                  itemBuilder: (_, __) =>
                      const Icon(Icons.star, color: AppColors.accent),
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                review.comment,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// info row widget used in the info card

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: AppColors.textHint),
              ),
              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
