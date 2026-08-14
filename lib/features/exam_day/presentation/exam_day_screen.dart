import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
            content: Text('Exam target saved, but notification permission is disabled.'),
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
                          PopupMenuItem(value: 'edit', child: Text('Edit target')),
                          PopupMenuItem(value: 'remove', child: Text('Remove target')),
                        ],
                      ),
              ) ??
              const SizedBox.shrink(),
        ],
      ),
      body: targetAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: FilledButton.icon(
            onPressed: () => ref.invalidate(examDayTargetProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry Exam-Day Mode'),
          ),
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

class _EmptyExamDay extends StatelessWidget {
  const _EmptyExamDay({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.event_available_outlined,
          size: 72,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(height: 20),
        Text(
          'Set one active exam target',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Keep a private countdown, logistics checklist and optional local reminders on this phone. ExamTree does not invent exam dates or readiness scores.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          onPressed: onCreate,
          icon: const Icon(Icons.add_rounded),
          label: const Text('Set exam target'),
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
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _CountdownCard(target: target, now: now, stage: stage),
        const SizedBox(height: 16),
        if (reportingPending)
          _InfoBanner(
            icon: Icons.directions_walk_outlined,
            title: 'Reporting countdown',
            body: '${examCountdownLabel(reporting, now)} until your saved reporting time.',
          ),
        if (reportingPending) const SizedBox(height: 16),
        _ActionCard(target: target),
        const SizedBox(height: 16),
        _LogisticsCard(target: target, onEdit: onEdit),
        const SizedBox(height: 16),
        _ChecklistCard(
          target: target,
          onToggle: onToggleChecklist,
          onAdd: onAddChecklistItem,
          onRemove: onRemoveChecklistItem,
        ),
        const SizedBox(height: 16),
        _InfoBanner(
          icon: target.remindersEnabled
              ? Icons.notifications_active_outlined
              : Icons.notifications_off_outlined,
          title: target.remindersEnabled
              ? 'Local reminders enabled'
              : 'Local reminders off',
          body: target.remindersEnabled
              ? 'ExamTree schedules inexact reminders about 24 hours and 2 hours before your saved reporting time, or exam time when reporting time is not set.'
              : 'You can enable optional local reminders when editing this target.',
        ),
        const SizedBox(height: 16),
        const _InfoBanner(
          icon: Icons.verified_user_outlined,
          title: 'Official instructions remain authoritative',
          body: 'This checklist is a personal aid. Always use the official notice/admit card for reporting time, documents, permitted items and venue rules.',
        ),
      ],
    );
  }
}

class _CountdownCard extends StatelessWidget {
  const _CountdownCard({
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
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            target.examName,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDateTime(target.examAt),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            examCountdownLabel(target.examAt, now),
            style: theme.textTheme.displaySmall?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            examDayStageTitle(stage),
            style: theme.textTheme.titleMedium?.copyWith(
              color: scheme.onPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            examDayGuidance(stage),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onPrimary.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.target});

  final ExamDayTarget target;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Useful now',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogisticsCard extends StatelessWidget {
  const _LogisticsCard({required this.target, required this.onEdit});

  final ExamDayTarget target;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Saved logistics',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                TextButton(onPressed: onEdit, child: const Text('Edit')),
              ],
            ),
            const SizedBox(height: 4),
            _LogisticsRow(
              icon: Icons.schedule_outlined,
              label: 'Exam',
              value: _formatDateTime(target.examAt),
            ),
            if (target.reportingAt != null)
              _LogisticsRow(
                icon: Icons.login_rounded,
                label: 'Reporting',
                value: _formatDateTime(target.reportingAt!),
              ),
            if (target.venue.trim().isNotEmpty)
              _LogisticsRow(
                icon: Icons.location_on_outlined,
                label: 'Venue note',
                value: target.venue.trim(),
              ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 76,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
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
    final completed = target.completedChecklistCount;
    final total = target.checklist.length;
    final progress = total == 0 ? 0.0 : completed / total;
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Exam-day checklist',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ),
                  Text('$completed/$total'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Checklist completion is not an academic readiness score.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            const SizedBox(height: 8),
            ...target.checklist.map(
              (item) => CheckboxListTile(
                dense: true,
                value: item.completed,
                onChanged: (value) => onToggle(
                  item.copyWith(completed: value ?? false),
                ),
                title: Text(item.label),
                controlAffinity: ListTileControlAffinity.leading,
                secondary: item.isCustom
                    ? IconButton(
                        tooltip: 'Remove custom item',
                        onPressed: () => onRemove(item),
                        icon: const Icon(Icons.delete_outline_rounded),
                      )
                    : null,
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add my own item'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(body, style: theme.textTheme.bodyMedium?.copyWith(height: 1.4)),
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
            hour: (_examAt.hour - 1).clamp(0, 23),
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
        const SnackBar(content: Text('Reporting time must be before the exam time.')),
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
    return Scaffold(
      appBar: AppBar(title: Text(widget.initial == null ? 'Set exam target' : 'Edit exam target')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              maxLength: 80,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Exam name',
                hintText: 'e.g. SSC CGL Tier I',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Enter the exam name.'
                  : null,
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
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
            const SizedBox(height: 12),
            TextFormField(
              controller: _venueController,
              maxLength: 160,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Venue note (optional)',
                hintText: 'Save the venue/address exactly as you want to remember it',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _remindersEnabled,
              onChanged: (value) => setState(() => _remindersEnabled = value),
              title: const Text('Exam-day reminders'),
              subtitle: const Text(
                'Request local notifications about 24 hours and 2 hours before the saved reporting/exam time.',
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save exam target'),
            ),
          ],
        ),
      ),
    );
  }
}

String _formatDate(DateTime value) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final local = value.toLocal();
  return '${local.day} ${months[local.month - 1]} ${local.year}';
}

String _formatDateTime(DateTime value) => '${_formatDate(value)} • ${_formatTime(value)}';

String _formatTime(DateTime value) {
  final local = value.toLocal();
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  final period = local.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $period';
}
