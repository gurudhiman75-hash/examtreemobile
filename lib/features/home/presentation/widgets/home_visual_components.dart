import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class HomeActionMetadata {
  const HomeActionMetadata({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

class HomeModuleShell extends StatelessWidget {
  const HomeModuleShell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.lg),
    this.color,
    this.gradient,
    this.borderColor,
    this.borderRadius = AppSpacing.radiusXl,
    this.boxShadow,
    this.onTap,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;
  final Color? borderColor;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(borderRadius);
    final content = Padding(padding: padding, child: child);

    return Semantics(
      container: true,
      label: semanticLabel,
      button: onTap != null,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: gradient == null
                ? color ?? theme.colorScheme.surfaceContainerLow
                : null,
            gradient: gradient,
            borderRadius: radius,
            border: Border.all(
              color: borderColor ?? theme.colorScheme.outlineVariant,
            ),
            boxShadow: boxShadow,
          ),
          child: onTap == null
              ? content
              : InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  child: content,
                ),
        ),
      ),
    );
  }
}

class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final action = actionLabel != null && onAction != null
        ? TextButton(onPressed: onAction, child: Text(actionLabel!))
        : null;

    return Semantics(
      container: true,
      header: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textScale = MediaQuery.textScalerOf(context).scale(1);
          final stackAction = constraints.maxWidth < 300 || textScale > 1.5;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
          );

          if (action == null) return copy;
          if (stackAction) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                copy,
                const SizedBox(height: AppSpacing.xs),
                action,
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: copy),
              const SizedBox(width: AppSpacing.sm),
              action,
            ],
          );
        },
      ),
    );
  }
}

class LearningActionCard extends StatelessWidget {
  const LearningActionCard({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
    this.metadata = const [],
    this.secondaryIcon,
    this.secondaryTooltip,
    this.onSecondaryAction,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;
  final List<HomeActionMetadata> metadata;
  final IconData? secondaryIcon;
  final String? secondaryTooltip;
  final VoidCallback? onSecondaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onPrimary = theme.colorScheme.onPrimary;

    return HomeModuleShell(
      semanticLabel: '$eyebrow. $title. $description',
      gradient: LinearGradient(
        colors: [
          theme.colorScheme.primary,
          Color.lerp(
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
            0.38,
          )!,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderColor: Colors.transparent,
      boxShadow: [
        BoxShadow(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ],
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
                  color: onPrimary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: onPrimary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      eyebrow.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: onPrimary.withValues(alpha: 0.78),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      title,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: onPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: onPrimary.withValues(alpha: 0.88),
              height: 1.45,
            ),
          ),
          if (metadata.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: metadata
                  .map(
                    (item) => _MetadataChip(
                      icon: item.icon,
                      label: item.label,
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          LayoutBuilder(
            builder: (context, constraints) {
              final textScale = MediaQuery.textScalerOf(context).scale(1);
              final stackButtons =
                  constraints.maxWidth < 290 || textScale > 1.5;
              final primary = FilledButton.icon(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: onPrimary,
                  foregroundColor: theme.colorScheme.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                ),
                icon: Icon(icon),
                label: Text(actionLabel),
              );
              final secondary = onSecondaryAction != null &&
                      secondaryIcon != null
                  ? IconButton(
                      tooltip: secondaryTooltip,
                      onPressed: onSecondaryAction,
                      constraints: const BoxConstraints(
                        minWidth: 48,
                        minHeight: 48,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: onPrimary.withValues(alpha: 0.14),
                        foregroundColor: onPrimary,
                      ),
                      icon: Icon(secondaryIcon),
                    )
                  : null;

              if (stackButtons) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    primary,
                    if (secondary != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Align(alignment: Alignment.centerLeft, child: secondary),
                    ],
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: primary),
                  if (secondary != null) ...[
                    const SizedBox(width: AppSpacing.sm),
                    secondary,
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = theme.colorScheme.onPrimary;
    final maxWidth = math.max(
      120.0,
      MediaQuery.sizeOf(context).width - (AppSpacing.lg * 2),
    );
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: foreground.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompactMetric extends StatelessWidget {
  const CompactMetric({
    super.key,
    required this.value,
    required this.label,
    this.icon,
  });

  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: theme.colorScheme.primary),
            const SizedBox(height: AppSpacing.xs),
          ],
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class HorizontalContentRail extends StatefulWidget {
  const HorizontalContentRail({
    super.key,
    required this.children,
    required this.height,
    required this.semanticLabel,
    this.minItemWidth = 248,
    this.maxItemWidth = 328,
  });

  final List<Widget> children;
  final double height;
  final String semanticLabel;
  final double minItemWidth;
  final double maxItemWidth;

  @override
  State<HorizontalContentRail> createState() => _HorizontalContentRailState();
}

class _HorizontalContentRailState extends State<HorizontalContentRail> {
  final ScrollController _controller = ScrollController();
  double _step = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _snapToNearest(bool disableAnimations) {
    if (!_controller.hasClients || _step <= 0) return;
    final position = _controller.position;
    final target = ((_controller.offset / _step).round() * _step)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if ((target - _controller.offset).abs() < 0.5) return;
    if (disableAnimations) {
      _controller.jumpTo(target);
      return;
    }
    _controller.animateTo(
      target,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Semantics(
      container: true,
      label: widget.semanticLabel,
      explicitChildNodes: true,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final availableWidth = constraints.maxWidth;
          final targetWidth = availableWidth >= 720
              ? availableWidth * 0.46
              : availableWidth * 0.82;
          final itemWidth = targetWidth
              .clamp(widget.minItemWidth, widget.maxItemWidth)
              .toDouble();
          _step = itemWidth + AppSpacing.md;
          final endPadding = math.max(0.0, availableWidth - itemWidth);

          return SizedBox(
            height: widget.height,
            child: NotificationListener<ScrollEndNotification>(
              onNotification: (notification) {
                _snapToNearest(disableAnimations);
                return false;
              },
              child: ListView.separated(
                controller: _controller,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                padding: EdgeInsets.only(right: endPadding),
                itemCount: widget.children.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) => Semantics(
                  label: 'Item ${index + 1} of ${widget.children.length}',
                  child: SizedBox(
                    width: itemWidth,
                    child: widget.children[index],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

enum HomeSkeletonVariant { action, metrics, rail }

class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({
    super.key,
    required this.height,
    this.variant = HomeSkeletonVariant.action,
  });

  final double height;
  final HomeSkeletonVariant variant;

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) {
      _controller
        ..stop()
        ..value = 0.45;
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: 'Loading content',
      child: ExcludeSemantics(
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final color = Color.lerp(
                theme.colorScheme.surfaceContainerLow,
                theme.colorScheme.surfaceContainerHighest,
                _controller.value,
              )!;
              return HomeModuleShell(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: SizedBox(
                  height: widget.height - (AppSpacing.md * 2),
                  child: _SkeletonBody(
                    color: color,
                    variant: widget.variant,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SkeletonBody extends StatelessWidget {
  const _SkeletonBody({required this.color, required this.variant});

  final Color color;
  final HomeSkeletonVariant variant;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusMd);
    Widget block({double? width, required double height}) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: color, borderRadius: radius),
        );

    switch (variant) {
      case HomeSkeletonVariant.metrics:
        return Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == 2 ? 0 : AppSpacing.sm,
                ),
                child: block(height: double.infinity),
              ),
            ),
          ),
        );
      case HomeSkeletonVariant.rail:
        return Row(
          children: [
            Expanded(flex: 4, child: block(height: double.infinity)),
            const SizedBox(width: AppSpacing.md),
            Expanded(flex: 1, child: block(height: double.infinity)),
          ],
        );
      case HomeSkeletonVariant.action:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                block(width: 48, height: 48),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: block(height: 48)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            block(height: 16),
            const SizedBox(height: AppSpacing.sm),
            FractionallySizedBox(
              widthFactor: 0.68,
              child: block(height: 16),
            ),
            const Spacer(),
            block(height: 48),
          ],
        );
    }
  }
}

class HomeReveal extends StatelessWidget {
  const HomeReveal({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (disableAnimations) return child;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 10 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

enum SyncStateBannerTone { info, warning, success }

class SyncStateBanner extends StatelessWidget {
  const SyncStateBanner({
    super.key,
    required this.message,
    required this.tone,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final SyncStateBannerTone tone;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, background, foreground) = switch (tone) {
      SyncStateBannerTone.info => (
          Icons.cloud_sync_outlined,
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
        ),
      SyncStateBannerTone.warning => (
          Icons.cloud_off_outlined,
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
        ),
      SyncStateBannerTone.success => (
          Icons.cloud_done_outlined,
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
        ),
    };

    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null)
              TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ),
      ),
    );
  }
}

class FeatureUnavailableCard extends StatelessWidget {
  const FeatureUnavailableCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return HomeModuleShell(
      semanticLabel: '$title. $description',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
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
