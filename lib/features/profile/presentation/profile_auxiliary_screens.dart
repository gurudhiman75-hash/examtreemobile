import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/presentation/providers/auth_providers.dart';
import '../../preferences/domain/question_language.dart';
import '../../preferences/presentation/providers/question_language_providers.dart';
import '../domain/performance_analytics.dart';
import 'providers/analytics_providers.dart';

class ProfileProgressScreen extends ConsumerWidget {
  const ProfileProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(performanceAnalyticsProvider);
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: _bar('My Progress'),
      body: analytics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _Retry(
          text: 'Unable to load your progress.',
          onRetry: () => ref.invalidate(performanceAnalyticsProvider),
        ),
        data: (value) => _ProgressBody(value: value),
      ),
    );
  }
}

class _ProgressBody extends StatelessWidget {
  const _ProgressBody({required this.value});
  final PerformanceAnalytics value;

  @override
  Widget build(BuildContext context) {
    if (value.totalTestsAttempted == 0) {
      return _EmptyPage(
        icon: Icons.insights_outlined,
        title: 'Your progress starts with your first test',
        body: 'Complete a mock or practice test to build accuracy, score and section insights here.',
        action: 'Browse Tests',
        onAction: () => context.go('/exams'),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        Row(
          children: [
            Expanded(child: _Metric(value: _pct(value.averageAccuracy), label: 'Overall Accuracy', icon: Icons.track_changes_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _Metric(value: value.totalQuestions.toString(), label: 'Questions', icon: Icons.quiz_outlined)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _Metric(value: _pct(value.averageScore), label: 'Average Score', icon: Icons.bar_chart_rounded)),
            const SizedBox(width: 10),
            Expanded(child: _Metric(value: value.totalTestsAttempted.toString(), label: 'Tests', icon: Icons.fact_check_outlined)),
          ],
        ),
        const SizedBox(height: 22),
        const Text('Subject-wise Progress', style: TextStyle(color: Color(0xFF081847), fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        if (value.sectionPerformance.isEmpty)
          const _InfoBox(text: 'Section-wise performance will appear after reviewed questions are available.')
        else
          for (final section in value.sectionPerformance) ...[
            _SectionProgress(section: section),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 16),
        const Text('Recent Tests', style: TextStyle(color: Color(0xFF081847), fontSize: 20, fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        for (final point in value.scoreTrend.reversed) ...[
          _RecentResult(point: point),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(questionLanguageProvider).value ?? QuestionLanguage.english;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: _bar('Settings'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          const _SectionLabel('App Preferences'),
          _SettingsCard(
            children: [
              _SettingRow(
                icon: Icons.translate_rounded,
                title: 'Language',
                value: language.label,
                onTap: () => _chooseLanguage(context, ref, language),
              ),
              _SettingRow(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                value: 'Device settings',
                onTap: () => context.push('/notifications'),
              ),
              _SettingRow(
                icon: Icons.lock_outline_rounded,
                title: 'Privacy & Account',
                value: 'Manage',
                onTap: () => context.push('/account'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _SectionLabel('Learning'),
          _SettingsCard(
            children: [
              _SettingRow(
                icon: Icons.download_outlined,
                title: 'My Downloads',
                value: 'Offline resources',
                onTap: () => context.push('/profile-downloads'),
              ),
              _SettingRow(
                icon: Icons.history_rounded,
                title: 'Test History',
                value: 'Results',
                onTap: () => context.push('/results'),
              ),
              _SettingRow(
                icon: Icons.help_outline_rounded,
                title: 'Help & Support',
                value: 'Get help',
                onTap: () => context.push('/profile-help'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _chooseLanguage(
    BuildContext context,
    WidgetRef ref,
    QuestionLanguage current,
  ) async {
    final selected = await showModalBottomSheet<QuestionLanguage>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Question Language', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ),
            ),
            for (final language in QuestionLanguage.values)
              RadioListTile<QuestionLanguage>(
                value: language,
                groupValue: current,
                title: Text(language.label),
                onChanged: (value) => Navigator.pop(sheetContext, value),
              ),
          ],
        ),
      ),
    );
    if (selected != null && selected != current) {
      await setQuestionLanguage(ref, selected);
    }
  }
}

class ProfileHelpScreen extends StatelessWidget {
  const ProfileHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const faqs = [
      ('How do I take a test?', 'Open a test series, choose an available test, review the instructions and tap Start Test.'),
      ('How do I use practice mode?', 'Practice content is available from Learn and from topic-wise test areas where published.'),
      ('How do I switch language?', 'Open Settings and choose Question Language. A translation is shown only when that question supports it.'),
      ('Where can I see past attempts?', 'Open Test History or Results from your Profile.'),
      ('How do payments and renewals work?', 'Choose a plan from a test series. Purchased access and renewal status appear in My Test Series.'),
      ('How do I manage my account?', 'Open Settings → Privacy & Account for privacy information and account controls.'),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: _bar('Help & Support'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFEEF5FF), borderRadius: BorderRadius.circular(18)),
            child: const Row(
              children: [
                Icon(Icons.support_agent_rounded, color: Color(0xFF176CC0), size: 30),
                SizedBox(width: 12),
                Expanded(child: Text('Find quick answers about tests, learning, payments and your account.', style: TextStyle(color: Color(0xFF425D89), height: 1.4))),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Text('Popular Help Topics', style: TextStyle(color: Color(0xFF081847), fontSize: 20, fontWeight: FontWeight.w900)),
          const SizedBox(height: 10),
          for (final faq in faqs) ...[
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE4ECF6))),
              child: ExpansionTile(
                title: Text(faq.$1, style: const TextStyle(color: Color(0xFF10264A), fontWeight: FontWeight.w800, fontSize: 13)),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                children: [
                  Align(alignment: Alignment.centerLeft, child: Text(faq.$2, style: const TextStyle(color: Color(0xFF60759B), height: 1.45))),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _name;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(
      text: ref.read(firebaseAuthProvider).currentUser?.displayName ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _name.text.trim();
    if (value.length < 2 || _saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(firebaseAuthProvider).currentUser?.updateDisplayName(value);
      await ref.read(firebaseAuthProvider).currentUser?.reload();
      ref.invalidate(authStateChangesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated.')));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Unable to update your profile right now.')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateChangesProvider).value ?? ref.read(firebaseAuthProvider).currentUser;
    final contact = user?.email?.trim().isNotEmpty == true ? user!.email! : (user?.phoneNumber ?? '');
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: const Color(0xFFF8FBFF),
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(_saving ? 'Saving…' : 'Save', style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
        children: [
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFFEAF4FF),
              child: Text(
                (_name.text.trim().isEmpty ? 'S' : _name.text.trim()[0]).toUpperCase(),
                style: const TextStyle(color: Color(0xFF176CC0), fontSize: 30, fontWeight: FontWeight.w900),
              ),
            ),
          ),
          const SizedBox(height: 26),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: TextEditingController(text: contact),
            enabled: false,
            decoration: const InputDecoration(labelText: 'Verified contact', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 10),
          const Text(
            'Email and phone changes require verification and are managed through your sign-in account.',
            style: TextStyle(color: Color(0xFF718096), fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class ProfileDownloadsScreen extends StatelessWidget {
  const ProfileDownloadsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: _bar('My Downloads'),
        body: const _EmptyPage(
          icon: Icons.download_done_rounded,
          title: 'No offline resources yet',
          body: 'Downloaded notes and revision resources will appear here when offline downloads are available.',
        ),
      );
}

class ProfileBookmarksScreen extends StatelessWidget {
  const ProfileBookmarksScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: _bar('Bookmarks'),
        body: const _EmptyPage(
          icon: Icons.bookmark_outline_rounded,
          title: 'No saved bookmarks yet',
          body: 'Items you save for revision will appear here as bookmark support expands across Learn and tests.',
        ),
      );
}

class ProfileCouponsScreen extends StatelessWidget {
  const ProfileCouponsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8FBFF),
        appBar: _bar('Coupons & Offers'),
        body: _EmptyPage(
          icon: Icons.local_offer_outlined,
          title: 'Apply coupons at checkout',
          body: 'Available coupon codes can be entered when choosing or renewing a test-series plan.',
          action: 'Explore Test Series',
          onAction: () => context.go('/exams'),
        ),
      );
}

PreferredSizeWidget _bar(String title) => AppBar(
      title: Text(title, style: const TextStyle(color: Color(0xFF081847), fontWeight: FontWeight.w900)),
      backgroundColor: const Color(0xFFF8FBFF),
      foregroundColor: const Color(0xFF081847),
      surfaceTintColor: Colors.transparent,
    );

class _Metric extends StatelessWidget {
  const _Metric({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE4ECF6))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: const Color(0xFF176CC0)),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(color: Color(0xFF081847), fontSize: 23, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Color(0xFF60759B), fontSize: 12)),
        ]),
      );
}

class _SectionProgress extends StatelessWidget {
  const _SectionProgress({required this.section});
  final SectionPerformance section;

  @override
  Widget build(BuildContext context) {
    final accuracy = section.accuracy.clamp(0, 100).toDouble();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE4ECF6))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(section.name, style: const TextStyle(color: Color(0xFF10264A), fontWeight: FontWeight.w900))),
          Text(_pct(accuracy), style: const TextStyle(color: Color(0xFF3563D8), fontWeight: FontWeight.w900)),
        ]),
        const SizedBox(height: 8),
        LinearProgressIndicator(value: accuracy / 100, minHeight: 7, borderRadius: BorderRadius.circular(999), backgroundColor: const Color(0xFFE6EDF7)),
        const SizedBox(height: 6),
        Text(section.answered.toString() + ' answered · ' + section.totalQuestions.toString() + ' total', style: const TextStyle(color: Color(0xFF718096), fontSize: 11)),
      ]),
    );
  }
}

class _RecentResult extends StatelessWidget {
  const _RecentResult({required this.point});
  final PerformanceTrendPoint point;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE4ECF6))),
        child: Row(children: [
          Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: const Color(0xFFEEF5FF), borderRadius: BorderRadius.circular(13)), child: Text(_pct(point.percentageScore), style: const TextStyle(color: Color(0xFF176CC0), fontWeight: FontWeight.w900, fontSize: 11))),
          const SizedBox(width: 11),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(point.testName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF10264A), fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(_pct(point.accuracy) + ' accuracy', style: const TextStyle(color: Color(0xFF718096), fontSize: 11)),
          ])),
        ]),
      );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text, style: const TextStyle(color: Color(0xFF60759B), fontSize: 12, fontWeight: FontWeight.w800)),
      );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE4ECF6))),
        child: Column(children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const Divider(height: 1),
          ],
        ]),
      );
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.icon, required this.title, required this.value, required this.onTap});
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon, color: const Color(0xFF176CC0)),
        title: Text(title, style: const TextStyle(color: Color(0xFF10264A), fontWeight: FontWeight.w800)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(value, style: const TextStyle(color: Color(0xFF718096), fontSize: 12)),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right_rounded),
        ]),
        onTap: onTap,
      );
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFEEF5FF), borderRadius: BorderRadius.circular(16)),
        child: Text(text, style: const TextStyle(color: Color(0xFF526A92), height: 1.4)),
      );
}

class _Retry extends StatelessWidget {
  const _Retry({required this.text, required this.onRetry});
  final String text;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(text),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ]),
      );
}

class _EmptyPage extends StatelessWidget {
  const _EmptyPage({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String body;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 92,
              height: 92,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: Color(0xFFEAF4FF), shape: BoxShape.circle),
              child: Icon(icon, size: 44, color: const Color(0xFF176CC0)),
            ),
            const SizedBox(height: 20),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF081847), fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(body, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF60759B), height: 1.45)),
            if (action != null && onAction != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(action!)),
            ],
          ]),
        ),
      );
}

String _pct(double value) {
  final safe = value.clamp(0, 100).toDouble();
  return safe == safe.roundToDouble() ? safe.toInt().toString() + '%' : safe.toStringAsFixed(1) + '%';
}
