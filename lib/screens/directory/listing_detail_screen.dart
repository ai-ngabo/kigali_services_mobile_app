import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../models/listing_model.dart';
import '../../providers/auth_provider.dart';
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
  GoogleMapController? _mapController;

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
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  void _getDirections() {
    AppHelpers.launchMapsDirections(
      latitude: widget.listing.latitude,
      longitude: widget.listing.longitude,
      label: widget.listing.name,
    );
  }

  void _callNow() {
    AppHelpers.launchPhone(widget.listing.contact);
  }

  void _editListing() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CreateEditListingScreen(existingListing: widget.listing),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AppAuthProvider>();
    final listing = widget.listing;
    final isOwner = auth.firebaseUser?.uid == listing.createdBy;

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
              if (isOwner)
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: _editListing,
                  tooltip: AppStrings.editListing,
                ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // category badge & rating
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

                  // description section
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

                  // embedding Google Map
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
                        onMapCreated: (c) => _mapController = c,
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
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textHint,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}