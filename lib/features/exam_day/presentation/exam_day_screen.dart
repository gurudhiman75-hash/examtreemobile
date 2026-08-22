import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/exam_day_mode.dart';
import 'providers/exam_day_providers.dart';

class ExamDayScreen extends ConsumerStatefulWidget {
  const ExamDayScreen({super.key});

  @override
  ConsumerState<ExamDayScreen> createState() => _ExamDayScreenState();
}

class _ExamDayScreenState extends ConsumerState<ExamDayScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _editTarget(ExamDayTarget? current) async {
    final target = await Navigator.of(context).push<ExamDayTarget>(
      MaterialPageRoute(
        builder: (context) => _ExamDayEditorScreen(initial: current),
      ),
    );
    if (target == null || !mounted) return;

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    try {
      final reminderReady = await ref.read(examDayControllerProvider).saveTarget(
            userId: user.uid,
            target: target,
          );
      ref.invalidate(examDayTargetProvider);
      if (mounted && target.remindersEnabled && !reminderReady) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Exam target saved, but notification permission is disabled.',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save the exam target.')),
        );
      }
    }
  }

  Future<void> _saveChecklist(ExamDayTarget target) async {
    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    try {
      await ref.read(examDayControllerProvider).saveChecklist(
            userId: user.uid,
            target: target.copyWith(updatedAt: DateTime.now()),
          );
      ref.invalidate(examDayTargetProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to update the checklist.')),
        );
      }
    }
  }

  Future<void> _toggleChecklist(
    ExamDayTarget target,
    ExamDayChecklistItem changed,
  ) async {
    final checklist = target.checklist
        .map((item) => item.id == changed.id ? changed : item)
        .toList(growable: false);
    await _saveChecklist(target.copyWith(checklist: checklist));
  }

  Future<void> _addChecklistItem(ExamDayTarget target) async {
    final controller = TextEditingController();
    final label = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add checklist item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 100,
          decoration: const InputDecoration(
            hintText: 'e.g. Bus ticket saved offline',
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (label == null || label.trim().isEmpty || !mounted) return;

    final custom = ExamDayChecklistItem(
      id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
      label: label.trim(),
      completed: false,
      isCustom: true,
    );
    await _saveChecklist(
      target.copyWith(checklist: [...target.checklist, custom]),
    );
  }

  Future<void> _removeChecklistItem(
    ExamDayTarget target,
    ExamDayChecklistItem item,
  ) async {
    if (!item.isCustom) return;
    await _saveChecklist(
      target.copyWith(
        checklist: target.checklist
            .where((candidate) => candidate.id != item.id)
            .toList(growable: false),
      ),
    );
  }

  Future<void> _deleteTarget() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove exam target?'),
        content: const Text(
          'This removes the local countdown, checklist and scheduled exam-day reminders from this device. Test history is unchanged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove target'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final user = ref.read(authStateChangesProvider).value;
    if (user == null) return;
    try {
      await ref.read(examDayControllerProvider).deleteTarget(user.uid);
      ref.invalidate(examDayTargetProvider);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to remove the exam target.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final targetAsync = ref.watch(examDayTargetProvider);
    final now = ref.watch(examDayClockProvider)();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam-Day Mode'),
        actions: [
          targetAsync.whenOrNull(
                data: (target) => target == null
                    ? null
                    : PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') _editTarget(target);
                          if (value == 'remove') _deleteTarget();
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Edit target'),
                          ),
                          PopupMenuItem(
                            value: 'remove',
                            child: Text('Remove target'),
                          ),
                        ],
                      ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: targetAsync.when(
        loading: () => const _ExamDayLoadingState(),
        error: (_, __) => _ExamDayErrorState(
          onRetry: () => ref.invalidate(examDayTargetProvider),
        ),
        data: (target) {
          if (target == null) {
            return _EmptyExamDay(onCreate: () => _editTarget(null));
          }
          return _ExamDayBody(
            target: target,
            now: now,
            onEdit: () => _editTarget(target),
            onToggleChecklist: (item) => _toggleChecklist(target, item),
            onAddChecklistItem: () => _addChecklistItem(target),
            onRemoveChecklistItem: (item) => _removeChecklistItem(target, item),
          );
        },
      ),
    );
  }
}

class _ExamDayLoadingState extends StatelessWidget {
  const _ExamDayLoadingState();

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainerHigh;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        Container(
          height: 270,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 130,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 220,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ],
    );
  }
}

class _ExamDayErrorState extends StatelessWidget {
  const _ExamDayErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.cloud_off_outlined,
                size: 30,
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Exam-Day Mode is unavailable',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try loading your saved target again.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry Exam-Day Mode'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyExamDay extends StatelessWidget {
  const _EmptyExamDay({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      key: const Key('exam-day-empty'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.tertiary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: _softShadow(),
          ),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.event_available_outlined,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Set one active exam target',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Keep a private countdown, logistics checklist and optional local reminders on this phone.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Set exam target'),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(54),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _InfoPanel(
          icon: Icons.verified_user_outlined,
          title: 'You provide the exam details',
          body:
              'ExamTree does not invent exam dates, reporting times, venues or readiness scores. Always verify saved details against the official notice or admit card.',
          background: AppColors.mintContainer,
          foreground: AppColors.onMintContainer,
        ),
      ],
    );
  }
}

class _ExamDayBody extends StatelessWidget {
  const _ExamDayBody({
    required this.target,
    required this.now,
    required this.onEdit,
    required this.onToggleChecklist,
    required this.onAddChecklistItem,
    required this.onRemoveChecklistItem,
  });

  final ExamDayTarget target;
  final DateTime now;
  final VoidCallback onEdit;
  final ValueChanged<ExamDayChecklistItem> onToggleChecklist;
  final VoidCallback onAddChecklistItem;
  final ValueChanged<ExamDayChecklistItem> onRemoveChecklistItem;

  @override
  Widget build(BuildContext context) {
    final stage = examDayStage(target, now);
    final reporting = target.reportingAt;
    final reportingPending = reporting != null && reporting.isAfter(now);

    return ListView(
      key: const Key('exam-day-scroll'),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xxl,
      ),
      children: [
        _CountdownHero(target: target, now: now, stage: stage),
        if (reportingPending) ...[
          const SizedBox(height: AppSpacing.md),
          _InfoPanel(
            icon: Icons.directions_walk_outlined,
            title: 'Reporting countdown',
            body:
                '${examCountdownLabel(reporting, now)} until your saved reporting time.',
            background: AppColors.skyContainer,
            foreground: AppColors.onSkyContainer,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        const _SectionHeader(
          title: 'Useful now',
          subtitle: 'Keep the last-mile actions focused and familiar.',
        ),
        const SizedBox(height: AppSpacing.sm),
        const _QuickActions(),
        const SizedBox(height: AppSpacing.xl),
        _SectionHeader(
          title: 'Saved logistics',
          subtitle: 'Only the details you entered for this target.',
          trailing: TextButton.icon(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit'),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _LogisticsCard(target: target),
        const SizedBox(height: AppSpacing.xl),
        _ChecklistCard(
          target: target,
          onToggle: onToggleChecklist,
          onAdd: onAddChecklistItem,
          onRemove: onRemoveChecklistItem,
        ),
        const SizedBox(height: AppSpacing.xl),
        _InfoPanel(
          icon: target.remindersEnabled
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          title: target.remindersEnabled
              ? 'Local reminders enabled'
              : 'Local reminders off',
          body: target.remindersEnabled
              ? 'ExamTree schedules inexact reminders about 24 hours and 2 hours before your saved reporting time, or exam time when reporting time is not set.'
              : 'You can enable optional local reminders when editing this target.',
          background: AppColors.primaryContainer,
          foreground: AppColors.onPrimaryContainer,
        ),
        const SizedBox(height: AppSpacing.sm),
        const _InfoPanel(
          icon: Icons.verified_user_outlined,
          title: 'Official instructions remain authoritative',
          body:
              'This checklist is a personal aid. Always use the official notice or admit card for reporting time, documents, permitted items and venue rules.',
          background: AppColors.mintContainer,
          foreground: AppColors.onMintContainer,
        ),
      ],
    );
  }
}

class _CountdownHero extends StatelessWidget {
  const _CountdownHero({
    required this.target,
    required this.now,
    required this.stage,
  });

  final ExamDayTarget target;
  final DateTime now;
  final ExamDayStage stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        examDayStageTitle(stage),
        style: theme.textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    return Container(
      key: const Key('exam-day-countdown'),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (largeText) ...[
            badge,
            const SizedBox(height: AppSpacing.md),
            Text(
              target.examName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
          ] else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    target.examName,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                badge,
              ],
            ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatDateTime(target.examAt),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            examCountdownLabel(target.examAt, now),
            style: theme.textTheme.displaySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            examDayGuidance(stage),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final actions = [
      FilledButton.tonalIcon(
        key: const Key('exam-day-quick-revision'),
        onPressed: () => context.push('/quick-revision?minutes=5'),
        icon: const Icon(Icons.bolt_rounded),
        label: const Text('5 min revision'),
      ),
      FilledButton.tonalIcon(
        onPressed: () => context.push('/daily'),
        icon: const Icon(Icons.auto_awesome_rounded),
        label: const Text('Daily Companion'),
      ),
      FilledButton.tonalIcon(
        onPressed: () => context.go('/exams'),
        icon: const Icon(Icons.assignment_outlined),
        label: const Text('Tests'),
      ),
    ];

    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < actions.length; index++) ...[
            actions[index],
            if (index != actions.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
        ],
      );
    }

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: actions,
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );

    if (trailing == null) return copy;
    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          copy,
          const SizedBox(height: AppSpacing.xs),
          trailing!,
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: copy),
        const SizedBox(width: AppSpacing.sm),
        trailing!,
      ],
    );
  }
}

class _LogisticsCard extends StatelessWidget {
  const _LogisticsCard({required this.target});

  final ExamDayTarget target;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            _LogisticsRow(
              icon: Icons.schedule_outlined,
              label: 'Exam',
              value: _formatDateTime(target.examAt),
            ),
            if (target.reportingAt != null) ...[
              const Divider(height: AppSpacing.lg),
              _LogisticsRow(
                icon: Icons.login_rounded,
                label: 'Reporting',
                value: _formatDateTime(target.reportingAt!),
              ),
            ],
            if (target.venue.trim().isNotEmpty) ...[
              const Divider(height: AppSpacing.lg),
              _LogisticsRow(
                icon: Icons.location_on_outlined,
                label: 'Venue note',
                value: target.venue.trim(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LogisticsRow extends StatelessWidget {
  const _LogisticsRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.5;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: AppColors.onPrimaryContainer),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                maxLines: largeText ? 4 : 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({
    required this.target,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
  });

  final ExamDayTarget target;
  final ValueChanged<ExamDayChecklistItem> onToggle;
  final VoidCallback onAdd;
  final ValueChanged<ExamDayChecklistItem> onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completed = target.completedChecklistCount;
    final total = target.checklist.length;
    final progress = total == 0 ? 0.0 : completed / total;

    return Material(
      key: const Key('exam-day-checklist'),
      color: theme.colorScheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Exam-day checklist',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'A personal logistics aid, not an academic readiness score.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mintContainer,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '$completed/$total',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.onMintContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              borderRadius: BorderRadius.circular(99),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (var index = 0; index < target.checklist.length; index++) ...[
              if (index != 0) const Divider(height: 1),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: target.checklist[index].completed,
                onChanged: (value) => onToggle(
                  target.checklist[index].copyWith(completed: value ?? false),
                ),
                title: Text(target.checklist[index].label),
                controlAffinity: ListTileControlAffinity.leading,
                secondary: target.checklist[index].isCustom
                    ? IconButton(
                        tooltip: 'Remove custom item',
                        onPressed: () => onRemove(target.checklist[index]),
                        icon: const Icon(Icons.delete_outline_rounded),
                      )
                    : null,
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add my own item'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoPanel extends StatelessWidget {
  const _InfoPanel({
    required this.icon,
    required this.title,
    required this.body,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  body,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: foreground,
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

class _ExamDayEditorScreen extends StatefulWidget {
  const _ExamDayEditorScreen({this.initial});

  final ExamDayTarget? initial;

  @override
  State<_ExamDayEditorScreen> createState() => _ExamDayEditorScreenState();
}

class _ExamDayEditorScreenState extends State<_ExamDayEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _venueController;
  late DateTime _examAt;
  DateTime? _reportingAt;
  late bool _remindersEnabled;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final initial = widget.initial;
    _nameController = TextEditingController(text: initial?.examName ?? '');
    _venueController = TextEditingController(text: initial?.venue ?? '');
    _examAt = initial?.examAt ?? now.add(const Duration(days: 30));
    _reportingAt = initial?.reportingAt;
    _remindersEnabled = initial?.remindersEnabled ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickExamDate() async {
    final today = DateTime.now();
    final first = DateTime(today.year, today.month, today.day);
    final current = _examAt.isBefore(first) ? first : _examAt;
    final date = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: first,
      lastDate: DateTime(today.year + 5, 12, 31),
    );
    if (date == null || !mounted) return;
    setState(() {
      _examAt = DateTime(
        date.year,
        date.month,
        date.day,
        _examAt.hour,
        _examAt.minute,
      );
      if (_reportingAt != null) {
        _reportingAt = DateTime(
          date.year,
          date.month,
          date.day,
          _reportingAt!.hour,
          _reportingAt!.minute,
        );
      }
    });
  }

  Future<void> _pickExamTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_examAt),
    );
    if (time == null || !mounted) return;
    setState(() {
      _examAt = DateTime(
        _examAt.year,
        _examAt.month,
        _examAt.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickReportingTime() async {
    final initial = _reportingAt == null
        ? TimeOfDay(
            hour: (_examAt.hour - 1).clamp(0, 23).toInt(),
            minute: _examAt.minute,
          )
        : TimeOfDay.fromDateTime(_reportingAt!);
    final time = await showTimePicker(context: context, initialTime: initial);
    if (time == null || !mounted) return;
    setState(() {
      _reportingAt = DateTime(
        _examAt.year,
        _examAt.month,
        _examAt.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final now = DateTime.now();
    if (!_examAt.isAfter(now)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a future exam date and time.')),
      );
      return;
    }
    if (_reportingAt != null && !_reportingAt!.isBefore(_examAt)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporting time must be before the exam time.'),
        ),
      );
      return;
    }

    Navigator.of(context).pop(
      ExamDayTarget(
        examName: _nameController.text.trim(),
        examAt: _examAt,
        reportingAt: _reportingAt,
        venue: _venueController.text.trim(),
        remindersEnabled: _remindersEnabled,
        checklist: widget.initial?.checklist ?? defaultExamDayChecklist,
        updatedAt: now,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initial == null ? 'Set exam target' : 'Edit exam target'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.xxl,
          ),
          children: [
            Text(
              'Save only the details you want available on this device.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              controller: _nameController,
              maxLength: 80,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Exam name',
                hintText: 'e.g. SSC CGL Tier I',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the exam name.'
                  : null,
            ),
            const SizedBox(height: AppSpacing.md),
            Material(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(22),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.calendar_month_outlined),
                    title: const Text('Exam date'),
                    subtitle: Text(_formatDate(_examAt)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickExamDate,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.schedule_outlined),
                    title: const Text('Exam time'),
                    subtitle: Text(_formatTime(_examAt)),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _pickExamTime,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.login_rounded),
                    title: const Text('Reporting time (optional)'),
                    subtitle: Text(
                      _reportingAt == null
                          ? 'Not set'
                          : _formatTime(_reportingAt!),
                    ),
                    trailing: _reportingAt == null
                        ? const Icon(Icons.add_rounded)
                        : IconButton(
                            tooltip: 'Clear reporting time',
                            onPressed: () => setState(() => _reportingAt = null),
                            icon: const Icon(Icons.close_rounded),
                          ),
                    onTap: _pickReportingTime,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _venueController,
              maxLength: 160,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Venue note (optional)',
                hintText:
                    'Save the venue or address exactly as you want to remember it',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Material(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(20),
              child: SwitchListTile(
                value: _remindersEnabled,
                onChanged: (value) =>
                    setState(() => _remindersEnabled = value),
                title: const Text('Exam-day reminders'),
                subtitle: const Text(
                  'Request local notifications about 24 hours and 2 hours before the saved reporting or exam time.',
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save exam target'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(54),
              ),
            ),
          ],
        ),
      ),
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

String _formatDate(DateTime value) {
  const months = [
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
  final local = value.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

String _formatDateTime(DateTime value) =>
    '${_formatDate(value)} • ${_formatTime(value)}';

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
