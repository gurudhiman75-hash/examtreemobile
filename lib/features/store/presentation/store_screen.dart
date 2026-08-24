import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/store_payment_launcher.dart';
import '../data/store_repository.dart';
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

  Future<void> _openCheckout(StoreProduct product) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => _CheckoutSheet(product: product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = ref.watch(storeProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Store')),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(storeProductsProvider);
            try {
              await ref.read(storeProductsProvider.future);
            } catch (_) {
              // The catalogue renders its own recoverable state.
            }
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              const _StoreHero(),
              const SizedBox(height: AppSpacing.lg),
              _SectionSwitch(
                value: _section,
                onChanged: (value) => setState(() => _section = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_section == StoreSection.tests)
                _TestSeriesCatalog(
                  key: const Key('store-test-series'),
                  products: products,
                  onRetry: () => ref.invalidate(storeProductsProvider),
                  onBrowseTests: () => context.go('/exams'),
                  onCheckout: _openCheckout,
                )
              else
                const _FoundationState(
                  key: Key('store-batches'),
                  icon: Icons.school_outlined,
                  title: 'Batches are not published yet',
                  description:
                      'ExamTree will show batches here only after real batch products, schedules and access rules are available.',
                ),
              const SizedBox(height: AppSpacing.lg),
              const _TrustNotice(),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreHero extends StatelessWidget {
  const _StoreHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final icon = Container(
      width: 58,
      height: 58,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(19),
      ),
      child: const Icon(
        Icons.shopping_bag_outlined,
        color: Colors.white,
        size: 28,
      ),
    );
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREPARATION STORE',
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.white.withValues(alpha: 0.76),
            fontWeight: FontWeight.w900,
            letterSpacing: 0.65,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          'Preparation products',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.45,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Published test series and future batches, clearly separated.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.82),
            height: 1.35,
          ),
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow(),
      ),
      child: largeText
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(height: AppSpacing.md),
                copy,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                icon,
                const SizedBox(width: AppSpacing.md),
                Expanded(child: copy),
              ],
            ),
    );
  }
}

class _SectionSwitch extends StatelessWidget {
  const _SectionSwitch({required this.value, required this.onChanged});

  final StoreSection value;
  final ValueChanged<StoreSection> onChanged;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final tests = _SectionButton(
      label: 'Test series',
      icon: Icons.assignment_turned_in_outlined,
      selected: value == StoreSection.tests,
      onTap: () => onChanged(StoreSection.tests),
    );
    final batches = _SectionButton(
      label: 'Batches',
      icon: Icons.school_outlined,
      selected: value == StoreSection.batches,
      onTap: () => onChanged(StoreSection.batches),
    );

    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: largeText
            ? Column(
                children: [
                  tests,
                  const SizedBox(height: 4),
                  batches,
                ],
              )
            : Row(
                children: [
                  Expanded(child: tests),
                  const SizedBox(width: 4),
                  Expanded(child: batches),
                ],
              ),
      ),
    );
  }
}

class _SectionButton extends StatelessWidget {
  const _SectionButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.surfaceContainerLowest
          : Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
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
    required this.onCheckout,
  });

  final AsyncValue<List<StoreProduct>> products;
  final VoidCallback onRetry;
  final VoidCallback onBrowseTests;
  final ValueChanged<StoreProduct> onCheckout;

  @override
  Widget build(BuildContext context) {
    return products.when(
      loading: () => const _StoreLoadingState(),
      error: (error, stackTrace) => _FoundationState(
        icon: Icons.cloud_off_outlined,
        iconColor: Theme.of(context).colorScheme.error,
        title: 'Store catalogue unavailable',
        description: 'ExamTree could not load published products right now.',
        actionLabel: 'Retry',
        onAction: onRetry,
        secondaryActionLabel: 'Browse tests',
        onSecondaryAction: onBrowseTests,
      ),
      data: (items) {
        if (items.isEmpty) {
          return _FoundationState(
            icon: Icons.inventory_2_outlined,
            title: 'No test products on sale',
            description:
                'There are no active products in the published catalogue right now. Free and already-accessible tests remain available under Tests.',
            actionLabel: 'Browse tests',
            onAction: onBrowseTests,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CatalogHeading(count: items.length),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < items.length; index++) ...[
              _ProductCard(
                product: items[index],
                onBrowseTests: onBrowseTests,
                onCheckout: () => onCheckout(items[index]),
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

class _CatalogHeading extends StatelessWidget {
  const _CatalogHeading({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Test series',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          '$count published ${count == 1 ? 'product' : 'products'}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onBrowseTests,
    required this.onCheckout,
  });

  final StoreProduct product;
  final VoidCallback onBrowseTests;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final facts = <Widget>[
      _ProductFact(
        icon: Icons.quiz_outlined,
        label: _testCountLabel(product.testCount),
        expanded: largeText,
      ),
      if (product.validityDays != null)
        _ProductFact(
          icon: Icons.event_available_outlined,
          label: '${product.validityDays} days access',
          expanded: largeText,
        ),
    ];

    final actions = <Widget>[
      FilledButton.icon(
        key: Key('store-pay-${product.id}'),
        onPressed: product.salePriceMinor > 0 ? onCheckout : null,
        icon: const Icon(Icons.lock_outline_rounded),
        label: Text(product.salePriceMinor > 0 ? 'Pay securely' : 'Included free'),
      ),
      OutlinedButton.icon(
        onPressed: onBrowseTests,
        icon: const Icon(Icons.arrow_forward_rounded),
        label: const Text('View tests'),
      ),
    ];

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      elevation: 1,
      shadowColor: AppColors.shadow.withValues(alpha: 0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: AppColors.primary,
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
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      if (product.description.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          product.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
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
            if (largeText)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < facts.length; index++) ...[
                    facts[index],
                    if (index != facts.length - 1)
                      const SizedBox(height: AppSpacing.xs),
                  ],
                ],
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: facts,
              ),
            const SizedBox(height: AppSpacing.lg),
            _ProductPrice(product: product),
            const SizedBox(height: AppSpacing.md),
            if (largeText)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  actions[0],
                  const SizedBox(height: AppSpacing.sm),
                  actions[1],
                ],
              )
            else
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: actions,
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSheet extends ConsumerStatefulWidget {
  const _CheckoutSheet({required this.product});

  final StoreProduct product;

  @override
  ConsumerState<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends ConsumerState<_CheckoutSheet> {
  late final String _idempotencyKey;
  bool _busy = false;
  bool _success = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    final nonce = Random.secure().nextInt(1 << 32).toRadixString(16);
    _idempotencyKey =
        'mobile-${widget.product.id}-${DateTime.now().microsecondsSinceEpoch}-$nonce';
  }

  Future<void> _pay() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });

    try {
      final order = await ref.read(storeRepositoryProvider).createCheckoutOrder(
            productId: widget.product.id,
            idempotencyKey: _idempotencyKey,
          );
      if (!mounted) return;

      final result = await ref.read(storePaymentLauncherProvider).open(
            order: order,
            product: widget.product,
            email: FirebaseAuth.instance.currentUser?.email,
          );
      if (!mounted) return;

      switch (result.outcome) {
        case StorePaymentOutcome.success:
          setState(() {
            _success = true;
            _message = null;
          });
        case StorePaymentOutcome.cancelled:
          setState(() {
            _message = 'Payment was cancelled. No access was changed.';
          });
        case StorePaymentOutcome.failed:
          setState(() {
            _message =
                'Payment could not be completed. No access was changed. Please try again.';
          });
      }
    } on StoreCheckoutException catch (error) {
      if (mounted) setState(() => _message = error.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _message = 'Payment could not be started. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = widget.product;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xs,
        AppSpacing.lg,
        AppSpacing.lg + bottomInset,
      ),
      child: _success
          ? _CheckoutSuccess(
              onViewTests: () {
                Navigator.of(context).pop();
                context.go('/exams');
              },
              onClose: () => Navigator.of(context).pop(),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure checkout',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  product.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _CheckoutSummary(product: product),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Razorpay handles the payment screen. ExamTree unlocks paid tests only after secure server confirmation.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                if (_message != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _message!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    key: const Key('store-checkout-confirm'),
                    onPressed: _busy ? null : _pay,
                    icon: _busy
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_outline_rounded),
                    label: Text(_busy ? 'Starting payment…' : 'Continue to payment'),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
    );
  }
}

class _CheckoutSummary extends StatelessWidget {
  const _CheckoutSummary({required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SummaryRow(label: 'Tests', value: _testCountLabel(product.testCount)),
          if (product.validityDays != null) ...[
            const SizedBox(height: AppSpacing.sm),
            _SummaryRow(
              label: 'Access',
              value: '${product.validityDays} days',
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Divider(color: theme.colorScheme.outlineVariant),
          const SizedBox(height: AppSpacing.sm),
          _SummaryRow(
            label: 'Total',
            value: formatStoreMoney(product.salePriceMinor, product.currency),
            strong: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: (strong ? theme.textTheme.titleMedium : theme.textTheme.bodyMedium)
              ?.copyWith(fontWeight: strong ? FontWeight.w900 : FontWeight.w700),
        ),
      ],
    );
  }
}

class _CheckoutSuccess extends StatelessWidget {
  const _CheckoutSuccess({required this.onViewTests, required this.onClose});

  final VoidCallback onViewTests;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 58,
          height: 58,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.mintContainer,
            borderRadius: BorderRadius.circular(19),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.onMintContainer,
            size: 30,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Payment submitted',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Razorpay reported a successful payment. Access is granted only after ExamTree receives secure server confirmation, so newly paid tests may take a moment to appear.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onViewTests,
            child: const Text('View tests'),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(onPressed: onClose, child: const Text('Close')),
        ),
      ],
    );
  }
}

class _ProductPrice extends StatelessWidget {
  const _ProductPrice({required this.product});

  final StoreProduct product;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatStoreMoney(product.salePriceMinor, product.currency),
          style: theme.textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        if (product.hasCanonicalDiscount)
          Text(
            formatStoreMoney(product.listPriceMinor, product.currency),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}

class _ProductFact extends StatelessWidget {
  const _ProductFact({
    required this.icon,
    required this.label,
    this.expanded = false,
  });

  final IconData icon;
  final String label;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Row(
      mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        if (expanded)
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          )
        else
          Flexible(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );

    return Container(
      width: expanded ? double.infinity : null,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(expanded ? 16 : 999),
      ),
      child: row,
    );
  }
}

class _TrustNotice extends StatelessWidget {
  const _TrustNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.mintContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: AppColors.onMintContainer,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Prices and availability come from the published ExamTree catalogue. Paid checkout opens in Razorpay, and access is granted only after secure server confirmation.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.onMintContainer,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FoundationState extends StatelessWidget {
  const _FoundationState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(
              icon,
              size: 27,
              color: iconColor ?? theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                FilledButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
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
    );
  }
}

class _StoreLoadingState extends StatelessWidget {
  const _StoreLoadingState();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    return Column(
      children: [
        for (var index = 0; index < 2; index++) ...[
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          if (index == 0) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

List<BoxShadow> _softShadow() => [
      BoxShadow(
        color: AppColors.shadow.withValues(alpha: 0.055),
        blurRadius: 22,
        offset: const Offset(0, 8),
      ),
    ];

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
