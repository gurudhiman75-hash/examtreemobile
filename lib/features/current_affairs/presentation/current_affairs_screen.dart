import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../../learn/domain/learning_resource.dart';
import '../../learn/presentation/providers/learning_resources_providers.dart';

enum _FormatFilter { all, articles, pdfs }

class CurrentAffairsScreen extends ConsumerStatefulWidget {
  const CurrentAffairsScreen({super.key});

  @override
  ConsumerState<CurrentAffairsScreen> createState() =>
      _CurrentAffairsScreenState();
}

class _CurrentAffairsScreenState extends ConsumerState<CurrentAffairsScreen> {
  _FormatFilter _filter = _FormatFilter.all;

  Future<void> _refresh() async {
    ref.invalidate(learningResourcesProvider);
    try {
      await ref.read(learningResourcesProvider.future);
    } catch (_) {
      // The screen renders its own recoverable error state.
    }
  }

  Future<void> _open(LearningResourceSummary resource) async {
    if (resource.hasInlineContent) {
      if (mounted) context.push('/learn-resource', extra: resource.id);
      return;
    }
    final url = resource.contentUrl;
    if (url != null &&
        await launchUrl(url, mode: LaunchMode.externalApplication)) {
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This current-affairs item could not be opened.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resourcesAsync = ref.watch(relevantLearningResourcesProvider);

    return SafeArea(
      child: resourcesAsync.when(
        loading: () => const _LoadingState(),
        error: (error, stackTrace) => NetworkFailureView(
          error: error,
          fallbackTitle: 'Unable to load current affairs',
          onRetry: () => ref.invalidate(learningResourcesProvider),
        ),
        data: (allResources) {
          final currentAffairs = allResources
              .where(
                (resource) =>
                    resource.category == LearningResourceCategory.currentAffairs,
              )
              .toList(growable: false);
          final visible = currentAffairs.where((resource) {
            return switch (_filter) {
              _FormatFilter.all => true,
              _FormatFilter.articles =>
                resource.format == LearningResourceFormat.article,
              _FormatFilter.pdfs =>
                resource.format == LearningResourceFormat.pdf,
            };
          }).toList(growable: false);

          final articleCount = currentAffairs
              .where((resource) => resource.format == LearningResourceFormat.article)
              .length;
          final pdfCount = currentAffairs
              .where((resource) => resource.format == LearningResourceFormat.pdf)
              .length;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              key: const Key('current-affairs-scroll'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              children: [
                _Hero(
                  count: currentAffairs.length,
                  articleCount: articleCount,
                  pdfCount: pdfCount,
                  latestDate: currentAffairs.isEmpty
                      ? null
                      : currentAffairs
                          .map((item) => item.contentDate ?? item.publishedAt)
                          .whereType<DateTime>()
                          .fold<DateTime?>(
                            null,
                            (latest, date) =>
                                latest == null || date.isAfter(latest)
                                    ? date
                                    : latest,
                          ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SectionHeading(
                  title: 'Latest updates',
                  subtitle: currentAffairs.isEmpty
                      ? 'Published current-affairs material will appear here.'
                      : 'Exam-relevant updates from the published ExamTree feed.',
                ),
                const SizedBox(height: AppSpacing.sm),
                _FilterBar(
                  value: _filter,
                  articleCount: articleCount,
                  pdfCount: pdfCount,
                  onChanged: (value) => setState(() => _filter = value),
                ),
                const SizedBox(height: AppSpacing.md),
                if (currentAffairs.isEmpty)
                  const _EmptyState()
                else if (visible.isEmpty)
                  const _FilteredEmptyState()
                else
                  for (var index = 0; index < visible.length; index++) ...[
                    _CurrentAffairsCard(
                      resource: visible[index],
                      onTap: () => _open(visible[index]),
                    ),
                    if (index != visible.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({
    required this.count,
    required this.articleCount,
    required this.pdfCount,
    required this.latestDate,
  });

  final int count;
  final int articleCount;
  final int pdfCount;
  final DateTime? latestDate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('current-affairs-hero'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF062D5C), Color(0xFF0A4B82)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062D5C).withValues(alpha: 0.16),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -34,
            top: -40,
            child: Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CURRENT AFFAIRS',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: const Color(0xFFFFD36B),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.9,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Stay ready for what changed.',
                style: AppTypography.premiumHeading(
                  theme.textTheme.headlineMedium,
                ).copyWith(
                  color: Colors.white,
                  height: 1.08,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Read published updates in your preferred language and keep exam-relevant developments close at hand.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.84),
                  height: 1.42,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  _HeroStat(
                    icon: Icons.newspaper_rounded,
                    value: '$count',
                    label: count == 1 ? 'update' : 'updates',
                  ),
                  _HeroStat(
                    icon: Icons.article_outlined,
                    value: '$articleCount',
                    label: articleCount == 1 ? 'article' : 'articles',
                  ),
                  _HeroStat(
                    icon: Icons.picture_as_pdf_outlined,
                    value: '$pdfCount',
                    label: pdfCount == 1 ? 'PDF' : 'PDFs',
                  ),
                ],
              ),
              if (latestDate != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Latest: ${_dateLabel(latestDate!)}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.78),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFFFFD36B)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '$value $label',
            style: theme.textTheme.labelMedium?.copyWith(
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
          style: AppTypography.premiumHeading(
            theme.textTheme.titleLarge,
          ).copyWith(color: const Color(0xFF10264A)),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.value,
    required this.articleCount,
    required this.pdfCount,
    required this.onChanged,
  });

  final _FormatFilter value;
  final int articleCount;
  final int pdfCount;
  final ValueChanged<_FormatFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = <(_FormatFilter, String)>[
      (_FormatFilter.all, 'All'),
      (_FormatFilter.articles, 'Articles $articleCount'),
      (_FormatFilter.pdfs, 'PDFs $pdfCount'),
    ];
    return Wrap(
      spacing: AppSpacing.xs,
      runSpacing: AppSpacing.xs,
      children: [
        for (final option in options)
          ChoiceChip(
            key: Key('current-affairs-filter-${option.$1.name}'),
            label: Text(option.$2),
            selected: value == option.$1,
            selectedColor: const Color(0xFF0B3A6F),
            backgroundColor: Colors.white,
            side: BorderSide(
              color: value == option.$1
                  ? const Color(0xFF0B3A6F)
                  : const Color(0xFFDCE5EF),
            ),
            labelStyle: TextStyle(
              color: value == option.$1
                  ? Colors.white
                  : const Color(0xFF526274),
              fontWeight:
                  value == option.$1 ? FontWeight.w800 : FontWeight.w600,
            ),
            onSelected: (_) => onChanged(option.$1),
          ),
      ],
    );
  }
}

class _CurrentAffairsCard extends StatelessWidget {
  const _CurrentAffairsCard({
    required this.resource,
    required this.onTap,
  });

  final LearningResourceSummary resource;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final date = resource.contentDate ?? resource.publishedAt;
    final target = _targetLabel(resource);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE8EDF3)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEDBE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      resource.format == LearningResourceFormat.pdf
                          ? Icons.picture_as_pdf_outlined
                          : Icons.article_outlined,
                      color: const Color(0xFF0B3A6F),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: [
                        if (date != null) _Badge(label: _dateLabel(date)),
                        _Badge(
                          label: resource.format == LearningResourceFormat.pdf
                              ? 'PDF'
                              : 'ARTICLE',
                        ),
                        _Badge(label: resource.languageCode.toUpperCase()),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF0B3A6F),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                resource.title,
                style: AppTypography.premiumHeading(
                  theme.textTheme.titleLarge,
                ).copyWith(
                  color: const Color(0xFF10264A),
                  height: 1.2,
                ),
              ),
              if (resource.summary.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  resource.summary,
                  maxLines:
                      MediaQuery.textScalerOf(context).scale(1) > 1.5 ? 5 : 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.flag_outlined,
                    size: 17,
                    color: Color(0xFFD6A63D),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      target,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: const Color(0xFF526274),
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6F9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: const Color(0xFF526274),
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('current-affairs-empty'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.newspaper_outlined,
            size: 42,
            color: Color(0xFF0B3A6F),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No current affairs are published yet.',
            textAlign: TextAlign.center,
            style: AppTypography.premiumHeading(
              theme.textTheme.titleMedium,
            ).copyWith(color: const Color(0xFF10264A)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'New published updates will appear here automatically.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _FilteredEmptyState extends StatelessWidget {
  const _FilteredEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('current-affairs-filter-empty'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE8EDF3)),
      ),
      child: Text(
        'No published items match this format yet.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF526274),
            ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          height: 255,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < 3; i++) ...[
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          if (i != 2) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

String _targetLabel(LearningResourceSummary resource) {
  if (resource.isGeneral) return 'All exams';
  if (resource.exams.isEmpty) return 'Selected exams';
  return resource.exams.take(2).map((exam) => exam.name).join(' · ');
}

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}
