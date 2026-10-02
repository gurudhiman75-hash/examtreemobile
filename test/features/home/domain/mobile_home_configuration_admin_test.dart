import 'package:examtree/features/home/domain/mobile_home_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses admin-driven sections, cards, settings and overrides', () {
    final config = MobileHomeConfiguration.fromJson({
      'sectionOrder': [
        'hero',
        'custom_quick_links',
        'exam_categories',
        'continue_learning',
      ],
      'sectionSettings': {
        'exam_categories': {
          'title': 'Top Exams',
          'subtitle': 'Choose your exam',
          'iconName': 'star',
          'layout': 'grid',
          'columns': 3,
          'isVisible': true,
        },
      },
      'itemOverrides': {
        'family-1': {
          'title': 'Punjab Exams',
          'iconUrl': 'https://example.com/icon.png',
        },
      },
      'customSections': [
        {
          'id': 'custom_quick_links',
          'title': 'Quick Links',
          'layout': 'grid',
          'columns': 3,
          'gap': 'compact',
          'style': 'featured',
          'isVisible': true,
          'cards': [
            {
              'id': 'card-1',
              'title': 'Current Affairs',
              'destinationType': 'learn',
              'destinationValue': '/learn',
              'span': 2,
              'style': 'compact',
              'isActive': true,
              'sortOrder': 1,
            },
          ],
        },
      ],
    });

    expect(config.sectionOrder, contains('custom_quick_links'));
    expect(config.customSections.single.title, 'Quick Links');
    expect(config.customSections.single.cards.single.title, 'Current Affairs');
    expect(config.customSections.single.columns, 3);
    expect(config.customSections.single.gap, 'compact');
    expect(config.customSections.single.style, 'featured');
    expect(config.customSections.single.cards.single.span, 2);
    expect(config.customSections.single.cards.single.style, 'compact');
    expect(config.settingFor('exam_categories').title, 'Top Exams');
    expect(config.settingFor('exam_categories').subtitle, 'Choose your exam');
    expect(config.settingFor('exam_categories').layout, 'grid');
    expect(config.settingFor('exam_categories').columns, 3);
    expect(config.overrideFor('family-1').title, 'Punjab Exams');
  });

  test('hidden custom sections are not added to the rendered order', () {
    final config = MobileHomeConfiguration.fromJson({
      'sectionOrder': ['hidden_section', 'hero'],
      'customSections': [
        {
          'id': 'hidden_section',
          'title': 'Hidden',
          'isVisible': false,
          'cards': [],
        },
      ],
    });

    expect(config.sectionOrder, isNot(contains('hidden_section')));
    expect(config.sectionOrder.first, 'hero');
  });
}
