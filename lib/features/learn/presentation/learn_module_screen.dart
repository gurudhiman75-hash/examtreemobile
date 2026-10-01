import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../data/learn_module_catalog.dart';
import '../domain/learn_practice_models.dart';

class LearnModuleScreen extends StatelessWidget {
  const LearnModuleScreen({super.key, required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context) {
    final module = learnModuleById(moduleId);
    if (module == null) {
      return const Scaffold(body: Center(child: Text('Module unavailable')));
    }
    final visual = _visualFor(module.id);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(module.title),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF10264A),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, AppSpacing.xxl),
        children: [
          _ModuleHero(module: module, visual: visual),
          const SizedBox(height: 18),
          _SectionHeader(
            title: 'Choose a topic area',
            subtitle: 'Open an area to continue learning and practice.',
            count: module.submodules.length,
          ),
          const SizedBox(height: 10),
          for (var index = 0; index < module.submodules.length; index++) ...[
            _SubmoduleCard(
              submodule: module.submodules[index],
              visual: visual,
              index: index,
            ),
            if (index != module.submodules.length - 1)
              const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  _ModuleVisual _visualFor(String id) {
    return switch (id) {
      'quant' => const _ModuleVisual(
          icon: Icons.calculate_rounded,
          accent: Color(0xFF3730A3),
          soft: Color(0xFFEFF1FF),
        ),
      'reasoning' => const _ModuleVisual(
          icon: Icons.psychology_alt_rounded,
          accent: Color(0xFF6D28D9),
          soft: Color(0xFFF4EEFF),
        ),
      'english' => const _ModuleVisual(
          icon: Icons.translate_rounded,
          accent: Color(0xFF0369A1),
          soft: Color(0xFFEAF7FF),
        ),
      _ => const _ModuleVisual(
          icon: Icons.public_rounded,
          accent: Color(0xFF047857),
          soft: Color(0xFFE8FAF2),
        ),
    };
  }
}

class _ModuleHero extends StatelessWidget {
  const _ModuleHero({required this.module, required this.visual});

  final LearnModuleDefinition module;
  final _ModuleVisual visual;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF031B3A),
            Color(0xFF063A70),
            Color(0xFF0B5D96),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF062D5C).withValues(alpha: .13),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            top: -30,
            child: Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(visual.icon, color: const Color(0xFFFFD36B)),
              ),
              const SizedBox(height: 12),
              Text(
                module.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.4,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                module.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: .84),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 13),
              Row(
                children: [
                  _HeroPill(
                    icon: Icons.grid_view_rounded,
                    label: '${module.submodules.length} areas',
                  ),
                  const SizedBox(width: 8),
                  const _HeroPill(
                    icon: Icons.schedule_rounded,
                    label: 'Untimed',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .11),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withValues(alpha: .1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFFD36B)),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.count,
  });

  final String title;
  final String subtitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF10264A),
                  fontWeight: FontWeight.w900,
                  letterSpacing: -.3,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF718096),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F6FA),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              color: const Color(0xFF42546A),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubmoduleCard extends StatelessWidget {
  const _SubmoduleCard({
    required this.submodule,
    required this.visual,
    required this.index,
  });

  final LearnSubmoduleDefinition submodule;
  final _ModuleVisual visual;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = submodule.available;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: available ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: available ? const Color(0xFFE3E9F1) : const Color(0xFFEDF1F5),
          ),
          boxShadow: available
              ? [
                  BoxShadow(
                    color: const Color(0xFF10264A).withValues(alpha: .045),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: InkWell(
          onTap: available
              ? () => context.push(
                    '/learn-submodule?id=${Uri.encodeQueryComponent(submodule.id)}',
                  )
              : null,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: available
                        ? visual.soft
                        : const Color(0xFFEEF2F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: available
                      ? Text(
                          '${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: visual.accent,
                            fontWeight: FontWeight.w900,
                          ),
                        )
                      : const Icon(
                          Icons.lock_outline_rounded,
                          size: 20,
                          color: Color(0xFF94A3B8),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submodule.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: const Color(0xFF162A48),
                          fontWeight: FontWeight.w900,
                          letterSpacing: -.15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        submodule.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF718096),
                          height: 1.35,
                        ),
                      ),
                      if (!available) ...[
                        const SizedBox(height: 5),
                        Text(
                          'Coming soon',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF9A7A35),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (available)
                  Icon(
                    Icons.chevron_right_rounded,
                    color: visual.accent,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModuleVisual {
  const _ModuleVisual({
    required this.icon,
    required this.accent,
    required this.soft,
  });

  final IconData icon;
  final Color accent;
  final Color soft;
}
