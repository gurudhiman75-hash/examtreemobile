import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../data/learn_practice_catalog.dart';
import '../data/polity_learn_localizations.dart';
import '../domain/learn_lesson.dart';
import '../domain/learn_practice_models.dart';
import 'providers/learn_practice_providers.dart';

class LearnModulesSection extends ConsumerStatefulWidget {
  const LearnModulesSection({super.key});

  @override
  ConsumerState<LearnModulesSection> createState() =>
      _LearnModulesSectionState();
}

class _LearnModulesSectionState extends ConsumerState<LearnModulesSection> {
  String _subject = 'english';

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(learnPracticeProgressListProvider).value ??
        const <LearnPracticeProgress>[];
    final language =
        ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    final polity = polityLearnSubjectFor(language);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionIntro(),
        const SizedBox(height: 12),
        _SubjectSwitcher(
          selected: _subject,
          onChanged: (value) => setState(() => _subject = value),
        ),
        const SizedBox(height: 14),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: _subject == 'english'
              ? _EnglishSubjectPanel(
                  key: const ValueKey('learn-subject-english-panel'),
                  progress: progress,
                )
              : _PolitySubjectPanel(
                  key: const ValueKey('learn-subject-polity-panel'),
                  title: polity.title,
                  subtitle: polity.subtitle,
                  lessons: polity.lessons,
                ),
        ),
      ],
    );
  }
}

class _SectionIntro extends StatelessWidget {
  const _SectionIntro();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Learn by Subject',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: const Color(0xFF0C131F),
                fontWeight: FontWeight.w900,
                letterSpacing: -.35,
              ),
        ),
        const SizedBox(height: 3),
        Text(
          'Pick a subject, open a master topic and continue learning.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF697580),
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}

class _SubjectSwitcher extends StatelessWidget {
  const _SubjectSwitcher({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('learn-subject-switcher'),
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE9EFED),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SubjectSwitchButton(
              key: const Key('learn-subject-english'),
              label: 'English',
              selected: selected == 'english',
              onTap: () => onChanged('english'),
            ),
          ),
          Expanded(
            child: _SubjectSwitchButton(
              key: const Key('learn-subject-polity'),
              label: 'Polity',
              selected: selected == 'polity',
              onTap: () => onChanged('polity'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectSwitchButton extends StatelessWidget {
  const _SubjectSwitchButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: selected
                  ? const Color(0xFF15806C)
                  : const Color(0xFF697580),
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class _EnglishSubjectPanel extends StatelessWidget {
  const _EnglishSubjectPanel({
    super.key,
    required this.progress,
  });

  final List<LearnPracticeProgress> progress;

  @override
  Widget build(BuildContext context) {
    final vocabulary = englishVocabularyPracticeTopics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GroupHeader(
          icon: Icons.translate_rounded,
          title: 'Vocabulary',
          subtitle: 'Build word power with focused exam practice.',
        ),
        const SizedBox(height: 8),
        Container(
          decoration: _groupDecoration,
          child: Column(
            children: [
              for (var index = 0; index < vocabulary.length; index++) ...[
                _EnglishTopicRow(
                  topic: vocabulary[index],
                  progress: _findProgress(progress, vocabulary[index].id),
                ),
                if (index != vocabulary.length - 1) const _RowDivider(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        const _GroupHeader(
          icon: Icons.rule_rounded,
          title: 'Grammar & Usage',
          subtitle: 'Error detection, sentence improvement and fillers.',
        ),
        const SizedBox(height: 8),
        const _ComingSoonGroup(
          items: ['Error Detection', 'Sentence Improvement', 'Fillers'],
        ),
        const SizedBox(height: 14),
        const _GroupHeader(
          icon: Icons.menu_book_rounded,
          title: 'Comprehension',
          subtitle: 'Reading and passage-based practice.',
        ),
        const SizedBox(height: 8),
        const _ComingSoonGroup(
          items: ['Reading Comprehension', 'Sentence Rearrangement'],
        ),
      ],
    );
  }

  static LearnPracticeProgress? _findProgress(
    List<LearnPracticeProgress> progress,
    String topicId,
  ) {
    for (final item in progress) {
      if (item.topicId == topicId) return item;
    }
    return null;
  }
}

class _PolitySubjectPanel extends StatelessWidget {
  const _PolitySubjectPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.lessons,
  });

  final String title;
  final String subtitle;
  final List<LearnLesson> lessons;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GroupHeader(
          icon: Icons.account_balance_rounded,
          title: title,
          subtitle: subtitle,
        ),
        const SizedBox(height: 8),
        Container(
          key: const Key('learn-polity-lessons'),
          decoration: _groupDecoration,
          child: Column(
            children: [
              for (var index = 0; index < lessons.length; index++) ...[
                _PolityLessonRow(lesson: lessons[index]),
                if (index != lessons.length - 1) const _RowDivider(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _EnglishTopicRow extends StatelessWidget {
  const _EnglishTopicRow({
    required this.topic,
    required this.progress,
  });

  final LearnPracticeTopic topic;
  final LearnPracticeProgress? progress;

  @override
  Widget build(BuildContext context) {
    final target = topic.questionTarget <= 0 ? 20 : topic.questionTarget;
    final current = progress == null
        ? 0
        : progress!.status == LearnPracticeStatus.completed
            ? target
            : progress!.currentQuestion.clamp(0, target);
    final percent = target == 0 ? 0 : ((current / target) * 100).round();
    final completed = progress?.status == LearnPracticeStatus.completed;
    final inProgress = progress?.status == LearnPracticeStatus.inProgress;

    return InkWell(
      key: Key('learn-topic-${topic.id}'),
      onTap: () => context.push(
        '/learn-practice?topic=${Uri.encodeQueryComponent(topic.id)}',
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F3F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$percent%',
                style: const TextStyle(
                  color: Color(0xFF147F6B),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0C131F),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    completed
                        ? 'Completed'
                        : inProgress
                            ? 'In progress · $current/$target'
                            : 'Not started · $target questions',
                    style: const TextStyle(
                      color: Color(0xFF697580),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9AA5AE),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolityLessonRow extends StatelessWidget {
  const _PolityLessonRow({required this.lesson});

  final LearnLesson lesson;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('learn-polity-${lesson.id}'),
      onTap: () => context.push(
        '/learn-lesson?id=${Uri.encodeQueryComponent(lesson.id)}',
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFE3F3F0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 19,
                color: Color(0xFF15806C),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0C131F),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lesson.summary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF697580),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${lesson.estimatedMinutes} min',
              style: const TextStyle(
                color: Color(0xFF15806C),
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComingSoonGroup extends StatelessWidget {
  const _ComingSoonGroup({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _groupDecoration,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.lock_outline_rounded,
                      size: 18,
                      color: Color(0xFF9AA5AE),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(
                        color: Color(0xFF49545E),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Text(
                    'Coming soon',
                    style: TextStyle(
                      color: Color(0xFF9A7A35),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            if (index != items.length - 1) const _RowDivider(),
          ],
        ],
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F3F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF15806C)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0C131F),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF697580),
                  fontSize: 11.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 61,
      endIndent: 10,
      color: Color(0xFFEEF1F3),
    );
  }
}

const _groupDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.all(Radius.circular(16)),
  border: Border.fromBorderSide(
    BorderSide(color: Color(0xFFE8EBEE)),
  ),
  boxShadow: [
    BoxShadow(
      color: Color(0x070C131F),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
  ],
);
