import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/providers/repository_providers.dart';

final managedMobilePageProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, slug) async {
  final response = await ref.watch(apiClientProvider).dio.get<Map<String, dynamic>>(
        'mobile/pages/${Uri.encodeComponent(slug)}',
      );
  final body = response.data;
  final page = body?['page'];
  if (page is! Map) throw const FormatException('Invalid mobile page');
  return Map<String, dynamic>.from(page);
});

class ManagedMobilePageScreen extends ConsumerWidget {
  const ManagedMobilePageScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(managedMobilePageProvider(slug));
    return state.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Page unavailable')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 44),
                const SizedBox(height: 12),
                const Text('This page could not be loaded.'),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => ref.invalidate(managedMobilePageProvider(slug)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
      data: (page) {
        final title = page['title']?.toString().trim() ?? '';
        final showAppBar = page['showAppBar'] != false;
        final configuration = page['configuration'] is Map
            ? Map<String, dynamic>.from(page['configuration'] as Map)
            : const <String, dynamic>{};
        final sections = configuration['sections'] is List
            ? (configuration['sections'] as List)
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .where((item) => item['isVisible'] != false)
                .toList(growable: false)
            : const <Map<String, dynamic>>[];

        final body = RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(managedMobilePageProvider(slug));
            await ref.read(managedMobilePageProvider(slug).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(12, 14, 12, 32),
            children: [
              if (sections.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: Text('No content has been published here yet.')),
                )
              else
                for (final section in sections) ...[
                  _ManagedSection(section: section),
                  const SizedBox(height: 18),
                ],
            ],
          ),
        );

        return Scaffold(
          backgroundColor: const Color(0xFFFBFCFE),
          appBar: showAppBar
              ? AppBar(
                  title: Text(title.isEmpty ? 'Examtree' : title),
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF10264A),
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                )
              : null,
          body: SafeArea(top: !showAppBar, child: body),
        );
      },
    );
  }
}

class _ManagedSection extends StatelessWidget {
  const _ManagedSection({required this.section});

  final Map<String, dynamic> section;

  @override
  Widget build(BuildContext context) {
    final title = section['title']?.toString().trim() ?? '';
    final subtitle = section['subtitle']?.toString().trim() ?? '';
    final layout = section['layout']?.toString().trim().toLowerCase() ?? 'horizontal';
    final cards = section['cards'] is List
        ? (section['cards'] as List)
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .where((item) => item['isActive'] != false)
            .toList(growable: false)
        : const <Map<String, dynamic>>[];

    final header = title.isEmpty && subtitle.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title.isNotEmpty)
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFF10264A),
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF718096),
                        ),
                  ),
                ],
              ],
            ),
          );

    Widget content;
    switch (layout) {
      case 'grid':
        content = LayoutBuilder(
          builder: (context, constraints) {
            final width = (constraints.maxWidth - 10) / 2;
            return Wrap(
              spacing: 10,
              runSpacing: 10,
              children: cards
                  .map((card) => SizedBox(width: width, child: _ManagedCard(card: card)))
                  .toList(growable: false),
            );
          },
        );
        break;
      case 'list':
        content = Column(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              _ManagedCard(card: cards[i], listMode: true),
              if (i != cards.length - 1) const SizedBox(height: 10),
            ],
          ],
        );
        break;
      case 'banner':
        content = cards.isEmpty
            ? const SizedBox.shrink()
            : _ManagedCard(card: cards.first, bannerMode: true);
        break;
      default:
        content = SizedBox(
          height: 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => SizedBox(
              width: 220,
              child: _ManagedCard(card: cards[index]),
            ),
          ),
        );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [header, content],
    );
  }
}

class _ManagedCard extends StatelessWidget {
  const _ManagedCard({
    required this.card,
    this.listMode = false,
    this.bannerMode = false,
  });

  final Map<String, dynamic> card;
  final bool listMode;
  final bool bannerMode;

  Future<void> _open(BuildContext context) async {
    final type = card['destinationType']?.toString().trim().toLowerCase() ?? 'none';
    final value = card['destinationValue']?.toString().trim() ?? '';
    switch (type) {
      case 'page':
        if (value.isNotEmpty) {
          context.push('/page/${Uri.encodeComponent(value)}');
        }
        return;
      case 'exam':
        if (value.isNotEmpty) {
          context.push('/exam-details?id=${Uri.encodeQueryComponent(value)}');
        } else {
          context.go('/exams');
        }
        return;
      case 'test_series':
        if (value.isNotEmpty) {
          context.push('/test-series?id=${Uri.encodeQueryComponent(value)}');
        } else {
          context.push('/store?section=tests');
        }
        return;
      case 'learn':
        if (value.startsWith('/')) {
          context.go(value);
        } else {
          context.go('/learn');
        }
        return;
      case 'url':
        final uri = Uri.tryParse(value);
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = card['title']?.toString().trim() ?? '';
    final subtitle = card['subtitle']?.toString().trim() ?? '';
    final badge = card['badge']?.toString().trim() ?? '';
    final imageUrl = card['imageUrl']?.toString().trim() ?? '';
    final iconUrl = card['iconUrl']?.toString().trim() ?? '';
    final cta = card['ctaLabel']?.toString().trim() ?? '';

    final image = imageUrl.isNotEmpty
        ? ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              imageUrl,
              height: bannerMode ? 150 : listMode ? 76 : 84,
              width: bannerMode ? double.infinity : listMode ? 76 : double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          )
        : iconUrl.isNotEmpty
            ? Align(
                alignment: Alignment.centerLeft,
                child: Image.network(
                  iconUrl,
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.apps_rounded),
                ),
              )
            : const Align(
                alignment: Alignment.centerLeft,
                child: Icon(Icons.apps_rounded, color: Color(0xFF0B5D96), size: 30),
              );

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (badge.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              badge,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF0B5D96),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        if (title.isNotEmpty)
          Text(
            title,
            maxLines: bannerMode ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: const Color(0xFF10264A),
                  fontWeight: FontWeight.w900,
                ),
          ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            maxLines: bannerMode ? 3 : 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF718096),
                  height: 1.35,
                ),
          ),
        ],
        if (cta.isNotEmpty) ...[
          const SizedBox(height: 9),
          Text(
            cta,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF0B5D96),
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ],
    );

    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Color(0xFFE3E9F1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _open(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: listMode
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 76, child: image),
                    const SizedBox(width: 12),
                    Expanded(child: copy),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    image,
                    const SizedBox(height: 10),
                    copy,
                  ],
                ),
        ),
      ),
    );
  }
}
