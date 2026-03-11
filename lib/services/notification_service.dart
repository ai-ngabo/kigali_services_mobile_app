import 'package:flutter/material.dart';

// notification helper
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  bool _enabled = true;

  bool get isEnabled => _enabled;

  void setEnabled(bool value) => _enabled = value;

  // notification using SnackBar
  void show(
    BuildContext context, {
    required String title,
    String? body,
    IconData icon = Icons.notifications_outlined,
    Color? color,
  }) {
    if (!_enabled) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (body != null)
                    Text(
                      body,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12),
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: color ?? const Color(0xFF0D47A1),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // notify when a new listing is added
  void notifyListingAdded(BuildContext context, String listingName) {
    show(
      context,
      title: 'New listing added',
      body: listingName,
      icon: Icons.add_location_alt_outlined,
    );
  }

  // notify when a new review is received on a listing
  void notifyNewReview(BuildContext context, String listingName) {
    show(
      context,
      title: 'New review on $listingName',
      icon: Icons.star_outline,
    );
  }
}
