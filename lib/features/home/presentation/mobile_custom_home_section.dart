import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_spacing.dart';
import '../domain/mobile_home_configuration.dart';

class MobileCustomHomeSectionView extends StatelessWidget {
  const MobileCustomHomeSectionView({
    super.key,
    required this.section,
  });

  final MobileCustomHomeSection section;

  Future<void> _open(BuildContext context, MobileHomeCard card) async {
    switch (card.destinationType) {
      case 'exam':
        if (card.destinationValue.trim().isNotEmpty) {
          context.push('/exam-details', extra: card.destinationValue.trim());
        } else {
          context.go('/exams');
        }
        return;
      case 'test_series':
        final value = card.destinationValue.trim();
        if (value.isNotEmpty) {
          context.push('/test-series?id=${Uri.encodeQueryComponent(value)}');
        } else {
          context.push('/store?section=tests');
        }
        return;
      case 'learn':
        final value = card.destinationValue.trim();
        context.go(value.startsWith('/') ? value : '/learn');
        return;
      case 'page':
        final value = card.destinationValue.trim();
        if (value.isNotEmpty) {
          context.push('/page/${Uri.encodeComponent(value)}');
        }
        return;
      case 'url':
        final uri = Uri.tryParse(card.destinationValue.trim());
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
    final cards = section.cards.where((card) => card.isActive).toList();
    if (!section.isVisible || cards.isEmpty) return const SizedBox.shrink();

    final header = Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _ConfigIcon(
                iconName: section.iconName,
                iconUrl: section.iconUrl,
                size: 22,
              ),
              if (section.iconName.isNotEmpty || section.iconUrl.isNotEmpty)
                const SizedBox(width: 8),
              Expanded(
                child: Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF10264A),
                      ),
                ),
              ),
            ],
          ),
          if (section.subtitle.trim().isNotEmpty) ...[
            const SizedBox(height: 3),
            Text(
              section.subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ],
        ],
      ),
    );

    Widget body;
    switch (section.layout) {
      case 'grid':
        body = GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.55,
          children: [
            for (final card in cards)
              _CustomCard(card: card, onTap: () => _open(context, card)),
          ],
        );
        break;
      case 'list':
        body = Column(
          children: [
            for (final card in cards) ...[
              _CustomCard(card: card, onTap: () => _open(context, card)),
              const SizedBox(height: 8),
            ],
          ],
        );
        break;
      case 'banner':
        body = _CustomCard(
          card: cards.first,
          onTap: () => _open(context, cards.first),
          banner: true,
        );
        break;
      default:
        body = SizedBox(
          height: 148,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => SizedBox(
              width: 255,
              child: _CustomCard(
                card: cards[index],
                onTap: () => _open(context, cards[index]),
              ),
            ),
          ),
        );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, body],
      ),
    );
  }
}

class _CustomCard extends StatelessWidget {
  const _CustomCard({
    required this.card,
    required this.onTap,
    this.banner = false,
  });

  final MobileHomeCard card;
  final VoidCallback onTap;
  final bool banner;

  @override
  Widget build(BuildContext context) {
    final hasAction = card.destinationType != 'none';
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasAction ? onTap : null,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE5EAF0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10264A).withValues(alpha: .05),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              if (card.imageUrl.trim().isNotEmpty)
                SizedBox(
                  width: banner ? 110 : 82,
                  height: double.infinity,
                  child: Image.network(
                    card.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _ConfigIcon(
                            iconName: card.iconName,
                            iconUrl: card.iconUrl,
                            size: 22,
                          ),
                          if (card.iconName.isNotEmpty ||
                              card.iconUrl.isNotEmpty)
                            const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              card.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ),
                          if (card.badge.trim().isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(left: 6),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF1FF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                card.badge,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1D5BBF),
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (card.subtitle.trim().isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Text(
                          card.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (card.ctaLabel.trim().isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          card.ctaLabel,
                          style: const TextStyle(
                            color: Color(0xFF0B5FB3),
                            fontWeight: FontWeight.w800,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfigIcon extends StatelessWidget {
  const _ConfigIcon({
    required this.iconName,
    required this.iconUrl,
    required this.size,
  });

  final String iconName;
  final String iconUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (iconUrl.trim().isNotEmpty) {
      return Image.network(
        iconUrl,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(_icon(iconName), size: size),
      );
    }
    if (iconName.trim().isEmpty) return const SizedBox.shrink();
    return Icon(_icon(iconName), size: size);
  }

  IconData _icon(String value) {
    switch (value.trim().toLowerCase()) {
      case 'school':
      case 'teaching':
        return Icons.school_rounded;
      case 'bank':
      case 'banking':
        return Icons.account_balance_rounded;
      case 'railway':
      case 'train':
        return Icons.train_rounded;
      case 'defence':
        return Icons.shield_rounded;
      case 'book':
      case 'learn':
        return Icons.menu_book_rounded;
      case 'quiz':
      case 'test':
        return Icons.quiz_rounded;
      case 'government':
      case 'govt':
        return Icons.apartment_rounded;
      case 'news':
      case 'current_affairs':
        return Icons.newspaper_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'brain':
        return Icons.psychology_alt_rounded;
      case 'bell':
        return Icons.notifications_rounded;
      case 'sparkles':
        return Icons.auto_awesome_rounded;
      case 'grid':
        return Icons.grid_view_rounded;
      default:
        return Icons.apps_rounded;
    }
  }
}
