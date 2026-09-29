import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
        Text(
          'Choose what to learn',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Practice by subject area, get instant explanations, and continue where you left off.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = textScale > 1.35 || constraints.maxWidth < 350;
            if (stacked) {
              return Column(
                children: [
                  for (var index = 0; index < learnModules.length; index++) ...[
                    _ModuleCard(
                      moduleIndex: index,
                      horizontal: true,
                    ),
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
                childAspectRatio: 1.05,
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
    final icon = switch (module.id) {
      'quant' => Icons.calculate_rounded,
      'reasoning' => Icons.psychology_alt_rounded,
      'english' => Icons.translate_rounded,
      _ => Icons.public_rounded,
    };

    final iconBox = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        icon,
        color: theme.colorScheme.onPrimaryContainer,
      ),
    );

    final copy = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          module.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${module.submodules.length} areas',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        key: Key('learn-module-${module.id}'),
        onTap: () => context.push(
          '/learn-module?module=${Uri.encodeQueryComponent(module.id)}',
        ),
        borderRadius: BorderRadius.circular(20),
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
                    const Icon(Icons.chevron_right_rounded),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    iconBox,
                    const Spacer(),
                    copy,
                  ],
                ),
        ),
      ),
    );
  }
}
