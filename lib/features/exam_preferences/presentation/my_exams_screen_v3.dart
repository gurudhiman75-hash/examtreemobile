import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/network_failure_view.dart';
import '../data/exam_preferences_repository.dart';
import '../domain/exam_preferences.dart';
import 'providers/exam_preferences_providers.dart';

class MyExamsScreen extends ConsumerWidget {
  const MyExamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(examPreferenceSnapshotProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My exams')),
      body: SafeArea(
        top: false,
        child: snapshotAsync.when(
          loading: () => const _LoadingState(),
          error: (error, stackTrace) => NetworkFailureView(
            error: error,
            fallbackTitle: 'Unable to load your exam catalogue',
            onRetry: () => ref.invalidate(examPreferenceSnapshotProvider),
          ),
          data: (snapshot) => _ExamPreferenceEditor(
            key: ValueKey(
              '${snapshot.catalogue.exams.length}:${snapshot.preferences.selectedExamIds.join(',')}',
            ),
            snapshot: snapshot,
          ),
        ),
      ),
    );
  }
}

class _ExamPreferenceEditor extends ConsumerStatefulWidget {
  const _ExamPreferenceEditor({super.key, required this.snapshot});

  final ExamPreferenceSnapshot snapshot;

  @override
  ConsumerState<_ExamPreferenceEditor> createState() =>
      _ExamPreferenceEditorState();
}

class _ExamPreferenceEditorState extends ConsumerState<_ExamPreferenceEditor> {
  late final TextEditingController _searchController;
  late final List<String> _originalIds;
  late final Set<String> _selectedIds;
  String _query = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _originalIds = List<String>.from(widget.snapshot.preferences.selectedExamIds);
    _selectedIds = _originalIds.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _maxSelected => widget.snapshot.catalogue.maxSelectedExams > 0
      ? widget.snapshot.catalogue.maxSelectedExams
      : widget.snapshot.preferences.maxSelectedExams;

  bool get _dirty {
    if (_selectedIds.length != _originalIds.length) return true;
    return _originalIds.any((id) => !_selectedIds.contains(id));
  }

  List<String> _orderedSelectedIds() {
    final original = _originalIds.where(_selectedIds.contains).toList();
    final originalSet = original.toSet();
    final newlySelected = widget.snapshot.catalogue.exams
        .where(
          (exam) =>
              _selectedIds.contains(exam.id) && !originalSet.contains(exam.id),
        )
        .map((exam) => exam.id);
    return [...original, ...newlySelected];
  }

  void _toggle(SelectableExamTarget exam, bool selected) {
    if (selected &&
        !_selectedIds.contains(exam.id) &&
        _selectedIds.length >= _maxSelected) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text('Choose up to $_maxSelected exams.')),
        );
      return;
    }

    setState(() {
      if (selected) {
        _selectedIds.add(exam.id);
      } else {
        _selectedIds.remove(exam.id);
      }
    });
  }

  Future<void> _save() async {
    if (_saving || !_dirty) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(examPreferencesRepositoryProvider)
          .savePreferences(_orderedSelectedIds());
      ref.invalidate(examPreferenceSnapshotProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('My exams updated.')),
      );
    } on ExamPreferencesException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to save your selected exams.')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final catalogue = widget.snapshot.catalogue;
    final query = _query.trim().toLowerCase();
    final familyById = {
      for (final family in catalogue.families) family.id: family,
    };
    final visibleExams = catalogue.exams.where((exam) {
      if (query.isEmpty) return true;
      final family = familyById[exam.familyId];
      return exam.name.toLowerCase().contains(query) ||
          exam.code.toLowerCase().contains(query) ||
          exam.description.toLowerCase().contains(query) ||
          (family?.name.toLowerCase().contains(query) ?? false);
    }).toList(growable: false);

    return Column(
      children: [
        Expanded(
          child: ListView(
            key: const Key('my-exams-scroll'),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              _PreparationHero(
                selected: _selectedIds.length,
                maximum: _maxSelected,
                onClear: _selectedIds.isEmpty
                    ? null
                    : () => setState(_selectedIds.clear),
              ),
              const SizedBox(height: AppSpacing.md),
              SearchBar(
                key: const Key('my-exams-search'),
                controller: _searchController,
                hintText: 'Search exams or exam families',
                leading: const Icon(Icons.search_rounded),
                trailing: [
                  if (_query.isNotEmpty)
                    IconButton(
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      query.isEmpty ? 'Available exam families' : 'Search results',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.25,
                      ),
                    ),
                  ),
                  Text(
                    '${visibleExams.length} ${visibleExams.length == 1 ? 'exam' : 'exams'}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (visibleExams.isEmpty)
                const _EmptySearch()
              else
                for (final family in catalogue.families) ...[
                  if (visibleExams.any((exam) => exam.familyId == family.id)) ...[
                    _FamilyGroup(
                      family: family,
                      exams: visibleExams
                          .where((exam) => exam.familyId == family.id)
                          .toList(growable: false),
                      selectedIds: _selectedIds,
                      maximum: _maxSelected,
                      onChanged: _toggle,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
            ],
          ),
        ),
        _SaveBar(
          selected: _selectedIds.length,
          dirty: _dirty,
          saving: _saving,
          onSave: _save,
        ),
      ],
    );
  }
}

class _PreparationHero extends StatelessWidget {
  const _PreparationHero({
    required this.selected,
    required this.maximum,
    required this.onClear,
  });

  final int selected;
  final int maximum;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final progress = maximum <= 0 ? 0.0 : (selected / maximum).clamp(0.0, 1.0);

    return Container(
      key: const Key('my-exams-summary'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
        ),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'YOUR PREPARATION',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Choose what you are preparing for',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.45,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'ExamTree will use these choices to organise tests, free material and relevant updates. You can change them anytime.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.onPrimaryContainer.withValues(alpha: 0.76),
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          if (textScale >= 1.5)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SelectionCount(selected: selected, maximum: maximum),
                if (onClear != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onClear,
                      child: const Text('Clear selection'),
                    ),
                  ),
                ],
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _SelectionCount(
                    selected: selected,
                    maximum: maximum,
                  ),
                ),
                if (onClear != null)
                  TextButton(
                    onPressed: onClear,
                    child: const Text('Clear'),
                  ),
              ],
            ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.72),
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionCount extends StatelessWidget {
  const _SelectionCount({required this.selected, required this.maximum});

  final int selected;
  final int maximum;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bookmark_added_outlined,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            '$selected of $maximum selected',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class _FamilyGroup extends StatelessWidget {
  const _FamilyGroup({
    required this.family,
    required this.exams,
    required this.selectedIds,
    required this.maximum,
    required this.onChanged,
  });

  final ExamFamilyTarget family;
  final List<SelectableExamTarget> exams;
  final Set<String> selectedIds;
  final int maximum;
  final void Function(SelectableExamTarget exam, bool selected) onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Material(
      key: Key('my-exams-family-${family.id}'),
      color: scheme.surfaceContainerLowest,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.skyContainer,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.school_outlined,
                    color: AppColors.sky,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        family.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (family.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          family.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${exams.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var index = 0; index < exams.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: AppSpacing.md,
                endIndent: AppSpacing.md,
                color: scheme.outlineVariant.withValues(alpha: 0.7),
              ),
            _ExamChoiceRow(
              exam: exams[index],
              selected: selectedIds.contains(exams[index].id),
              limitReached: selectedIds.length >= maximum &&
                  !selectedIds.contains(exams[index].id),
              onChanged: (value) => onChanged(exams[index], value),
            ),
          ],
        ],
      ),
    );
  }
}

class _ExamChoiceRow extends StatelessWidget {
  const _ExamChoiceRow({
    required this.exam,
    required this.selected,
    required this.limitReached,
    required this.onChanged,
  });

  final SelectableExamTarget exam;
  final bool selected;
  final bool limitReached;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final languageLabels = exam.languages
        .map((language) => language.code.toUpperCase())
        .where((code) => code.isNotEmpty)
        .take(3)
        .join(' · ');

    final status = _AvailabilityPill(
      icon: exam.hasLiveTests
          ? Icons.assignment_turned_in_outlined
          : Icons.schedule_outlined,
      label: exam.hasLiveTests
          ? '${exam.liveTestCount} live ${exam.liveTestCount == 1 ? 'test' : 'tests'}'
          : 'Tests coming later',
      accent: exam.hasLiveTests ? AppColors.mint : AppColors.amber,
      background: exam.hasLiveTests
          ? AppColors.mintContainer
          : AppColors.amberContainer,
      foreground: exam.hasLiveTests
          ? AppColors.onMintContainer
          : AppColors.onAmberContainer,
    );

    return Semantics(
      button: true,
      selected: selected,
      hint: limitReached && !selected
          ? 'Selection limit reached. Tap for details.'
          : selected
              ? 'Tap to remove this exam.'
              : 'Tap to add this exam.',
      child: Material(
        key: Key('my-exams-choice-${exam.id}'),
        color: selected
            ? AppColors.primaryContainer.withValues(alpha: 0.72)
            : Colors.transparent,
        child: InkWell(
          onTap: () => onChanged(!selected),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.primary
                        : scheme.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selected ? Icons.check_rounded : Icons.add_rounded,
                    size: 21,
                    color: selected
                        ? Colors.white
                        : limitReached
                            ? scheme.outline
                            : AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: selected
                              ? AppColors.onPrimaryContainer
                              : scheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (exam.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          exam.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      if (textScale >= 1.5)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            status,
                            if (languageLabels.isNotEmpty) ...[
                              const SizedBox(height: AppSpacing.xs),
                              _AvailabilityPill(
                                icon: Icons.translate_rounded,
                                label: languageLabels,
                                accent: AppColors.sky,
                                background: AppColors.skyContainer,
                                foreground: AppColors.onSkyContainer,
                              ),
                            ],
                          ],
                        )
                      else
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            status,
                            if (languageLabels.isNotEmpty)
                              _AvailabilityPill(
                                icon: Icons.translate_rounded,
                                label: languageLabels,
                                accent: AppColors.sky,
                                background: AppColors.skyContainer,
                                foreground: AppColors.onSkyContainer,
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill({
    required this.icon,
    required this.label,
    required this.accent,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color accent;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: accent),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  const _SaveBar({
    required this.selected,
    required this.dirty,
    required this.saving,
    required this.onSave,
  });

  final int selected;
  final bool dirty;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      elevation: 8,
      shadowColor: AppColors.shadow.withValues(alpha: 0.08),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: FilledButton(
            key: const Key('my-exams-save'),
            onPressed: saving || !dirty ? null : onSave,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
            ),
            child: saving
                ? const SizedBox.square(
                    dimension: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    selected == 0
                        ? 'Save without selected exams'
                        : 'Save $selected ${selected == 1 ? 'exam' : 'exams'}',
                    textAlign: TextAlign.center,
                  ),
          ),
        ),
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Container(
          height: 205,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          height: 54,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (var index = 0; index < 3; index++) ...[
          Container(
            height: 136,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No exams match that search.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Try the exam name, code, or exam family.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
