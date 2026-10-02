import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/mobile_analytics_provider.dart';
import '../../../core/providers/repository_providers.dart';

class MobileNotificationItem {
  const MobileNotificationItem({
    required this.campaignId,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.destinationType,
    required this.destinationValue,
    required this.sentAt,
    required this.openedAt,
    required this.readAt,
  });

  final String campaignId;
  final String title;
  final String body;
  final String imageUrl;
  final String destinationType;
  final String destinationValue;
  final DateTime? sentAt;
  final DateTime? openedAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  factory MobileNotificationItem.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(Object? value) {
      final text = value?.toString().trim() ?? '';
      return text.isEmpty ? null : DateTime.tryParse(text)?.toLocal();
    }

    return MobileNotificationItem(
      campaignId: json['campaignId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      destinationType: json['destinationType']?.toString() ?? 'none',
      destinationValue: json['destinationValue']?.toString() ?? '',
      sentAt: parseDate(json['sentAt']),
      openedAt: parseDate(json['openedAt']),
      readAt: parseDate(json['readAt']) ?? parseDate(json['openedAt']),
    );
  }
}

final mobileNotificationInboxProvider =
    FutureProvider<List<MobileNotificationItem>>((ref) async {
  final response =
      await ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>(
            'mobile/notifications',
          );
  final rows = response.data?['notifications'];
  if (rows is! List) return const <MobileNotificationItem>[];
  return rows
      .whereType<Map>()
      .map(
        (row) => MobileNotificationItem.fromJson(
          Map<String, dynamic>.from(row),
        ),
      )
      .where((item) => item.campaignId.isNotEmpty)
      .toList(growable: false);
});

class MobileNotificationsScreen extends ConsumerWidget {
  const MobileNotificationsScreen({super.key});

  Future<void> _markAllRead(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(apiClientProvider).dio.post<void>(
            'mobile/notifications/read-all',
          );
      ref.invalidate(mobileNotificationInboxProvider);
      await ref.read(mobileNotificationInboxProvider.future);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All notifications marked as read.')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to mark notifications as read.')),
        );
      }
    }
  }

  Future<void> _open(
    BuildContext context,
    WidgetRef ref,
    MobileNotificationItem item,
  ) async {
    try {
      await ref.read(apiClientProvider).dio.post<void>(
            'mobile/notifications/${item.campaignId}/open',
          );
      await ref.read(mobileAnalyticsClientProvider).track(
            'notification_open',
            entityType: 'notification',
            entityId: item.campaignId,
            placement: 'inbox',
            metadata: <String, Object?>{
              'destinationType': item.destinationType,
            },
          );
      ref.invalidate(mobileNotificationInboxProvider);
    } catch (_) {
      // Opening the destination remains useful even if read telemetry fails.
    }

    if (!context.mounted) return;

    switch (item.destinationType) {
      case 'exam':
        if (item.destinationValue.isNotEmpty) {
          context.push(
            '/exam-details?id=${Uri.encodeQueryComponent(item.destinationValue)}',
          );
        }
        return;
      case 'test_series':
        if (item.destinationValue.isNotEmpty) {
          context.push(
            '/test-series?id=${Uri.encodeQueryComponent(item.destinationValue)}',
          );
        } else {
          context.go('/exams');
        }
        return;
      case 'learn':
        if (item.destinationValue.startsWith('/')) {
          context.push(item.destinationValue);
        } else {
          context.go('/learn');
        }
        return;
      case 'page':
        if (item.destinationValue.isNotEmpty) {
          context.push('/page/${Uri.encodeComponent(item.destinationValue)}');
        }
        return;
      case 'url':
        final uri = Uri.tryParse(item.destinationValue);
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
      default:
        return;
    }
  }

  String _timeLabel(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final delta = now.difference(date);
    if (delta.inMinutes < 1) return 'Just now';
    if (delta.inHours < 1) return '${delta.inMinutes}m';
    if (delta.inDays < 1) return '${delta.inHours}h';
    if (delta.inDays < 7) return '${delta.inDays}d';
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(mobileNotificationInboxProvider);
    final unreadCount =
        notifications.value?.where((item) => item.isUnread).length ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () => _markAllRead(context, ref),
              child: const Text(
                'Mark all read',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
        ],
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE8EDF3)),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mobileNotificationInboxProvider);
          await ref.read(mobileNotificationInboxProvider.future);
        },
        child: notifications.when(
          loading: () => const _NotificationLoadingState(),
          error: (error, stack) => _NotificationErrorState(
            onRetry: () => ref.invalidate(mobileNotificationInboxProvider),
          ),
          data: (items) {
            final unread = items.where((item) => item.isUnread).length;

            return ListView(
              key: const Key('notification-inbox-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 28),
              children: [
                _NotificationHero(
                  totalCount: items.length,
                  unreadCount: unread,
                ),
                const SizedBox(height: 20),
                _SectionHeading(
                  title: items.isEmpty ? 'Your inbox' : 'Latest updates',
                  subtitle: items.isEmpty
                      ? 'ExamTree updates and reminders will appear here.'
                      : unread == 0
                          ? 'You are all caught up.'
                          : '$unread ${unread == 1 ? 'update is' : 'updates are'} waiting for you.',
                ),
                const SizedBox(height: 10),
                if (items.isEmpty)
                  const _EmptyNotifications()
                else
                  for (var index = 0; index < items.length; index++) ...[
                    _NotificationCard(
                      item: items[index],
                      timeLabel: _timeLabel(items[index].sentAt),
                      onTap: () => _open(context, ref, items[index]),
                    ),
                    if (index != items.length - 1)
                      const SizedBox(height: 10),
                  ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NotificationHero extends StatelessWidget {
  const _NotificationHero({
    required this.totalCount,
    required this.unreadCount,
  });

  final int totalCount;
  final int unreadCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('notification-inbox-hero'),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF031B3A),
            Color(0xFF063A70),
            Color(0xFF0B5D96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062D5C).withValues(alpha: .13),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -28,
            top: -34,
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'NOTIFICATIONS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFFFD36B),
                  fontWeight: FontWeight.w900,
                  letterSpacing: .9,
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Important updates, in one place.',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Exam reminders, learning updates and test announcements stay easy to find.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: .84),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _HeroPill(
                    icon: Icons.notifications_active_outlined,
                    label: '$unreadCount unread',
                  ),
                  _HeroPill(
                    icon: Icons.inbox_outlined,
                    label: '$totalCount total',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFFD36B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            color: const Color(0xFF10264A),
            fontWeight: FontWeight.w900,
            letterSpacing: -.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF718096),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.item,
    required this.timeLabel,
    required this.onTap,
  });

  final MobileNotificationItem item;
  final String timeLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = item.imageUrl.trim().isNotEmpty;
    final destination = _destinationLabel(item.destinationType);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: item.isUnread ? const Color(0xFFFFFEFA) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: item.isUnread
                ? const Color(0xFFEBD9A6)
                : const Color(0xFFE3E9F1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF10264A).withValues(alpha: .035),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (hasImage)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                  ),
                  child: AspectRatio(
                    aspectRatio: 16 / 7,
                    child: Image.network(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(13, 12, 13, 13),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: item.isUnread
                            ? const Color(0xFFFFF4D6)
                            : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        _destinationIcon(item.destinationType),
                        color: item.isUnread
                            ? const Color(0xFF0B3A6F)
                            : const Color(0xFF64748B),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF10264A),
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -.15,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              if (item.isUnread) ...[
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.only(top: 5),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD4A73A),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (item.body.trim().isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(
                              item.body,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF526274),
                                height: 1.42,
                              ),
                            ),
                          ],
                          const SizedBox(height: 9),
                          Row(
                            children: [
                              if (destination.isNotEmpty) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF4FF),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    destination,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF0B5D96),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (timeLabel.isNotEmpty)
                                Text(
                                  timeLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: const Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              const Spacer(),
                              const Icon(
                                Icons.chevron_right_rounded,
                                size: 19,
                                color: Color(0xFF52708F),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _destinationIcon(String type) => switch (type) {
        'exam' => Icons.assignment_outlined,
        'test_series' => Icons.fact_check_outlined,
        'learn' => Icons.menu_book_outlined,
        'page' => Icons.web_outlined,
        'url' => Icons.open_in_new_rounded,
        _ => Icons.notifications_none_rounded,
      };

  static String _destinationLabel(String type) => switch (type) {
        'exam' => 'Exam',
        'test_series' => 'Tests',
        'learn' => 'Learn',
        'page' => 'Page',
        'url' => 'Open link',
        _ => '',
      };
}

class _EmptyNotifications extends StatelessWidget {
  const _EmptyNotifications();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE3E9F1)),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              size: 29,
              color: Color(0xFF0B5D96),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No notifications yet',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF10264A),
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Important ExamTree updates will appear here when there is something worth your attention.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF718096),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationErrorState extends StatelessWidget {
  const _NotificationErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 120, 20, 30),
      children: [
        const Icon(
          Icons.cloud_off_outlined,
          size: 48,
          color: Color(0xFF94A3B8),
        ),
        const SizedBox(height: 14),
        Text(
          'Unable to load notifications',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF10264A),
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Check your connection and try again.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF718096),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF073A6A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.w900),
            ),
            child: const Text('Try again'),
          ),
        ),
      ],
    );
  }
}

class _NotificationLoadingState extends StatelessWidget {
  const _NotificationLoadingState();

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double radius = 20}) => Container(
          height: height,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F5F8),
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 28),
      children: [
        block(196, radius: 24),
        const SizedBox(height: 20),
        block(24),
        const SizedBox(height: 10),
        block(132),
        const SizedBox(height: 10),
        block(132),
      ],
    );
  }
}
