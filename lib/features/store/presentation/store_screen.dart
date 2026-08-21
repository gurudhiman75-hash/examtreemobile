import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/store_product.dart';
import 'providers/store_providers.dart';

enum StoreSection { tests, batches }

StoreSection storeSectionFromQuery(String? value) =>
    value?.trim().toLowerCase() == 'batches'
        ? StoreSection.batches
        : StoreSection.tests;

class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({
    super.key,
    this.initialSection = StoreSection.tests,
  });

  final StoreSection initialSection;

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
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
    final products = ref.watch(storeProductsProvider);

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
              _TestSeriesCatalog(
                key: const Key('store-test-series'),
                products: products,
                onRetry: () {
                  ref.invalidate(storeProductsProvider);
                },
                onBrowseTests: () => context.go('/exams'),
              )
            else
              const _ProductFoundationCard(
                key: Key('store-batches'),
                icon: Icons.school_outlined,
                title: 'Batches',
                description:
                    'No batches are published yet. ExamTree will show batches here only after real batch products and access rules are available.',
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
                      'Prices, validity and availability shown for test products come from the published ExamTree catalogue. We do not invent discounts, urgency or unavailable products.',
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

class _TestSeriesCatalog extends StatelessWidget {
  const _TestSeriesCatalog({
    super.key,
    required this.products,
    required this.onRetry,
    required this.onBrowseTests,
  });

  final AsyncValue<List<StoreProduct>> products;
  final VoidCallback onRetry;
  final VoidCallback onBrowseTests;

  @override
  Widget build(BuildContext context) {
    return products.when(
      loading: () => const _StoreLoadingCard(),
      error: (error, _) => _StoreErrorCard(
        error: error,
        onRetry: onRetry,
        onBrowseTests: onBrowseTests,
      ),
      data: (items) {
        if (items.isEmpty) {
          return _StoreEmptyCard(onBrowseTests: onBrowseTests);
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var index = 0; index < items.length; index++) ...[
              _CanonicalProductCard(
                product: items[index],
                onBrowseTests: onBrowseTests,
              ),
              if (index != items.length - 1)
                const SizedBox(height: AppSpacing.md),
            ],
          ],
        );
      },
    );
  }
}

class _CanonicalProductCard extends StatelessWidget {
  const _CanonicalProductCard({
    required this.product,
    required this.onBrowseTests,
  });

  final StoreProduct product;
  final VoidCallback onBrowseTests;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Icon(
                    Icons.assignment_turned_in_outlined,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (product.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          product.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _ProductFact(
                  icon: Icons.quiz_outlined,
                  label: _testCountLabel(product.testCount),
                ),
                if (product.validityDays != null)
                  _ProductFact(
                    icon: Icons.event_available_outlined,
                    label: '${product.validityDays} days access',
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: _ProductPrice(product: product)),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton(
                  onPressed: onBrowseTests,
                  child: const Text('Browse tests'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Secure purchase controls will appear here after mobile checkout is connected to the canonical order flow.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProductPrice extends StatelessWidget {
  const _ProductPrice({required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatStoreMoney(product.salePriceMinor, product.currency),
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: scheme.primary,
          ),
        ),
        if (product.hasCanonicalDiscount)
          Text(
            formatStoreMoney(product.listPriceMinor, product.currency),
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class _ProductFact extends StatelessWidget {
  const _ProductFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _StoreLoadingCard extends StatelessWidget {
  const _StoreLoadingCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(child: Text('Loading published test products…')),
        ],
      ),
    );
  }
}

class _StoreErrorCard extends StatelessWidget {
  const _StoreErrorCard({
    required this.error,
    required this.onRetry,
    required this.onBrowseTests,
  });

  final Object error;
  final VoidCallback onRetry;
  final VoidCallback onBrowseTests;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final message = error.toString().trim();

    return _ProductFoundationCard(
      icon: Icons.cloud_off_outlined,
      title: 'Store catalogue unavailable',
      description: message.isEmpty
          ? 'ExamTree could not load published products right now.'
          : message,
      actionLabel: 'Retry',
      onAction: onRetry,
      secondaryActionLabel: 'Browse tests',
      onSecondaryAction: onBrowseTests,
      iconColor: scheme.error,
    );
  }
}

class _StoreEmptyCard extends StatelessWidget {
  const _StoreEmptyCard({required this.onBrowseTests});

  final VoidCallback onBrowseTests;

  @override
  Widget build(BuildContext context) {
    return _ProductFoundationCard(
      icon: Icons.inventory_2_outlined,
      title: 'No test products on sale',
      description:
          'There are no active test products in the published catalogue right now. Free and already-accessible tests remain available under Tests.',
      actionLabel: 'Browse tests',
      onAction: onBrowseTests,
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
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final Color? iconColor;

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
            Icon(icon, size: 34, color: iconColor ?? scheme.primary),
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
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: onAction,
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(actionLabel!),
                  ),
                  if (secondaryActionLabel != null &&
                      onSecondaryAction != null)
                    TextButton(
                      onPressed: onSecondaryAction,
                      child: Text(secondaryActionLabel!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _testCountLabel(int count) => count == 1 ? '1 test' : '$count tests';

String formatStoreMoney(int minor, String currency) {
  if (minor == 0) return 'Free';
  final normalized = currency.trim().toUpperCase();
  final whole = minor ~/ 100;
  final remainder = minor % 100;
  final amount = remainder == 0
      ? '$whole'
      : '$whole.${remainder.toString().padLeft(2, '0')}';
  return switch (normalized) {
    'INR' => '₹$amount',
    'USD' => '\$$amount',
    'GBP' => '£$amount',
    'EUR' => '€$amount',
    _ => '$normalized $amount',
  };
}
