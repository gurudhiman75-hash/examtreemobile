import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../bookmarks/presentation/providers/bookmark_providers.dart';
import '../../companion/presentation/providers/daily_companion_providers.dart';
import '../../../l10n/l10n.dart';

const _ink = Color(0xFF10264A);
const _muted = Color(0xFF5F6F82);
const _border = Color(0xFFE4E9F1);
const _navy = Color(0xFF0B3A6F);
const _page = Color(0xFFF7F7F1);

/// What a learner can use without a connection, all of it already stored on
/// this device. Full tests and notes cannot be downloaded yet, and the screen
/// says so rather than showing an empty "downloads" list.
class OfflineLibraryScreen extends ConsumerWidget {
  const OfflineLibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(questionBookmarksProvider).value ?? const [];
    final companion = ref.watch(dailyCompanionSnapshotProvider).value;
    final revisionCount = companion?.items.length ?? 0;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        title: Text(l10n.offlineTitle),
        backgroundColor: _page,
        foregroundColor: _ink,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Text(
            l10n.offlineIntro,
            style: const TextStyle(
              color: _muted,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _OfflineTile(
            key: const Key('offline-bookmarks'),
            icon: Icons.bookmark_rounded,
            title: l10n.offlineSavedQuestions,
            detail: bookmarks.isEmpty
                ? l10n.offlineSavedQuestionsEmpty
                : l10n.offlineSavedQuestionsCount(bookmarks.length),
            onTap: () => context.push('/profile-bookmarks'),
          ),
          const SizedBox(height: 10),
          _OfflineTile(
            key: const Key('offline-revision'),
            icon: Icons.replay_rounded,
            title: l10n.offlineRevision,
            detail: revisionCount == 0
                ? l10n.offlineRevisionEmpty
                : l10n.offlineRevisionCount(revisionCount),
            onTap: () => context.push('/daily'),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2F8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.offlineTestsTitle,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.offlineTestsBody,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    height: 1.5,
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

class _OfflineTile extends StatelessWidget {
  const _OfflineTile({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: _navy),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: _muted),
            ],
          ),
        ),
      ),
    );
  }
}
