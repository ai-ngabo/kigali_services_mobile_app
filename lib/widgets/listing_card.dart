import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/listing_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'category_chip.dart';

class ListingCard extends StatelessWidget {
  final ListingModel listing;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.listing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final info = listing.categoryInfo;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // category icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: info.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.sm + 2),
                ),
                child: Icon(info.iconData, color: info.color, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),

              // content column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      listing.name,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Category badge
                    CategoryBadge(category: listing.categoryEnum),
                    const SizedBox(height: AppSpacing.sm),

                    // Address
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            listing.address,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    // Rating row
                    if (listing.hasRatings) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          RatingBarIndicator(
                            rating: listing.rating,
                            itemCount: 5,
                            itemSize: 13,
                            itemBuilder: (_, __) => const Icon(
                              Icons.star,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${listing.rating.toStringAsFixed(1)} '
                            '(${listing.ratingCount})',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // timestamp 
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    AppHelpers.timeAgo(listing.timestamp),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textHint,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}