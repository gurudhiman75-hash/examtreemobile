import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.xl,
            ),
            children: [
              Text(
                'Choose what you are preparing for',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.35,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'ExamTree will use these choices to organise tests, free material and relevant updates. You can change them anytime.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _SelectionSummary(
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
              if (visibleExams.isEmpty)
                const _EmptySearch()
              else
                for (final family in catalogue.families) ...[
                  if (visibleExams.any((exam) => exam.familyId == family.id)) ...[
                    _FamilyHeader(
                      family: family,
                      visibleCount: visibleExams
                          .where((exam) => exam.familyId == family.id)
                          .length,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final exam in visibleExams.where(
                      (exam) => exam.familyId == family.id,
                    ))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _ExamChoiceCard(
                          exam: exam,
                          selected: _selectedIds.contains(exam.id),
                          limitReached: _selectedIds.length >= _maxSelected &&
                              !_selectedIds.contains(exam.id),
                          onChanged: (value) => _toggle(exam, value),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
            ],
          ),
        ),
        Material(
          color: scheme.surface,
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
                onPressed: _saving || !_dirty ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                ),
                child: _saving
                    ? const SizedBox.square(
                        dimension: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _selectedIds.isEmpty
                            ? 'Save without selected exams'
                            : 'Save ${_selectedIds.length} ${_selectedIds.length == 1 ? 'exam' : 'exams'}',
                        textAlign: TextAlign.center,
                      ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectionSummary extends StatelessWidget {
  const _SelectionSummary({
    required this.selected,
    required this.maximum,
    required this.onClear,
  });

  final int selected;
  final int maximum;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: AppSpacing.sm,
        runSpacing: AppSpacing.xs,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.bookmark_added_outlined,
                size: 20,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                '$selected of $maximum selected',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          if (onClear != null)
            TextButton(onPressed: onClear, child: const Text('Clear')),
        ],
      ),
    );
  }
}

class _FamilyHeader extends StatelessWidget {
  const _FamilyHeader({required this.family, required this.visibleCount});

  final ExamFamilyTarget family;
  final int visibleCount;

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
                family.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (family.description.isNotEmpty)
                Text(
                  family.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$visibleCount',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ExamChoiceCard extends StatelessWidget {
  const _ExamChoiceCard({
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
    final languageLabels = exam.languages
        .map((language) => language.code.toUpperCase())
        .where((code) => code.isNotEmpty)
        .take(3)
        .join(' · ');

    return Semantics(
      button: true,
      selected: selected,
      hint: limitReached && !selected
          ? 'Selection limit reached. Tap for details.'
          : selected
              ? 'Tap to remove this exam.'
              : 'Tap to add this exam.',
      child: Material(
        color: selected
            ? scheme.primaryContainer.withValues(alpha: 0.45)
            : scheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(
            color: selected ? scheme.primary : scheme.outlineVariant,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => onChanged(!selected),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selected,
                  onChanged: (value) => onChanged(value ?? false),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (exam.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          exam.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                            height: 1.35,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xs),
                      Wrap(
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xxs,
                        children: [
                          _MetaChip(
                            icon: exam.hasLiveTests
                                ? Icons.assignment_turned_in_outlined
                                : Icons.schedule_outlined,
                            label: exam.hasLiveTests
                                ? '${exam.liveTestCount} live ${exam.liveTestCount == 1 ? 'test' : 'tests'}'
                                : 'Tests coming later',
                          ),
                          if (languageLabels.isNotEmpty)
                            _MetaChip(
                              icon: Icons.translate_rounded,
                              label: languageLabels,
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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: 5,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) => Container(
        height: index == 0 ? 112 : 96,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text('No exams match that search.'),
        ],
      ),
    );
  }
}
