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

class RegisteredMobilePageScreen extends ConsumerWidget {
  const RegisteredMobilePageScreen({
    super.key,
    required this.slug,
    required this.nativeChild,
  });

  final String slug;
  final Widget nativeChild;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(managedMobilePageProvider(slug));
    return state.maybeWhen(
      data: (page) => page['renderMode']?.toString() == 'managed'
          ? ManagedMobilePageScreen(slug: slug)
          : nativeChild,
      orElse: () => nativeChild,
    );
  }
}

class ManagedMobilePageScreen extends ConsumerWidget {
  const ManagedMobilePageScreen({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(managedMobilePageProvider(slug));
    return state.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Page unavailable')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.cloud_off_outlined, size: 44),
              const SizedBox(height: 12),
              const Text('This page could not be loaded.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(managedMobilePageProvider(slug)),
                child: const Text('Retry'),
              ),
            ]),
          ),
        ),
      ),
      data: (page) {
        final title = page['title']?.toString().trim() ?? '';
        final showAppBar = page['showAppBar'] != false;
        final configuration = page['configuration'] is Map
            ? Map<String, dynamic>.from(page['configuration'] as Map)
            : const <String, dynamic>{};
        final hero = configuration['hero'] is Map
            ? Map<String, dynamic>.from(configuration['hero'] as Map)
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
              if (hero['enabled'] == true) ...[
                _ManagedHero(hero: hero),
                const SizedBox(height: 20),
              ],
              if (sections.isEmpty && hero['enabled'] != true)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(child: Text('No content has been published here yet.')),
                )
              else
                for (final section in sections) ...[
                  _ManagedSection(section: section),
                  const SizedBox(height: 20),
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

class _ManagedHero extends StatelessWidget {
  const _ManagedHero({required this.hero});
  final Map<String, dynamic> hero;

  @override
  Widget build(BuildContext context) {
    final title = hero['title']?.toString().trim() ?? '';
    final subtitle = hero['subtitle']?.toString().trim() ?? '';
    final badge = hero['badge']?.toString().trim() ?? '';
    final imageUrl = hero['imageUrl']?.toString().trim() ?? '';
    final cta = hero['ctaLabel']?.toString().trim() ?? '';
    final style = hero['style']?.toString().trim() ?? 'featured';
    final compact = style == 'compact';

    return Material(
      color: const Color(0xFF062D5C),
      borderRadius: BorderRadius.circular(compact ? 18 : 24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDestination(context, hero),
        child: Stack(
          children: [
            if (imageUrl.isNotEmpty)
              Positioned.fill(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF031B3A).withValues(alpha: .94),
                      const Color(0xFF0B5D96).withValues(alpha: imageUrl.isEmpty ? .94 : .72),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(compact ? 14 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (badge.isNotEmpty)
                    Text(
                      badge.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: const Color(0xFFFFD36B),
                            fontWeight: FontWeight.w900,
                            letterSpacing: .6,
                          ),
                    ),
                  if (title.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            height: 1.15,
                          ),
                    ),
                  ],
                  if (subtitle.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: .82),
                            height: 1.4,
                          ),
                    ),
                  ],
                  if (cta.isNotEmpty) ...[
                    const SizedBox(height: 13),
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text(cta, style: const TextStyle(color: Color(0xFFFFD36B), fontWeight: FontWeight.w900)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFFFFD36B)),
                    ]),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
    final columns = ((section['columns'] as num?)?.toInt() ?? 2).clamp(1, 4);
    final gapName = section['gap']?.toString() ?? 'normal';
    final gap = gapName == 'compact' ? 6.0 : gapName == 'relaxed' ? 14.0 : 10.0;
    final sectionStyle = section['style']?.toString() ?? 'default';
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
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                        height: 1.35,
                      ),
                ),
              ],
            ]),
          );

    Widget content;
    switch (layout) {
      case 'grid':
        content = LayoutBuilder(builder: (context, constraints) {
          final unit = (constraints.maxWidth - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: gap,
            runSpacing: gap,
            children: cards.map((card) {
              final span = ((card['span'] as num?)?.toInt() ?? 1).clamp(1, columns);
              final width = unit * span + gap * (span - 1);
              return SizedBox(
                width: width,
                child: _ManagedCard(card: card, sectionStyle: sectionStyle, compactGrid: columns >= 3),
              );
            }).toList(growable: false),
          );
        });
        break;
      case 'list':
        content = Column(children: [
          for (var i = 0; i < cards.length; i++) ...[
            _ManagedCard(card: cards[i], sectionStyle: sectionStyle, listMode: true),
            if (i != cards.length - 1) SizedBox(height: gap),
          ],
        ]);
        break;
      case 'banner':
        content = cards.isEmpty
            ? const SizedBox.shrink()
            : _ManagedCard(card: cards.first, sectionStyle: sectionStyle, bannerMode: true);
        break;
      default:
        content = SizedBox(
          height: sectionStyle == 'compact' ? 142 : 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => SizedBox(width: gap),
            itemBuilder: (context, index) => SizedBox(
              width: sectionStyle == 'compact' ? 176 : 220,
              child: _ManagedCard(card: cards[index], sectionStyle: sectionStyle),
            ),
          ),
        );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [header, content]);
  }
}

class _ManagedCard extends StatelessWidget {
  const _ManagedCard({
    required this.card,
    required this.sectionStyle,
    this.listMode = false,
    this.bannerMode = false,
    this.compactGrid = false,
  });

  final Map<String, dynamic> card;
  final String sectionStyle;
  final bool listMode;
  final bool bannerMode;
  final bool compactGrid;

  @override
  Widget build(BuildContext context) {
    final title = card['title']?.toString().trim() ?? '';
    final subtitle = card['subtitle']?.toString().trim() ?? '';
    final badge = card['badge']?.toString().trim() ?? '';
    final imageUrl = card['imageUrl']?.toString().trim() ?? '';
    final iconUrl = card['iconUrl']?.toString().trim() ?? '';
    final cta = card['ctaLabel']?.toString().trim() ?? '';
    final overrideStyle = card['style']?.toString().trim() ?? 'default';
    final style = overrideStyle == 'default' ? sectionStyle : overrideStyle;
    final compact = style == 'compact' || compactGrid;
    final minimal = style == 'minimal';
    final imageLed = style == 'image' || style == 'featured';

    final visual = imageUrl.isNotEmpty && (imageLed || bannerMode)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              height: bannerMode ? 150 : compact ? 58 : 84,
              width: bannerMode ? double.infinity : listMode ? 72 : double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          )
        : iconUrl.isNotEmpty
            ? Image.network(
                iconUrl,
                width: compact ? 30 : 42,
                height: compact ? 30 : 42,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(Icons.apps_rounded, size: compact ? 26 : 30),
              )
            : Icon(Icons.apps_rounded, color: const Color(0xFF0B5D96), size: compact ? 26 : 30);

    final copy = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (badge.isNotEmpty && !compact)
        Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: const Color(0xFFEAF4FF), borderRadius: BorderRadius.circular(999)),
          child: Text(badge, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF0B5D96), fontWeight: FontWeight.w800)),
        ),
      if (title.isNotEmpty)
        Text(
          title,
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: (compact ? Theme.of(context).textTheme.titleSmall : Theme.of(context).textTheme.titleMedium)?.copyWith(
                color: const Color(0xFF10264A),
                fontWeight: FontWeight.w900,
              ),
        ),
      if (subtitle.isNotEmpty && !minimal && !compactGrid) ...[
        const SizedBox(height: 4),
        Text(
          subtitle,
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF718096), height: 1.35),
        ),
      ],
      if (cta.isNotEmpty && !compact && !minimal) ...[
        const SizedBox(height: 8),
        Text(cta, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF0B5D96), fontWeight: FontWeight.w900)),
      ],
    ]);

    return Material(
      color: style == 'featured' ? const Color(0xFFFFFBF0) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        side: BorderSide(color: style == 'featured' ? const Color(0xFFE8C970) : const Color(0xFFE3E9F1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openDestination(context, card),
        child: Padding(
          padding: EdgeInsets.all(compact ? 9 : 12),
          child: listMode
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 72, child: Align(alignment: Alignment.topLeft, child: visual)),
                  const SizedBox(width: 12),
                  Expanded(child: copy),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Align(alignment: Alignment.centerLeft, child: visual),
                  SizedBox(height: compact ? 7 : 10),
                  copy,
                ]),
        ),
      ),
    );
  }
}

Future<void> _openDestination(BuildContext context, Map<String, dynamic> source) async {
  final type = source['destinationType']?.toString().trim().toLowerCase() ?? 'none';
  final value = source['destinationValue']?.toString().trim() ?? '';
  switch (type) {
    case 'page':
      if (value.isNotEmpty) context.push('/page/${Uri.encodeComponent(value)}');
      return;
    case 'exam':
      if (value.isNotEmpty) {
        context.push('/exam-details?id=${Uri.encodeQueryComponent(value)}');
      } else {
        context.go('/exams');
      }
      return;
    case 'exam_family':
      context.go('/exams');
      return;
    case 'test_series':
      if (value.isNotEmpty) {
        context.push('/test-series?id=${Uri.encodeQueryComponent(value)}');
      } else {
        context.push('/store?section=tests');
      }
      return;
    case 'learn':
    case 'native':
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
