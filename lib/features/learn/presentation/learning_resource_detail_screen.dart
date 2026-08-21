import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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
      appBar: AppBar(title: const Text('Learning resource')),
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
    final scheme = theme.colorScheme;
    final resource = detail.summary;
    final date = resource.contentDate ?? resource.publishedAt;
    final targetLabel = resource.isGeneral
        ? 'All exams'
        : resource.exams.isEmpty
            ? 'Selected exams'
            : resource.exams.map((exam) => exam.name).join(' · ');

    return SelectionArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _MetaBadge(
                icon: resource.category == LearningResourceCategory.currentAffairs
                    ? Icons.newspaper_outlined
                    : resource.category == LearningResourceCategory.formulaSheet
                        ? Icons.functions_rounded
                        : Icons.menu_book_outlined,
                label: resource.category.label,
              ),
              _MetaBadge(
                icon: resource.format == LearningResourceFormat.pdf
                    ? Icons.picture_as_pdf_outlined
                    : Icons.article_outlined,
                label: resource.format == LearningResourceFormat.pdf
                    ? 'PDF'
                    : 'Article',
              ),
              _MetaBadge(
                icon: Icons.translate_rounded,
                label: resource.languageCode.toUpperCase(),
              ),
              if (date != null)
                _MetaBadge(
                  icon: Icons.calendar_today_outlined,
                  label: _dateLabel(date),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            resource.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.35,
            ),
          ),
          if (resource.summary.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              resource.summary,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.flag_outlined,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  targetLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Divider(color: scheme.outlineVariant),
          const SizedBox(height: AppSpacing.md),
          if (detail.bodyMarkdown.trim().isNotEmpty)
            MarkdownBody(
              data: detail.bodyMarkdown,
              selectable: true,
              onTapLink: (text, href, title) =>
                  _openMarkdownLink(context, href),
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
                h1: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                h2: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                h3: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                blockquoteDecoration: BoxDecoration(
                  color: scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
              ),
            )
          else if (resource.contentUrl != null)
            _DocumentCard(
              url: resource.contentUrl!,
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
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.url, required this.onOpen});

  final Uri url;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.picture_as_pdf_outlined,
            size: 34,
            color: scheme.primary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Document ready',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Open this published resource in your device browser or PDF app.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
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
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text(
        'This published resource has no readable content right now.',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

class _DetailLoading extends StatelessWidget {
  const _DetailLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          height: 30,
          width: 180,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 76,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        for (var index = 0; index < 5; index++) ...[
          Container(
            height: 22,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
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
