import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/result_model.dart';
import '../../../shared/widgets/skeleton.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../domain/question_bookmark.dart';
import '../../../l10n/l10n.dart';
import 'providers/bookmark_providers.dart';

const _ink = Color(0xFF10264A);
const _muted = Color(0xFF5F6F82);
const _border = Color(0xFFE4E9F1);
const _navy = Color(0xFF0B3A6F);
const _page = Color(0xFFF7F7F1);
const _correct = Color(0xFF15806C);

class BookmarksScreen extends ConsumerStatefulWidget {
  const BookmarksScreen({super.key});

  @override
  ConsumerState<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends ConsumerState<BookmarksScreen> {
  String? _section;

  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(questionBookmarksProvider);
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        title: Text(context.l10n.bookmarksTitle),
        backgroundColor: _page,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
      ),
      body: bookmarks.when(
        loading: () => const _BookmarksLoading(),
        error: (_, _) => const _BookmarksEmpty(),
        data: (items) {
          if (items.isEmpty) return const _BookmarksEmpty();
          final sections = {for (final item in items) item.section}.toList()
            ..sort();
          final selected = sections.contains(_section) ? _section : null;
          final visible = selected == null
              ? items
              : items.where((item) => item.section == selected).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              Text(
                context.l10n.bookmarksCount(items.length),
                style: const TextStyle(
                  color: _muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (sections.length > 1) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _SectionChip(
                        label: context.l10n.bookmarksAll,
                        selected: selected == null,
                        onTap: () => setState(() => _section = null),
                      ),
                      for (final section in sections)
                        _SectionChip(
                          label: section,
                          selected: selected == section,
                          onTap: () => setState(() => _section = section),
                        ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              for (final item in visible) ...[
                _BookmarkCard(bookmark: item),
                const SizedBox(height: 10),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  const _SectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: _navy,
        side: BorderSide(color: selected ? _navy : const Color(0xFFDCE5EF)),
        labelStyle: TextStyle(
          color: selected ? Colors.white : _ink,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _BookmarkCard extends ConsumerWidget {
  const _BookmarkCard({required this.bookmark});

  final QuestionBookmark bookmark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    final question = localizeResultQuestion(bookmark.question, language);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: ValueKey('bookmark-${bookmark.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BookmarkDetailScreen(bookmarkId: bookmark.id),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                bookmark.section.toUpperCase(),
                style: const TextStyle(
                  color: _muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                question.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _ink,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                [
                  if (bookmark.testName.trim().isNotEmpty) bookmark.testName,
                  _savedLabel(context, bookmark.savedAt),
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookmarkDetailScreen extends ConsumerWidget {
  const BookmarkDetailScreen({super.key, required this.bookmarkId});

  final String bookmarkId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(questionBookmarksProvider).value ?? const [];
    final bookmark = items.where((item) => item.id == bookmarkId).firstOrNull;
    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        title: Text(context.l10n.savedQuestion),
        backgroundColor: _page,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (bookmark != null)
            IconButton(
              key: const Key('bookmark-remove'),
              tooltip: context.l10n.removeBookmark,
              icon: const Icon(Icons.bookmark_remove_outlined),
              onPressed: () async {
                await ref
                    .read(questionBookmarksProvider.notifier)
                    .remove(bookmark.id);
                if (context.mounted) Navigator.of(context).maybePop();
              },
            ),
        ],
      ),
      body: bookmark == null
          ? _BookmarksEmpty(message: context.l10n.bookmarkRemoved)
          : _QuestionBody(
              bookmark: bookmark,
              question: localizeResultQuestion(bookmark.question, language),
            ),
    );
  }
}

class _QuestionBody extends StatelessWidget {
  const _QuestionBody({required this.bookmark, required this.question});

  final QuestionBookmark bookmark;
  final ResultQuestionReview question;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      children: [
        Text(
          [
            bookmark.section,
            if (bookmark.testName.trim().isNotEmpty) bookmark.testName,
          ].join(' · '),
          style: const TextStyle(
            color: _muted,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SelectableText(
          question.text,
          style: const TextStyle(
            color: _ink,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < question.options.length; i++) ...[
          _OptionRow(
            label: question.optionKeys.length > i
                ? question.optionKeys[i]
                : String.fromCharCode(65 + i),
            text: question.options[i],
            correct: i == question.correct,
            yours: i == question.selected,
          ),
          const SizedBox(height: 8),
        ],
        if (question.explanation.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.solution,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  question.explanation,
                  style: const TextStyle(
                    color: Color(0xFF31445F),
                    fontSize: 15,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _OptionRow extends StatelessWidget {
  const _OptionRow({
    required this.label,
    required this.text,
    required this.correct,
    required this.yours,
  });

  final String label;
  final String text;
  final bool correct;
  final bool yours;

  @override
  Widget build(BuildContext context) {
    final wrongPick = yours && !correct;
    final borderColor = correct
        ? _correct
        : wrongPick
        ? const Color(0xFF9F1239)
        : _border;
    final l10n = context.l10n;
    final tag = correct
        ? (yours ? l10n.correctYourAnswer : l10n.correctAnswer)
        : wrongPick
        ? l10n.yourAnswer
        : null;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: correct ? const Color(0xFFEAF8F2) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: correct || wrongPick ? 1.5 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label.',
            style: const TextStyle(color: _ink, fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
                if (tag != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    tag,
                    style: TextStyle(
                      color: correct ? _correct : const Color(0xFF9F1239),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookmarksEmpty extends StatelessWidget {
  const _BookmarksEmpty({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bookmark_outline_rounded, size: 48, color: _navy),
            const SizedBox(height: 12),
            Text(
              message ?? context.l10n.bookmarksEmptyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ink,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (message == null) ...[
              const SizedBox(height: 8),
              Text(
                context.l10n.bookmarksEmptyBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _muted,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BookmarksLoading extends StatelessWidget {
  const _BookmarksLoading();

  @override
  Widget build(BuildContext context) {
    return const SkeletonShimmer(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SkeletonBlock(height: 96, radius: 18),
            SizedBox(height: 10),
            SkeletonBlock(height: 96, radius: 18),
            SizedBox(height: 10),
            SkeletonBlock(height: 96, radius: 18),
          ],
        ),
      ),
    );
  }
}

String _savedLabel(BuildContext context, DateTime savedAt) {
  final l10n = context.l10n;
  final now = DateTime.now();
  final days = DateTime(
    now.year,
    now.month,
    now.day,
  ).difference(DateTime(savedAt.year, savedAt.month, savedAt.day)).inDays;
  if (days <= 0) return l10n.savedToday;
  if (days == 1) return l10n.savedYesterday;
  if (days < 7) return l10n.savedDaysAgo(days);
  return MaterialLocalizations.of(context).formatShortMonthDay(savedAt);
}
