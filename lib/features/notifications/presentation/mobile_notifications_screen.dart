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
  });

  final String campaignId;
  final String title;
  final String body;
  final String imageUrl;
  final String destinationType;
  final String destinationValue;
  final DateTime? sentAt;
  final DateTime? openedAt;

  bool get isUnread => openedAt == null;

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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
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
          loading: () => ListView(
            physics: AlwaysScrollableScrollPhysics(),
            children: [
              SizedBox(height: 220),
              Center(child: CircularProgressIndicator()),
            ],
          ),
          error: (error, stack) => ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 120),
              Icon(
                Icons.cloud_off_outlined,
                size: 48,
                color: theme.colorScheme.outline,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load notifications',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Center(
                child: FilledButton(
                  onPressed: () =>
                      ref.invalidate(mobileNotificationInboxProvider),
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
          ),
          data: (items) {
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 120),
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 58,
                    color: const Color(0xFF0B3A6F),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ExamTree updates and reminders will appear here.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = items[index];
                return Material(
                  color: Colors.white,
                  elevation: 1,
                  shadowColor: const Color(0xFF10264A).withValues(alpha: .06),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE3E9F1)),
                  ),
                  child: InkWell(
                    onTap: () => _open(context, ref, item),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: item.imageUrl.trim().isNotEmpty
                                ? Image.network(
                                    item.imageUrl,
                                    width: 52,
                                    height: 52,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 42,
                                      height: 42,
                                      color: item.isUnread
                                          ? const Color(0xFFFFF4D6)
                                          : const Color(0xFFF1F5F9),
                                      child: Icon(
                                        Icons.notifications_outlined,
                                        color: item.isUnread
                                            ? const Color(0xFF0B3A6F)
                                            : const Color(0xFF64748B),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: item.isUnread
                                          ? const Color(0xFFFFF4D6)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.notifications_outlined,
                                      color: item.isUnread
                                          ? const Color(0xFF0B3A6F)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
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
                                        style:
                                            theme.textTheme.titleSmall?.copyWith(
                                          fontWeight: item.isUnread
                                              ? FontWeight.w800
                                              : FontWeight.w700,
                                          color: const Color(0xFF10264A),
                                        ),
                                      ),
                                    ),
                                    if (item.isUnread) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 8,
                                        height: 8,
                                        margin: const EdgeInsets.only(top: 4),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFD4A73A),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.body,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF475569),
                                    height: 1.35,
                                  ),
                                ),
                                if (_timeLabel(item.sentAt).isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    _timeLabel(item.sentAt),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
