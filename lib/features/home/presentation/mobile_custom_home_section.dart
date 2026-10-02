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
    final value = card.destinationValue.trim();
    switch (card.destinationType) {
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
        context.go(value.startsWith('/') ? value : '/learn');
        return;
      case 'page':
        if (value.isNotEmpty) {
          context.push('/page/${Uri.encodeComponent(value)}');
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
    final cards = section.cards.where((card) => card.isActive).toList();
    if (!section.isVisible || cards.isEmpty) return const SizedBox.shrink();

    final gap = switch (section.gap) {
      'compact' => 6.0,
      'relaxed' => 14.0,
      _ => 10.0,
    };
    final columns = section.columns.clamp(1, 4);

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
                    height: 1.35,
                  ),
            ),
          ],
        ],
      ),
    );

    Widget body;
    switch (section.layout) {
      case 'grid':
        body = LayoutBuilder(
          builder: (context, constraints) {
            final unit =
                (constraints.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final card in cards)
                  SizedBox(
                    width: unit * card.span.clamp(1, columns) +
                        gap * (card.span.clamp(1, columns) - 1),
                    child: _CustomCard(
                      card: card,
                      sectionStyle: section.style,
                      compactGrid: columns >= 3 && card.span == 1,
                      onTap: () => _open(context, card),
                    ),
                  ),
              ],
            );
          },
        );
        break;
      case 'list':
        body = Column(
          children: [
            for (var index = 0; index < cards.length; index++) ...[
              _CustomCard(
                card: cards[index],
                sectionStyle: section.style,
                listMode: true,
                onTap: () => _open(context, cards[index]),
              ),
              if (index != cards.length - 1) SizedBox(height: gap),
            ],
          ],
        );
        break;
      case 'banner':
        body = _CustomCard(
          card: cards.first,
          sectionStyle: section.style,
          bannerMode: true,
          onTap: () => _open(context, cards.first),
        );
        break;
      default:
        final compact = section.style == 'compact';
        body = SizedBox(
          height: compact ? 142 : 178,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (_, __) => SizedBox(width: gap),
            itemBuilder: (context, index) => SizedBox(
              width: compact ? 176 : 220,
              child: _CustomCard(
                card: cards[index],
                sectionStyle: section.style,
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
    required this.sectionStyle,
    required this.onTap,
    this.listMode = false,
    this.bannerMode = false,
    this.compactGrid = false,
  });

  final MobileHomeCard card;
  final String sectionStyle;
  final VoidCallback onTap;
  final bool listMode;
  final bool bannerMode;
  final bool compactGrid;

  @override
  Widget build(BuildContext context) {
    final overrideStyle = card.style.trim().isEmpty ? 'default' : card.style;
    final style = overrideStyle == 'default' ? sectionStyle : overrideStyle;
    final compact = style == 'compact' || compactGrid;
    final minimal = style == 'minimal';
    final imageLed = style == 'image' || style == 'featured';
    final hasAction = card.destinationType != 'none';
    final imageUrl = card.imageUrl.trim();
    final hasExplicitIcon =
        card.iconUrl.trim().isNotEmpty || card.iconName.trim().isNotEmpty;

    Widget visual;
    if (imageUrl.isNotEmpty && (imageLed || bannerMode || !hasExplicitIcon)) {
      visual = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          height: bannerMode ? 150 : compact ? 58 : 84,
          width: bannerMode ? double.infinity : listMode ? 72 : double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _ConfigIcon(
            iconName: card.iconName.isEmpty ? 'grid' : card.iconName,
            iconUrl: card.iconUrl,
            size: compact ? 30 : 42,
          ),
        ),
      );
    } else {
      visual = _ConfigIcon(
        iconName: card.iconName.isEmpty ? 'grid' : card.iconName,
        iconUrl: card.iconUrl,
        size: compact ? 30 : 42,
      );
    }

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (card.badge.trim().isNotEmpty && !compact)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              card.badge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: const Color(0xFF0B5D96),
                    fontWeight: FontWeight.w800,
                  ),
            ),
          ),
        Text(
          card.title,
          maxLines: compact ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: (compact
                  ? Theme.of(context).textTheme.titleSmall
                  : Theme.of(context).textTheme.titleMedium)
              ?.copyWith(
            color: const Color(0xFF10264A),
            fontWeight: FontWeight.w900,
          ),
        ),
        if (card.subtitle.trim().isNotEmpty && !minimal && !compactGrid) ...[
          const SizedBox(height: 4),
          Text(
            card.subtitle,
            maxLines: compact ? 2 : 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF718096),
                  height: 1.35,
                ),
          ),
        ],
        if (card.ctaLabel.trim().isNotEmpty && !compact && !minimal) ...[
          const SizedBox(height: 8),
          Text(
            card.ctaLabel,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF0B5D96),
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ],
    );

    return Material(
      color: style == 'featured' ? const Color(0xFFFFFBF0) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        side: BorderSide(
          color: style == 'featured'
              ? const Color(0xFFE8C970)
              : const Color(0xFFE3E9F1),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: hasAction ? onTap : null,
        child: Padding(
          padding: EdgeInsets.all(compact ? 9 : 12),
          child: listMode
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 72,
                      child: Align(alignment: Alignment.topLeft, child: visual),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: copy),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(alignment: Alignment.centerLeft, child: visual),
                    SizedBox(height: compact ? 7 : 10),
                    copy,
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
    return Icon(_icon(iconName), size: size, color: const Color(0xFF0B5D96));
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
