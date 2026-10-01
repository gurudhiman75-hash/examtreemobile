import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/mobile_analytics_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/mobile_content_plan_item.dart';
import '../mobile_content_planning_providers.dart';

class MobilePlannedContentSection extends ConsumerWidget {
  const MobilePlannedContentSection({
    super.key,
    required this.slotKey,
    this.title = 'Featured for you',
  });

  final String slotKey;
  final String title;

  void _open(
    BuildContext context,
    WidgetRef ref,
    MobileContentPlanItem item,
  ) {
    unawaited(
      ref.read(mobileAnalyticsClientProvider).track(
            'content_plan_click',
            entityType: item.entityType,
            entityId: item.entityId,
            placement: item.slotKey,
          ),
    );

    switch (item.entityType) {
      case 'learning_resource':
        context.push('/learn-resource?id=${Uri.encodeQueryComponent(item.entityId)}');
        return;
      case 'current_affairs_release':
        context.go('/current-affairs');
        return;
      case 'test_series':
      case 'exam_family':
        context.go('/exams');
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(mobileContentPlanProvider(slotKey)).value ??
        const <MobileContentPlanItem>[];
    if (items.isEmpty) return const SizedBox.shrink();

    final analytics = ref.read(mobileAnalyticsClientProvider);
    for (final item in items.take(8)) {
      unawaited(
        analytics.trackOnce(
          'content-plan-impression-${item.id}',
          'content_plan_impression',
          entityType: item.entityType,
          entityId: item.entityId,
          placement: item.slotKey,
        ),
      );
    }

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: const Color(0xFF10264A),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.take(8).length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 220,
                child: Material(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                    side: const BorderSide(color: Color(0xFFE3E9F1)),
                  ),
                  child: InkWell(
                    onTap: () => _open(context, ref, item),
                    borderRadius: BorderRadius.circular(18),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (item.badgeText.trim().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4D6),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                item.badgeText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: const Color(0xFF8A5A00),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          const Spacer(),
                          Text(
                            item.displayLabel,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _typeLabel(item.entityType),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ],
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
        'learning_resource' => 'Learn resource',
        'current_affairs_release' => 'Current Affairs',
        'test_series' => 'Test series',
        'exam_family' => 'Exam category',
        _ => 'Featured',
      };
}
