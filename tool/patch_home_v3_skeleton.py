from pathlib import Path

path = Path('lib/features/home/presentation/home_screen_v3.dart')
source = path.read_text(encoding='utf-8')
marker = 'class _SkeletonCard extends StatelessWidget {'
if marker not in source:
    raise SystemExit('Skeleton marker not found')

replacement = r'''class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: 'Loading',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: scheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 150;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Container(
                        height: 16,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  width: double.infinity,
                  height: 18,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                FractionallySizedBox(
                  widthFactor: 0.68,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                  ),
                ),
                if (!compact) ...[
                  const Spacer(),
                  Container(
                    width: 126,
                    height: 42,
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
'''

path.write_text(source[: source.index(marker)] + replacement, encoding='utf-8')
