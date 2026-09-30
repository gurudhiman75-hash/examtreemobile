import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/learn_module_catalog.dart';

class LearnModulesSection extends StatelessWidget {
  const LearnModulesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Practice by subject',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.35,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Choose a module and continue at your own pace.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                'UNTIMED',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: .7,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = textScale > 1.35 || constraints.maxWidth < 350;
            if (stacked) {
              return Column(
                children: [
                  for (var index = 0; index < learnModules.length; index++) ...[
                    _ModuleCard(moduleIndex: index, horizontal: true),
                    if (index != learnModules.length - 1)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: learnModules.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisSpacing: AppSpacing.sm,
                childAspectRatio: 1.12,
              ),
              itemBuilder: (context, index) =>
                  _ModuleCard(moduleIndex: index),
            );
          },
        ),
      ],
    );
  }
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({
    required this.moduleIndex,
    this.horizontal = false,
  });

  final int moduleIndex;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final module = learnModules[moduleIndex];
    final style = _styleFor(module.id);

    final iconBox = Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: style.iconBackground,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(style.icon, color: style.iconForeground, size: 24),
    );

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          module.title,
          maxLines: horizontal ? 1 : 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            height: 1.15,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${module.submodules.length} areas',
              style: theme.textTheme.bodySmall?.copyWith(
                color: style.iconForeground,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.arrow_forward_rounded,
              size: 15,
              color: style.iconForeground,
            ),
          ],
        ),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [style.backgroundStart, style.backgroundEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: style.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.055),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: InkWell(
          key: Key('learn-module-${module.id}'),
          onTap: () => context.push(
            '/learn-module?module=${Uri.encodeQueryComponent(module.id)}',
          ),
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: horizontal
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      iconBox,
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: copy),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .72),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.chevron_right_rounded, size: 20),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          iconBox,
                          const Spacer(),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: .7),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.north_east_rounded,
                              size: 16,
                              color: style.iconForeground,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      copy,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  _ModuleStyle _styleFor(String id) {
    return switch (id) {
      'quant' => const _ModuleStyle(
          icon: Icons.calculate_rounded,
          iconForeground: Color(0xFF3730A3),
          iconBackground: Color(0xFFE0E7FF),
          backgroundStart: Color(0xFFF7F7FF),
          backgroundEnd: Color(0xFFEEF2FF),
          border: Color(0xFFE0E7FF),
        ),
      'reasoning' => const _ModuleStyle(
          icon: Icons.psychology_alt_rounded,
          iconForeground: Color(0xFF6D28D9),
          iconBackground: Color(0xFFEDE9FE),
          backgroundStart: Color(0xFFFBF8FF),
          backgroundEnd: Color(0xFFF5F3FF),
          border: Color(0xFFEDE9FE),
        ),
      'english' => const _ModuleStyle(
          icon: Icons.translate_rounded,
          iconForeground: Color(0xFF0369A1),
          iconBackground: Color(0xFFE0F2FE),
          backgroundStart: Color(0xFFF7FCFF),
          backgroundEnd: Color(0xFFF0F9FF),
          border: Color(0xFFE0F2FE),
        ),
      _ => const _ModuleStyle(
          icon: Icons.public_rounded,
          iconForeground: Color(0xFF047857),
          iconBackground: Color(0xFFD1FAE5),
          backgroundStart: Color(0xFFF7FFFB),
          backgroundEnd: Color(0xFFECFDF5),
          border: Color(0xFFD1FAE5),
        ),
    };
  }
}

class _ModuleStyle {
  const _ModuleStyle({
    required this.icon,
    required this.iconForeground,
    required this.iconBackground,
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.border,
  });

  final IconData icon;
  final Color iconForeground;
  final Color iconBackground;
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color border;
}
