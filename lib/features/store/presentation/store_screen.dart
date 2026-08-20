import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';

enum StoreSection { tests, batches }

StoreSection storeSectionFromQuery(String? value) =>
    value?.trim().toLowerCase() == 'batches'
        ? StoreSection.batches
        : StoreSection.tests;

class StoreScreen extends StatefulWidget {
  const StoreScreen({
    super.key,
    this.initialSection = StoreSection.tests,
  });

  final StoreSection initialSection;

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  late StoreSection _section;

  @override
  void initState() {
    super.initState();
    _section = widget.initialSection;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'Preparation products',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Test series and batches stay separate so you always know what you are buying.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<StoreSection>(
                segments: const [
                  ButtonSegment(
                    value: StoreSection.tests,
                    icon: Icon(Icons.assignment_outlined),
                    label: Text('Test series'),
                  ),
                  ButtonSegment(
                    value: StoreSection.batches,
                    icon: Icon(Icons.school_outlined),
                    label: Text('Batches'),
                  ),
                ],
                selected: {_section},
                onSelectionChanged: (selection) {
                  setState(() => _section = selection.first);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_section == StoreSection.tests)
              _ProductFoundationCard(
                key: const Key('store-test-series'),
                icon: Icons.assignment_turned_in_outlined,
                title: 'Test series',
                description:
                    'Browse the existing test catalogue now. Pricing and purchase controls will appear only when canonical product and entitlement data is available.',
                actionLabel: 'Browse tests',
                onAction: () => context.go('/exams'),
              )
            else
              const _ProductFoundationCard(
                key: Key('store-batches'),
                icon: Icons.school_outlined,
                title: 'Batches',
                description:
                    'No batches are published yet. This surface is ready for real batch products once the catalogue and entitlement backend is connected.',
              ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: scheme.secondaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    color: scheme.onSecondaryContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'ExamTree will not show fabricated discounts, fake urgency or unavailable products. Store cards will be driven by published backend data.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSecondaryContainer,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductFoundationCard extends StatelessWidget {
  const _ProductFoundationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      color: scheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34, color: scheme.primary),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
