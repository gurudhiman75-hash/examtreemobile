import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/performance_analytics.dart';
import 'providers/analytics_providers.dart';

const _navy = Color(0xFF062A56);
const _navy2 = Color(0xFF0B4F8A);
const _page = Color(0xFFF7F9FC);
const _line = Color(0xFFE8EDF4);

enum ProfileSection { progress, downloads, bookmarks, history, offers, help }

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final analytics = ref.watch(performanceAnalyticsProvider);
    final rawName = user?.displayName?.trim() ?? '';
    final email = user?.email?.trim() ?? '';
    final phone = user?.phoneNumber?.trim() ?? '';
    final name = rawName.isNotEmpty
        ? rawName
        : (email.isNotEmpty ? email.split('@').first : 'Student');
    final contact = email.isNotEmpty ? email : phone;
    final initial = name.isEmpty ? 'S' : name[0].toUpperCase();

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(performanceAnalyticsProvider);
        try {
          await ref.read(performanceAnalyticsProvider.future);
        } catch (_) {}
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 28),
        children: [
          _IdentityCard(
            name: name,
            contact: contact,
            initial: initial,
            onManage: () => context.push('/account'),
          ),
          const SizedBox(height: 14),
          analytics.when(
            loading: () => const _StatsRow(tests: '…', accuracy: '…', questions: '…'),
            error: (_, __) => const _StatsRow(tests: '—', accuracy: '—', questions: '—'),
            data: (value) => _StatsRow(
              tests: value.totalTestsAttempted.toString(),
              accuracy: value.averageAccuracy.round().toString() + '%',
              questions: value.totalQuestions.toString(),
            ),
          ),
          const SizedBox(height: 16),
          _MenuCard(
            items: [
              _MenuItem(
                Icons.insights_rounded,
                const Color(0xFF2563EB),
                const Color(0xFFEAF2FF),
                'My Progress',
                'Accuracy, attempts and performance',
                () => context.push('/profile/progress'),
              ),
              _MenuItem(
                Icons.download_rounded,
                const Color(0xFF0F9F8F),
                const Color(0xFFE4F8F4),
                'My Downloads',
                'Notes and offline content',
                () => context.push('/profile/downloads'),
              ),
              _MenuItem(
                Icons.bookmark_rounded,
                const Color(0xFF7C3AED),
                const Color(0xFFF2ECFF),
                'Bookmarks',
                'Saved notes and questions',
                () => context.push('/profile/bookmarks'),
              ),
              _MenuItem(
                Icons.history_rounded,
                const Color(0xFFE05A45),
                const Color(0xFFFFECE8),
                'Test History',
                'Recent attempts and scores',
                () => context.push('/profile/history'),
              ),
              _MenuItem(
                Icons.local_offer_rounded,
                const Color(0xFFD97706),
                const Color(0xFFFFF3D9),
                'Coupons & Offers',
                'Savings on test series',
                () => context.push('/profile/offers'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _MenuCard(
            items: [
              _MenuItem(
                Icons.settings_rounded,
                const Color(0xFF475569),
                const Color(0xFFEEF2F6),
                'Settings',
                'Language, privacy and account',
                () => context.push('/account'),
              ),
              _MenuItem(
                Icons.help_outline_rounded,
                const Color(0xFF2563EB),
                const Color(0xFFEAF2FF),
                'Help & Support',
                'Answers and support options',
                () => context.push('/profile/help'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileSectionScreen extends ConsumerWidget {
  const ProfileSectionScreen({super.key, required this.section});
  final ProfileSection section;

  String get title {
    switch (section) {
      case ProfileSection.progress:
        return 'My Progress';
      case ProfileSection.downloads:
        return 'My Downloads';
      case ProfileSection.bookmarks:
        return 'Bookmarks';
      case ProfileSection.history:
        return 'Test History';
      case ProfileSection.offers:
        return 'Coupons & Offers';
      case ProfileSection.help:
        return 'Help & Support';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B1F44),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: _line),
        ),
      ),
      body: SafeArea(child: _body(context, ref)),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref) {
    if (section == ProfileSection.progress || section == ProfileSection.history) {
      final analytics = ref.watch(performanceAnalyticsProvider);
      return analytics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'Unable to load data',
          body: 'Check your connection and try again.',
          action: 'Retry',
          onTap: () => ref.invalidate(performanceAnalyticsProvider),
        ),
        data: (value) => section == ProfileSection.progress
            ? _ProgressView(analytics: value)
            : _HistoryView(analytics: value),
      );
    }

    switch (section) {
      case ProfileSection.downloads:
        return _EmptyState(
          icon: Icons.download_done_rounded,
          title: 'Your offline library',
          body: 'Downloaded learning resources will appear here when offline support is available.',
          action: 'Open Learn',
          onTap: () => context.go('/learn'),
        );
      case ProfileSection.bookmarks:
        return _EmptyState(
          icon: Icons.bookmark_outline_rounded,
          title: 'Nothing bookmarked yet',
          body: 'Save useful notes and questions while learning and they will appear here.',
          action: 'Browse Learn',
          onTap: () => context.go('/learn'),
        );
      case ProfileSection.offers:
        return _OffersView(onBrowse: () => context.push('/store'));
      case ProfileSection.help:
        return const _HelpView();
      case ProfileSection.progress:
      case ProfileSection.history:
        return const SizedBox.shrink();
    }
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.name,
    required this.contact,
    required this.initial,
    required this.onManage,
  });

  final String name;
  final String contact;
  final String initial;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_navy, _navy2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Color(0x18062A56), blurRadius: 22, offset: Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0x2EFFFFFF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: Color(0xFFFFD36B),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (contact.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    contact,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFFCFDDF0)),
                  ),
                ],
                const SizedBox(height: 9),
                InkWell(
                  onTap: onManage,
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const Text(
                      'Manage account',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: Colors.white),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.tests,
    required this.accuracy,
    required this.questions,
  });

  final String tests;
  final String accuracy;
  final String questions;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          _StatCell(Icons.assignment_turned_in_outlined, tests, 'Tests'),
          const _Divider(),
          _StatCell(Icons.track_changes_rounded, accuracy, 'Accuracy'),
          const _Divider(),
          _StatCell(Icons.quiz_outlined, questions, 'Questions'),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell(this.icon, this.value, this.label);
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 19, color: AppColors.primary),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(color: Color(0xFF66758A), fontSize: 11)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(width: 1, height: 42, color: _line);
}

class _MenuItem {
  const _MenuItem(this.icon, this.tint, this.soft, this.title, this.subtitle, this.onTap);
  final IconData icon;
  final Color tint;
  final Color soft;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items});
  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: _line),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              onTap: items[i].onTap,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              leading: _IconBubble(items[i].icon, items[i].tint, items[i].soft),
              title: Text(items[i].title, style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(
                items[i].subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF718096)),
            ),
            if (i != items.length - 1)
              const Padding(
                padding: EdgeInsets.only(left: 68),
                child: Divider(height: 1, color: _line),
              ),
          ],
        ],
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble(this.icon, this.tint, this.soft);
  final IconData icon;
  final Color tint;
  final Color soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(13)),
      child: Icon(icon, color: tint, size: 22),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView({required this.analytics});
  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.totalTestsAttempted == 0) {
      return _EmptyState(
        icon: Icons.insights_rounded,
        title: 'Your progress starts here',
        body: 'Complete a test to see accuracy, attempts and section-level insights.',
        action: 'Browse tests',
        onTap: () => context.go('/exams'),
      );
    }
    final accuracy = analytics.averageAccuracy.clamp(0, 100).toDouble();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: _line),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: accuracy / 100,
                      strokeWidth: 8,
                      backgroundColor: const Color(0xFFE8EEF6),
                      color: const Color(0xFF14B879),
                    ),
                    Text(
                      accuracy.round().toString() + '%',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Overall accuracy', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 5),
                    Text(
                      analytics.totalTestsAttempted.toString() +
                          ' tests • ' +
                          analytics.totalQuestions.toString() +
                          ' questions',
                      style: const TextStyle(color: Color(0xFF6B7A90)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Section performance',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _navy),
        ),
        const SizedBox(height: 10),
        if (analytics.sectionPerformance.isEmpty)
          const _Note('Section-wise data will appear after eligible test attempts.')
        else
          ...analytics.sectionPerformance.map((section) => _SectionRow(section)),
      ],
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow(this.section);
  final SectionPerformance section;

  @override
  Widget build(BuildContext context) {
    final progress = (section.accuracy / 100).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          const _IconBubble(Icons.auto_graph_rounded, Color(0xFF2563EB), Color(0xFFEAF2FF)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFE9EEF5),
                    color: const Color(0xFF14B879),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            section.accuracy.round().toString() + '%',
            style: const TextStyle(fontWeight: FontWeight.w900, color: _navy),
          ),
        ],
      ),
    );
  }
}

class _HistoryView extends StatelessWidget {
  const _HistoryView({required this.analytics});
  final PerformanceAnalytics analytics;

  @override
  Widget build(BuildContext context) {
    if (analytics.scoreTrend.isEmpty) {
      return _EmptyState(
        icon: Icons.history_rounded,
        title: 'No completed tests yet',
        body: 'Your recent test attempts will appear here.',
        action: 'Explore tests',
        onTap: () => context.go('/exams'),
      );
    }
    final history = analytics.scoreTrend.reversed.toList(growable: false);
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const Text(
          'Recent attempts',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _navy),
        ),
        const SizedBox(height: 10),
        for (final point in history)
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
              side: const BorderSide(color: _line),
            ),
            child: ListTile(
              onTap: () => context.push('/review', extra: point.attemptId),
              leading: const _IconBubble(
                Icons.assignment_turned_in_rounded,
                Color(0xFF2563EB),
                Color(0xFFEAF2FF),
              ),
              title: Text(
                point.testName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              subtitle: Text(
                point.accuracy.round().toString() + '% accuracy',
                style: const TextStyle(color: Color(0xFF718096), fontSize: 12),
              ),
              trailing: Text(
                point.percentageScore.round().toString() + '%',
                style: const TextStyle(fontWeight: FontWeight.w900, color: _navy),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OffersView extends StatelessWidget {
  const _OffersView({required this.onBrowse});
  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF092A59), Color(0xFF125DA4)]),
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Row(
            children: [
              _IconBubble(Icons.card_giftcard_rounded, Color(0xFFFFC857), Color(0x22FFFFFF)),
              SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Eligible discounts are shown before payment so you always see the final payable amount.',
                  style: TextStyle(color: Colors.white, height: 1.35, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const _Note('There are no account-specific coupons to show right now.'),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onBrowse,
          icon: const Icon(Icons.explore_outlined),
          label: const Text('Explore Test Series'),
        ),
      ],
    );
  }
}

class _HelpView extends StatelessWidget {
  const _HelpView();

  @override
  Widget build(BuildContext context) {
    const items = <(IconData, String, String)>[
      (
        Icons.quiz_outlined,
        'How do I take a test?',
        'Open Exams or My Test Series, select a test, review the instructions and tap Start Test.'
      ),
      (
        Icons.translate_rounded,
        'How do I change question language?',
        'Open Settings from Profile and choose your preferred question language.'
      ),
      (
        Icons.payment_rounded,
        'Payments and test series',
        'The final payable amount, discount and selected payment method are shown before you pay.'
      ),
      (
        Icons.lock_outline_rounded,
        'Account and login',
        'Use Manage Account for linked sign-in methods, password and account controls.'
      ),
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        const Text(
          'How can we help?',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: _navy),
        ),
        const SizedBox(height: 10),
        for (final item in items)
          ExpansionTile(
            backgroundColor: Colors.white,
            collapsedBackgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            leading: _IconBubble(item.$1, const Color(0xFF2563EB), const Color(0xFFEAF2FF)),
            title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
            childrenPadding: const EdgeInsets.fromLTRB(70, 0, 16, 14),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(item.$3, style: const TextStyle(color: Color(0xFF68778C), height: 1.4)),
              ),
            ],
          ),
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF294B78)))),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
    required this.action,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            children: [
              Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF2FF),
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Icon(icon, size: 42, color: const Color(0xFF2563EB)),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: _navy),
              ),
              const SizedBox(height: 8),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF6F7E92), height: 1.45),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: _navy,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                child: Text(action),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
