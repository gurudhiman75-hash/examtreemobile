import '../domain/learn_lesson.dart';

const polityLearnSubject = LearnSubject(
  code: 'POL',
  title: 'Indian Polity',
  subtitle: 'Learn the Constitution, rights, institutions and governance for competitive exams.',
  iconName: 'account_balance',
  lessons: [
    LearnLesson(
      id: 'POL-LRN-001',
      subjectCode: 'POL',
      title: 'Making of the Indian Constitution',
      summary: 'How the Constituent Assembly was formed and how the Constitution was adopted.',
      estimatedMinutes: 6,
      sections: [
        LearnLessonSection(
          heading: 'Concept',
          paragraphs: [
            'India’s Constitution was prepared by the Constituent Assembly. The demand for such an assembly developed gradually during the freedom struggle.',
            'The Constituent Assembly was formed under the Cabinet Mission Plan of 1946. Representatives of the provinces were elected indirectly by members of the provincial legislative assemblies.',
            'The Assembly first met on 9 December 1946. Dr. Sachchidananda Sinha served as the temporary chairman. On 11 December 1946, Dr. Rajendra Prasad was elected its permanent President.',
            'The Drafting Committee was formed on 29 August 1947 with Dr. B. R. Ambedkar as its Chairman. The Constitution was adopted on 26 November 1949 and came into force on 26 January 1950.',
          ],
        ),
        LearnLessonSection(
          heading: 'Key points',
          paragraphs: const [],
          points: [
            'Constituent Assembly formed under the Cabinet Mission Plan, 1946.',
            'First meeting: 9 December 1946.',
            'Temporary Chairman: Dr. Sachchidananda Sinha.',
            'Permanent President: Dr. Rajendra Prasad.',
            'Drafting Committee formed: 29 August 1947.',
            'Drafting Committee Chairman: Dr. B. R. Ambedkar.',
            'Constitution adopted: 26 November 1949.',
            'Constitution came into force: 26 January 1950.',
          ],
        ),
        LearnLessonSection(
          heading: 'Dates to remember',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Event', 'Date'],
            rows: [
              ['First meeting of Constituent Assembly', '9 Dec 1946'],
              ['Rajendra Prasad elected President', '11 Dec 1946'],
              ['Drafting Committee formed', '29 Aug 1947'],
              ['Constitution adopted', '26 Nov 1949'],
              ['Constitution came into force', '26 Jan 1950'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Remember',
          paragraphs: [
            '26 November 1949 means the Constitution was adopted. 26 January 1950 means it came into force. These two dates are frequently confused in exams.',
          ],
        ),
      ],
      quickRevision: [
        'Cabinet Mission Plan → Constituent Assembly.',
        'First meeting → 9 December 1946.',
        'Drafting Committee → 29 August 1947, chaired by B. R. Ambedkar.',
        'Adopted → 26 November 1949.',
        'In force → 26 January 1950.',
      ],
      examFocus: [
        'Dates connected with the Constituent Assembly.',
        'Chairpersons and the Drafting Committee.',
        'Difference between adoption and commencement.',
      ],
      practiceTags: ['constituent-assembly', 'making-of-constitution'],
    ),
    LearnLesson(
      id: 'POL-LRN-002',
      subjectCode: 'POL',
      title: 'Constituent Assembly',
      summary: 'Composition, important officers, committees and major milestones of the Constituent Assembly.',
      estimatedMinutes: 8,
      sections: [
        LearnLessonSection(
          heading: 'How it was constituted',
          paragraphs: [
            'The Constituent Assembly was created under the Cabinet Mission Plan. Its members from British Indian provinces were chosen indirectly by the provincial legislative assemblies, while princely states were allotted seats separately.',
            'The original strength of the Assembly was 389. After Partition, the strength of the Constituent Assembly of India was reduced to 299.',
          ],
        ),
        LearnLessonSection(
          heading: 'Important office-bearers',
          paragraphs: const [],
          points: [
            'Temporary Chairman: Dr. Sachchidananda Sinha.',
            'President: Dr. Rajendra Prasad.',
            'Vice-President: H. C. Mookherjee.',
            'Constitutional Adviser: B. N. Rau.',
            'Chairman of the Drafting Committee: Dr. B. R. Ambedkar.',
          ],
        ),
        LearnLessonSection(
          heading: 'Important committees',
          paragraphs: [
            'The Assembly worked through several committees. Competitive exams often ask who chaired a particular committee.',
          ],
          table: LearnLessonTable(
            headers: ['Committee', 'Chairman'],
            rows: [
              ['Drafting Committee', 'B. R. Ambedkar'],
              ['Union Powers Committee', 'Jawaharlal Nehru'],
              ['Union Constitution Committee', 'Jawaharlal Nehru'],
              ['Provincial Constitution Committee', 'Vallabhbhai Patel'],
              ['Advisory Committee on Fundamental Rights, Minorities and Tribal Areas', 'Vallabhbhai Patel'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Time taken',
          paragraphs: [
            'The Constituent Assembly took 2 years, 11 months and 18 days to complete the Constitution. It held 11 sessions during this period.',
          ],
        ),
      ],
      quickRevision: [
        'Original strength: 389; after Partition: 299.',
        'President: Rajendra Prasad.',
        'Constitutional Adviser: B. N. Rau.',
        'Drafting Committee Chairman: B. R. Ambedkar.',
        'Time taken: 2 years, 11 months, 18 days.',
      ],
      examFocus: [
        'Original and post-Partition strength.',
        'Office-bearers of the Assembly.',
        'Committee-chairman matching questions.',
      ],
      practiceTags: ['constituent-assembly', 'constitution-committees'],
    ),
    LearnLesson(
      id: 'POL-LRN-003',
      subjectCode: 'POL',
      title: 'Preamble',
      summary: 'Meaning, keywords, constitutional status and amendment of the Preamble.',
      estimatedMinutes: 7,
      sections: [
        LearnLessonSection(
          heading: 'What is the Preamble?',
          paragraphs: [
            'The Preamble is the introductory statement of the Constitution. It expresses the source of authority of the Constitution, the nature of the Indian State and the broad objectives that the Constitution seeks to secure.',
            'It begins with the words “We, the People of India”, showing that the Constitution derives its authority from the people.',
          ],
        ),
        LearnLessonSection(
          heading: 'Keywords',
          paragraphs: const [],
          points: [
            'Sovereign: India is free to conduct its internal and external affairs.',
            'Socialist: the State seeks social and economic justice.',
            'Secular: the State does not establish an official religion and treats religions equally.',
            'Democratic: political authority ultimately rests with the people.',
            'Republic: the head of the State is elected, directly or indirectly, and is not a hereditary monarch.',
          ],
        ),
        LearnLessonSection(
          heading: 'Objectives',
          paragraphs: const [],
          points: [
            'Justice — social, economic and political.',
            'Liberty — of thought, expression, belief, faith and worship.',
            'Equality — of status and opportunity.',
            'Fraternity — assuring the dignity of the individual and the unity and integrity of the nation.',
          ],
        ),
        LearnLessonSection(
          heading: '42nd Constitutional Amendment',
          paragraphs: [
            'The words “Socialist”, “Secular” and “Integrity” were added to the Preamble by the 42nd Constitutional Amendment Act, 1976.',
          ],
        ),
      ],
      quickRevision: [
        'Starts with: We, the People of India.',
        'Nature of State: Sovereign, Socialist, Secular, Democratic, Republic.',
        'Objectives: Justice, Liberty, Equality and Fraternity.',
        '42nd Amendment added Socialist, Secular and Integrity.',
      ],
      examFocus: [
        'Words added by the 42nd Amendment.',
        'Meaning of Sovereign, Secular, Democratic and Republic.',
        'Justice-Liberty-Equality-Fraternity sequence and wording.',
      ],
      practiceTags: ['preamble'],
    ),
    LearnLesson(
      id: 'POL-LRN-004',
      subjectCode: 'POL',
      title: 'Union and its Territory',
      summary: 'Articles 1–4 and the constitutional framework for states and territories.',
      estimatedMinutes: 6,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-005',
      subjectCode: 'POL',
      title: 'Citizenship',
      summary: 'Citizenship at the commencement of the Constitution and the Citizenship Act.',
      estimatedMinutes: 7,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-006',
      subjectCode: 'POL',
      title: 'Fundamental Rights — Overview',
      summary: 'Articles 12–35 and the structure of Fundamental Rights.',
      estimatedMinutes: 6,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-007',
      subjectCode: 'POL',
      title: 'Right to Equality',
      summary: 'Articles 14–18 explained for competitive exams.',
      estimatedMinutes: 7,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-008',
      subjectCode: 'POL',
      title: 'Right to Freedom',
      summary: 'Articles 19–22 and the protections they provide.',
      estimatedMinutes: 8,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-009',
      subjectCode: 'POL',
      title: 'Right against Exploitation',
      summary: 'Articles 23–24 on trafficking, forced labour and child labour.',
      estimatedMinutes: 5,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-010',
      subjectCode: 'POL',
      title: 'Freedom of Religion',
      summary: 'Articles 25–28 and constitutional religious freedom.',
      estimatedMinutes: 6,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-011',
      subjectCode: 'POL',
      title: 'Cultural & Educational Rights',
      summary: 'Articles 29–30 and protection of cultural and educational interests.',
      estimatedMinutes: 5,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-012',
      subjectCode: 'POL',
      title: 'Constitutional Remedies',
      summary: 'Article 32 and the five constitutional writs.',
      estimatedMinutes: 8,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-013',
      subjectCode: 'POL',
      title: 'Directive Principles of State Policy',
      summary: 'Articles 36–51 and the major categories of Directive Principles.',
      estimatedMinutes: 8,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
    LearnLesson(
      id: 'POL-LRN-014',
      subjectCode: 'POL',
      title: 'Fundamental Duties',
      summary: 'Article 51A, origin and important facts about Fundamental Duties.',
      estimatedMinutes: 6,
      sections: [],
      quickRevision: [],
      examFocus: [],
    ),
  ],
);

LearnLesson? polityLessonById(String id) {
  final normalized = id.trim().toUpperCase();
  for (final lesson in polityLearnSubject.lessons) {
    if (lesson.id == normalized) return lesson;
  }
  return null;
}
