import 'package:flutter/material.dart';
import '../constants.dart';

// Helper to open the notifications bottom sheet
void showNotificationsSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const NotificationsSheet(),
  );
}

// Simple notification model
class _NotificationItem {
  final String title;
  final String body;
  final String timeAgo;
  final IconData icon;
  final Color color;

  _NotificationItem({
    required this.title,
    required this.body,
    required this.timeAgo,
    required this.icon,
    required this.color,
  });
}

class NotificationsSheet extends StatelessWidget {
  final List<_NotificationItem> notifications;

  const NotificationsSheet({super.key, this.notifications = const []});

  List<_NotificationItem> _dummyNotifications() {
    return [
      _NotificationItem(
        title: 'Appointment Confirmed',
        body: 'Your checkup with Dr. Chen on Aug 22nd is confirmed.',
        timeAgo: '2m ago',
        icon: Icons.event_available_rounded,
        color: const Color(0xFF42A5F5),
      ),
      _NotificationItem(
        title: 'Reminder: Payment Due',
        body: 'A payment of \$450 for Root Canal is due soon.',
        timeAgo: '1h ago',
        icon: Icons.payments_rounded,
        color: const Color(0xFFFFB74D),
      ),
      _NotificationItem(
        title: 'New Clinic Offer',
        body: 'Enjoy 20% off on Teeth Whitening this week!',
        timeAgo: '1d ago',
        icon: Icons.local_offer_rounded,
        color: const Color(0xFF66BB6A),
      ),
      _NotificationItem(
        title: 'System Update',
        body: 'New features and bug fixes have been deployed.',
        timeAgo: '3d ago',
        icon: Icons.system_update_alt_rounded,
        color: const Color(0xFFAB47BC),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final data = notifications.isNotEmpty ? notifications : _dummyNotifications();

    return SafeArea(
      child: Container(
        color: Colors.black.withOpacity(0.35),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            constraints: const BoxConstraints(maxHeight: 550),
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  (isDark ? const Color(0xFF1E1E1E) : Colors.white).withOpacity(0.98),
                  (isDark ? const Color(0xFF121212) : theme.scaffoldBackgroundColor).withOpacity(0.98),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: kPrimaryColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_rounded,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Notifications',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: theme.iconTheme.color?.withOpacity(0.7),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = data[index];
                      return _NotificationTile(item: item);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.38) : Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  item.color.withOpacity(0.95),
                  item.color.withOpacity(0.75),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: item.color.withOpacity(0.40),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(item.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.textTheme.bodySmall?.color?.withOpacity(isDark ? 0.7 : 0.6) ??
                            (isDark ? Colors.white70 : Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    height: 1.25,
                    color: theme.textTheme.bodySmall?.color?.withOpacity(isDark ? 0.80 : 0.75) ??
                        (isDark ? Colors.white.withOpacity(0.85) : Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
