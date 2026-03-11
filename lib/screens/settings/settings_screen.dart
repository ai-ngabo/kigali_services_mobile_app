import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/listings_provider.dart';
import '../../utils/constants.dart';
import '../../utils/helpers.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final settings = context.watch<SettingsProvider>();
    final listings = context.watch<ListingsProvider>();
    final theme = Theme.of(context);
    final user = auth.userModel;

    // Fallback display values from Firebase Auth when Firestore profile is missing
    final displayName = user?.displayName ?? auth.firebaseUser?.displayName ?? auth.firebaseUser?.email ?? 'User';
    final email = user?.email ?? auth.firebaseUser?.email ?? '';
    final initials = user?.initials ?? (displayName.isNotEmpty ? displayName[0].toUpperCase() : '?');

    // Use the actual count from listings provider if available, else fallback to model
    final realListingCount = auth.isLoggedIn ? listings.myListings.length : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: ListView(
        children: [
          // profile card
          if (auth.isLoggedIn) ...[
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: Text(
                      initials,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$realListingCount listing${realListingCount == 1 ? '' : 's'} added',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Not logged in banner
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  const Icon(Icons.person_outline,
                      size: 48, color: Colors.white54),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Not signed in',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // preferences section
          const _SectionHeader('Preferences'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(AppStrings.notifications),
                  subtitle: const Text(AppStrings.notificationsSubtitle),
                  secondary: const Icon(Icons.notifications_outlined,
                      color: AppColors.primary),
                  value: settings.notificationsEnabled,
                  onChanged: (_) => settings.toggleNotifications(),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // About section
          const _SectionHeader('About'),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.info_outline, color: AppColors.primary),
                  title: const Text('App Version'),
                  trailing: Text(
                    '1.0.0',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                const ListTile(
                  leading: Icon(Icons.location_city,
                      color: AppColors.primary),
                  title: Text(AppStrings.appName),
                  subtitle: Text(AppStrings.tagline),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Account section (only if logged in)
          if (auth.isLoggedIn) ...[
            const _SectionHeader('Account'),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirmed = await AppHelpers.showConfirmDialog(
                      context,
                      title: 'Log Out',
                      message: 'Are you sure you want to log out?',
                      confirmLabel: AppStrings.logout,
                    );
                    if (confirmed && context.mounted) {
                      context.read<AppAuthProvider>().signOut();
                    }
                  },
                  icon: const Icon(Icons.logout, color: AppColors.error),
                  label: const Text(AppStrings.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textHint,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
