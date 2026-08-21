import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../domain/learning_resource.dart';
import 'providers/learning_resources_providers.dart';

class LearningResourceDetailScreen extends ConsumerWidget {
  const LearningResourceDetailScreen({
    super.key,
    required this.resourceId,
  });

  final String resourceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(learningResourceDetailProvider(resourceId));
    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: SafeArea(
        top: false,
        child: detailAsync.when(
          loading: () => const _DetailLoading(),
          error: (error, stackTrace) => NetworkFailureView(
            error: error,
            fallbackTitle: 'Unable to load this resource',
            onRetry: () => ref.invalidate(
              learningResourceDetailProvider(resourceId),
            ),
          ),
          data: (detail) => _ResourceDetail(detail: detail),
        ),
      ),
    );
  }
}

class _ResourceDetail extends StatelessWidget {
  const _ResourceDetail({required this.detail});

  final LearningResourceDetail detail;

  Future<void> _openUrl(BuildContext context, Uri uri) async {
    if (uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      return;
    }
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This link could not be opened.')),
    );
  }

  Future<void> _openMarkdownLink(BuildContext context, String? href) async {
    final uri = href == null ? null : Uri.tryParse(href);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Only secure web links can be opened.')),
      );
      return;
    }
    await _openUrl(context, uri);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final resource = detail.summary;
    final date = resource.contentDate ?? resource.publishedAt;
    final target = resource.isGeneral
        ? 'All exams'
        : resource.exams.isEmpty
            ? 'Selected exams'
            : resource.exams.map((exam) => exam.name).join(' · ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        _ResourceHero(
          resource: resource,
          date: date,
          target: target,
        ),
        const SizedBox(height: AppSpacing.xl),
        if (detail.bodyMarkdown.trim().isNotEmpty) ...[
          Text(
            'Resource',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.25,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MarkdownBody(
            data: detail.bodyMarkdown,
            selectable: true,
            onTapLink: (text, href, title) =>
                _openMarkdownLink(context, href),
            styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
              p: theme.textTheme.bodyLarge?.copyWith(height: 1.62),
              h1: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.25,
              ),
              h2: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.3,
              ),
              h3: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
              blockquotePadding: const EdgeInsets.all(AppSpacing.md),
              blockquoteDecoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              codeblockPadding: const EdgeInsets.all(AppSpacing.md),
              codeblockDecoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
              ),
              horizontalRuleDecoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: theme.colorScheme.outlineVariant),
                ),
              ),
            ),
          ),
        ] else if (resource.contentUrl != null)
          _DocumentCard(
            onOpen: () => _openUrl(context, resource.contentUrl!),
          )
        else
          const _UnavailableBody(),
        if (detail.bodyMarkdown.trim().isNotEmpty &&
            resource.contentUrl != null) ...[
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () => _openUrl(context, resource.contentUrl!),
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open supporting document'),
          ),
        ],
      ],
    );
  }
}

class _ResourceHero extends StatelessWidget {
  const _ResourceHero({
    required this.resource,
    required this.date,
    required this.target,
  });

  final LearningResourceSummary resource;
  final DateTime? date;
  final String target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formula = resource.category == LearningResourceCategory.formulaSheet;
    final currentAffairs =
        resource.category == LearningResourceCategory.currentAffairs;
    final icon = currentAffairs
        ? Icons.newspaper_rounded
        : formula
            ? Icons.functions_rounded
            : Icons.menu_book_rounded;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFF4F0FF), Color(0xFFE0F2FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: currentAffairs
                      ? AppColors.sky
                      : formula
                          ? AppColors.amber
                          : AppColors.tertiary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Wrap(
                  spacing: AppSpacing.xs,
                  runSpacing: AppSpacing.xs,
                  children: [
                    _HeroBadge(label: resource.category.label),
                    _HeroBadge(
                      label: resource.format == LearningResourceFormat.pdf
                          ? 'PDF'
                          : 'Article',
                    ),
                    _HeroBadge(label: resource.languageCode.toUpperCase()),
                    if (date != null) _HeroBadge(label: _dateLabel(date!)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            resource.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.45,
              height: 1.18,
            ),
          ),
          if (resource.summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              resource.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.onPrimaryContainer.withValues(alpha: 0.74),
                height: 1.48,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(
                  Icons.flag_outlined,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  target,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.onPrimaryContainer,
                    fontWeight: FontWeight.w800,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.roseContainer,
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.onRoseContainer,
              size: 27,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Document ready',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Open this published resource in your device browser or PDF app.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onOpen,
            icon: const Icon(Icons.open_in_new_rounded),
            label: const Text('Open document'),
          ),
        ],
      ),
    );
  }
}

class _UnavailableBody extends StatelessWidget {
  const _UnavailableBody();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'This published resource has no readable content right now.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget block(double height) => Container(
          height: height,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(22),
          ),
        );
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        block(250),
        const SizedBox(height: AppSpacing.xl),
        block(32),
        const SizedBox(height: AppSpacing.md),
        block(180),
      ],
    );
  }
}

String _dateLabel(DateTime value) {
  final local = value.toLocal();
  const months = <String>[
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

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.05),
        blurRadius: 20,
        offset: const Offset(0, 7),
      ),
    ];
