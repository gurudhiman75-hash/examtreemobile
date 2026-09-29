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
      summary: 'Articles 1–4 and how the Constitution deals with states, territories and boundary changes.',
      estimatedMinutes: 7,
      sections: [
        LearnLessonSection(
          heading: 'Articles 1–4',
          paragraphs: [
            'Part I of the Constitution deals with the Union and its territory. Article 1 describes India, that is Bharat, as a Union of States and explains what forms the territory of India.',
            'Articles 2 and 3 deal with the admission or establishment of new States and with changes to the area, boundaries or names of existing States.',
          ],
        ),
        LearnLessonSection(
          heading: 'What Article 3 allows Parliament to do',
          paragraphs: const [],
          points: [
            'Form a new State by separating territory from an existing State.',
            'Unite two or more States, or parts of States, to form a new State.',
            'Increase or reduce the area of a State.',
            'Alter the boundaries of a State.',
            'Alter the name of a State.',
          ],
        ),
        LearnLessonSection(
          heading: 'Role of the President and State Legislature',
          paragraphs: [
            'A Bill for a matter covered by Article 3 can be introduced in Parliament only on the recommendation of the President. When the proposal affects the area, boundaries or name of a State, the President refers it to that State Legislature for its views within the specified period.',
            'The State Legislature gives its views, but its consent is not made a constitutional requirement for Parliament to pass the law.',
          ],
        ),
        LearnLessonSection(
          heading: 'Article 4',
          paragraphs: [
            'A law made under Articles 2 or 3 may make necessary changes to the First and Fourth Schedules and may contain supplemental, incidental and consequential provisions. Article 4 states that such a law is not treated as a constitutional amendment for the purpose of Article 368.',
          ],
        ),
      ],
      quickRevision: [
        'Article 1: India, that is Bharat, is a Union of States.',
        'Articles 2–3: new States and changes to existing States.',
        'Article 3 Bill needs the President’s recommendation.',
        'Affected State Legislature is asked for its views; consent is not constitutionally required.',
        'Article 4 laws are not treated as Article 368 constitutional amendments.',
      ],
      examFocus: [
        'Article-number matching: 1, 2, 3 and 4.',
        'Difference between the President’s recommendation and the State Legislature’s views.',
        'Whether a law under Articles 2–3 is an Article 368 amendment.',
      ],
      practiceTags: ['union-territory', 'articles-1-4', 'state-reorganisation'],
    ),
    LearnLesson(
      id: 'POL-LRN-005',
      subjectCode: 'POL',
      title: 'Citizenship',
      summary: 'Articles 5–11, citizenship at the commencement of the Constitution and the Citizenship Act, 1955.',
      estimatedMinutes: 8,
      sections: [
        LearnLessonSection(
          heading: 'Citizenship in the Constitution',
          paragraphs: [
            'Part II of the Constitution contains Articles 5–11. These provisions mainly dealt with citizenship at the commencement of the Constitution and certain migration situations connected with Partition.',
            'Article 11 gives Parliament the power to make laws on acquisition and termination of citizenship and on other citizenship matters.',
          ],
        ),
        LearnLessonSection(
          heading: 'Articles 5–11 at a glance',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Article', 'Focus'],
            rows: [
              ['5', 'Citizenship at commencement'],
              ['6', 'Certain migrants to India from Pakistan'],
              ['7', 'Certain migrants to Pakistan'],
              ['8', 'Certain persons of Indian origin residing outside India'],
              ['9', 'Voluntary acquisition of foreign citizenship'],
              ['10', 'Continuance of citizenship rights'],
              ['11', 'Parliament’s power to regulate citizenship by law'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Citizenship Act, 1955',
          paragraphs: [
            'Parliament enacted the Citizenship Act, 1955. The Act provides statutory routes for acquisition of citizenship and also provides for loss of citizenship.',
          ],
          points: [
            'Acquisition: by birth.',
            'Acquisition: by descent.',
            'Acquisition: by registration.',
            'Acquisition: by naturalisation.',
            'Acquisition: by incorporation of territory.',
            'Loss: renunciation, termination and deprivation.',
          ],
        ),
        LearnLessonSection(
          heading: 'OCI is not full Indian citizenship',
          paragraphs: [
            'The Citizenship Act separately provides for registration as an Overseas Citizen of India Cardholder. For exam purposes, do not treat OCI status as the same thing as ordinary Indian citizenship.',
          ],
        ),
      ],
      quickRevision: [
        'Part II = Articles 5–11.',
        'Article 11 empowers Parliament to regulate citizenship by law.',
        'Citizenship Act, 1955 lists five main modes of acquisition.',
        'Renunciation, termination and deprivation are modes of loss under the Act.',
        'OCI Cardholder status is distinct from ordinary Indian citizenship.',
      ],
      examFocus: [
        'Article-number questions from 5–11.',
        'Five modes of acquisition under the Citizenship Act, 1955.',
        'Three modes of loss: renunciation, termination and deprivation.',
      ],
      practiceTags: ['citizenship', 'articles-5-11', 'citizenship-act-1955'],
    ),
    LearnLesson(
      id: 'POL-LRN-006',
      subjectCode: 'POL',
      title: 'Fundamental Rights — Overview',
      summary: 'Part III, Articles 12–35 and the structure of the Fundamental Rights chapter.',
      estimatedMinutes: 8,
      sections: [
        LearnLessonSection(
          heading: 'Where Fundamental Rights appear',
          paragraphs: [
            'Fundamental Rights are contained in Part III of the Constitution. Part III begins with Article 12, which defines “the State” for this Part, and Article 13, which deals with laws inconsistent with Fundamental Rights.',
            'The enforceable rights are then organised into groups such as equality, freedom, protection against exploitation, freedom of religion, cultural and educational rights, and constitutional remedies.',
          ],
        ),
        LearnLessonSection(
          heading: 'The six broad groups',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Right', 'Articles'],
            rows: [
              ['Right to Equality', '14–18'],
              ['Right to Freedom', '19–22'],
              ['Right against Exploitation', '23–24'],
              ['Right to Freedom of Religion', '25–28'],
              ['Cultural and Educational Rights', '29–30'],
              ['Right to Constitutional Remedies', '32'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Articles 12 and 13',
          paragraphs: [
            'Article 12 gives an extended meaning to “the State” for Part III. Article 13 provides that laws inconsistent with or in derogation of Fundamental Rights are void to the extent of the inconsistency.',
          ],
        ),
        LearnLessonSection(
          heading: 'Article 32',
          paragraphs: [
            'Article 32 guarantees the right to move the Supreme Court for enforcement of the rights conferred by Part III. The Constitution authorises the Supreme Court to issue directions, orders or writs for this purpose.',
          ],
        ),
      ],
      quickRevision: [
        'Fundamental Rights are in Part III.',
        'Part III spans Articles 12–35.',
        'Article 12 defines “the State” for Part III.',
        'Article 13 deals with laws inconsistent with Fundamental Rights.',
        'Article 32 provides the right to approach the Supreme Court for enforcement of Part III rights.',
      ],
      examFocus: [
        'Part III and its article range.',
        'Matching each Fundamental Right group with its article range.',
        'Purpose of Articles 12, 13 and 32.',
      ],
      practiceTags: ['fundamental-rights', 'part-iii', 'articles-12-35'],
    ),
    LearnLesson(
      id: 'POL-LRN-007',
      subjectCode: 'POL',
      title: 'Right to Equality',
      summary: 'Articles 14–18: equality before law, non-discrimination, public employment, untouchability and titles.',
      estimatedMinutes: 8,
      sections: [
        LearnLessonSection(
          heading: 'Articles 14–18',
          paragraphs: [
            'The Right to Equality is mainly contained in Articles 14 to 18. These provisions deal with equality before law, discrimination, equality of opportunity in public employment, abolition of untouchability and abolition of titles.',
          ],
          table: LearnLessonTable(
            headers: ['Article', 'Core idea'],
            rows: [
              ['14', 'Equality before law and equal protection of laws'],
              ['15', 'Prohibition of discrimination on specified grounds'],
              ['16', 'Equality of opportunity in public employment'],
              ['17', 'Abolition of untouchability'],
              ['18', 'Abolition of titles'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Article 14',
          paragraphs: [
            'Article 14 says that the State shall not deny to any person equality before the law or the equal protection of the laws within the territory of India.',
            'A common exam trap is that Article 14 uses the word “person”, not only “citizen”.',
          ],
        ),
        LearnLessonSection(
          heading: 'Articles 15 and 16',
          paragraphs: [
            'Article 15 prohibits the State from discriminating against citizens only on specified grounds such as religion, race, caste, sex or place of birth, while also permitting constitutionally specified special provisions.',
            'Article 16 deals specifically with equality of opportunity in matters of public employment and also contains constitutional provisions allowing reservation in specified circumstances.',
          ],
        ),
        LearnLessonSection(
          heading: 'Articles 17 and 18',
          paragraphs: [
            'Article 17 abolishes untouchability and forbids its practice in any form. Article 18 abolishes titles, subject to the constitutional exceptions stated in that Article, including military or academic distinctions.',
          ],
        ),
      ],
      quickRevision: [
        '14 = equality before law and equal protection.',
        '15 = non-discrimination.',
        '16 = public employment.',
        '17 = abolition of untouchability.',
        '18 = abolition of titles.',
      ],
      examFocus: [
        'Correct article-number matching from 14–18.',
        'Article 14 applies to “any person”.',
        'Difference between Articles 15 and 16.',
        'Military and academic distinctions under Article 18.',
      ],
      practiceTags: ['right-to-equality', 'articles-14-18'],
    ),
    LearnLesson(
      id: 'POL-LRN-008',
      subjectCode: 'POL',
      title: 'Right to Freedom',
      summary: 'Articles 19–22: six freedoms and constitutional protections relating to criminal law, life, education and arrest.',
      estimatedMinutes: 10,
      sections: [
        LearnLessonSection(
          heading: 'Article 19 — six freedoms',
          paragraphs: [
            'Article 19 guarantees specified freedoms to citizens. These freedoms are not absolute; the Constitution permits reasonable restrictions on constitutionally stated grounds.',
          ],
          points: [
            'Freedom of speech and expression.',
            'Freedom to assemble peaceably and without arms.',
            'Freedom to form associations or unions or co-operative societies.',
            'Freedom to move freely throughout the territory of India.',
            'Freedom to reside and settle in any part of the territory of India.',
            'Freedom to practise any profession, or to carry on any occupation, trade or business.',
          ],
        ),
        LearnLessonSection(
          heading: 'Article 20 — protection in criminal cases',
          paragraphs: const [],
          points: [
            'Protection against conviction under an ex post facto criminal law.',
            'Protection against being prosecuted and punished more than once for the same offence.',
            'Protection against being compelled to be a witness against oneself.',
          ],
        ),
        LearnLessonSection(
          heading: 'Article 21 and Article 21A',
          paragraphs: [
            'Article 21 protects life and personal liberty except according to procedure established by law.',
            'Article 21A provides for free and compulsory education for children of the age of six to fourteen years in the manner determined by law.',
          ],
        ),
        LearnLessonSection(
          heading: 'Article 22 — arrest and detention',
          paragraphs: [
            'Article 22 contains safeguards relating to arrest and detention. A person arrested in ordinary circumstances must be informed of the grounds of arrest, allowed to consult and be defended by a legal practitioner of choice, and produced before the nearest magistrate within twenty-four hours, excluding necessary journey time.',
            'The Article also contains separate provisions concerning preventive detention, so exam questions may distinguish ordinary arrest safeguards from preventive-detention rules.',
          ],
        ),
      ],
      quickRevision: [
        '19 = six freedoms of citizens.',
        '20 = criminal-law protections.',
        '21 = life and personal liberty.',
        '21A = free and compulsory education for ages 6–14.',
        '22 = safeguards against arrest and detention, plus preventive-detention provisions.',
      ],
      examFocus: [
        'The six current freedoms under Article 19.',
        'Three protections under Article 20.',
        'Difference between Articles 21 and 21A.',
        'Twenty-four-hour rule under Article 22 and its exception structure.',
      ],
      practiceTags: ['right-to-freedom', 'articles-19-22'],
    ),
    LearnLesson(
      id: 'POL-LRN-009',
      subjectCode: 'POL',
      title: 'Right against Exploitation',
      summary: 'Articles 23–24 on trafficking, forced labour and hazardous employment of children.',
      estimatedMinutes: 6,
      sections: [
        LearnLessonSection(
          heading: 'Article 23',
          paragraphs: [
            'Article 23 prohibits traffic in human beings, begar and other similar forms of forced labour. A violation is an offence punishable according to law.',
            'The Article allows the State to impose compulsory service for public purposes, but in doing so the State cannot discriminate only on grounds of religion, race, caste or class.',
          ],
        ),
        LearnLessonSection(
          heading: 'Article 24',
          paragraphs: [
            'Article 24 prohibits employment of a child below fourteen years in any factory or mine or in any other hazardous employment.',
          ],
        ),
        LearnLessonSection(
          heading: 'Do not confuse the two',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Article', 'Exam cue'],
            rows: [
              ['23', 'Trafficking, begar and forced labour'],
              ['24', 'Children below 14 in factory, mine or hazardous employment'],
            ],
          ),
        ),
      ],
      quickRevision: [
        '23 = trafficking and forced labour.',
        '24 = hazardous employment of children below 14.',
        'Compulsory public service is not barred by Article 23, subject to its non-discrimination rule.',
      ],
      examFocus: [
        'Difference between Articles 23 and 24.',
        'Meaning of begar/forced labour in Article 23.',
        'Age and workplace wording used in Article 24.',
      ],
      practiceTags: ['right-against-exploitation', 'articles-23-24'],
    ),
    LearnLesson(
      id: 'POL-LRN-010',
      subjectCode: 'POL',
      title: 'Freedom of Religion',
      summary: 'Articles 25–28: conscience, religious practice, religious affairs, taxation and instruction.',
      estimatedMinutes: 8,
      sections: [
        LearnLessonSection(
          heading: 'Articles 25–28',
          paragraphs: [
            'The Constitution protects freedom of religion through Articles 25 to 28. These rights operate subject to constitutional limits such as public order, morality and health where stated.',
          ],
          table: LearnLessonTable(
            headers: ['Article', 'Core idea'],
            rows: [
              ['25', 'Freedom of conscience; profess, practise and propagate religion'],
              ['26', 'Freedom to manage religious affairs'],
              ['27', 'Freedom from taxation specifically appropriated for promotion or maintenance of a particular religion'],
              ['28', 'Rules on religious instruction or worship in certain educational institutions'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Article 25',
          paragraphs: [
            'Article 25 applies to all persons, not only citizens. It protects freedom of conscience and the right freely to profess, practise and propagate religion, subject to the conditions written in the Article.',
            'For exam purposes, remember the constitutional explanation that wearing and carrying kirpans is included in the profession of the Sikh religion.',
          ],
        ),
        LearnLessonSection(
          heading: 'Articles 26–28',
          paragraphs: [
            'Article 26 protects specified rights of religious denominations or sections of them. Article 27 deals with taxes whose proceeds are specifically appropriated for promotion or maintenance of a particular religion.',
            'Article 28 distinguishes between educational institutions wholly maintained from State funds and certain institutions administered by the State but established under an endowment or trust requiring religious instruction.',
          ],
        ),
      ],
      quickRevision: [
        '25 = conscience; profess, practise and propagate.',
        '26 = manage religious affairs.',
        '27 = specified tax protection.',
        '28 = religious instruction/worship in educational institutions.',
        'Article 25 expressly recognises carrying kirpans in relation to Sikh religion.',
      ],
      examFocus: [
        'Article-number matching from 25–28.',
        'Article 25 applies to all persons.',
        'Kirpan explanation under Article 25.',
        'Difference between Articles 27 and 28.',
      ],
      practiceTags: ['freedom-of-religion', 'articles-25-28'],
    ),
    LearnLesson(
      id: 'POL-LRN-011',
      subjectCode: 'POL',
      title: 'Cultural & Educational Rights',
      summary: 'Articles 29–30 and protection of language, script, culture and minority educational institutions.',
      estimatedMinutes: 7,
      sections: [
        LearnLessonSection(
          heading: 'Article 29',
          paragraphs: [
            'Article 29 protects the right of any section of citizens having a distinct language, script or culture of its own to conserve it.',
            'Its second clause says that no citizen shall be denied admission into an educational institution maintained by the State or receiving State aid only on grounds of religion, race, caste, language or any of them.',
          ],
        ),
        LearnLessonSection(
          heading: 'Article 30',
          paragraphs: [
            'Article 30 gives minorities, whether based on religion or language, the right to establish and administer educational institutions of their choice.',
          ],
        ),
        LearnLessonSection(
          heading: 'Common exam confusion',
          paragraphs: [
            'Article 29(1) is worded for “any section of the citizens” with a distinct language, script or culture. Article 30 specifically uses the expression minorities based on religion or language.',
          ],
          table: LearnLessonTable(
            headers: ['Article', 'Remember'],
            rows: [
              ['29', 'Conservation of distinct language, script or culture; admission protection'],
              ['30', 'Minority educational institutions'],
            ],
          ),
        ),
      ],
      quickRevision: [
        '29(1) = conserve distinct language, script or culture.',
        '29(2) = admission protection in State-maintained/aided institutions.',
        '30 = religious or linguistic minorities can establish and administer educational institutions.',
      ],
      examFocus: [
        'Article 29 is not worded only for minorities.',
        'Religion/language minorities under Article 30.',
        'Difference between cultural conservation and minority institution rights.',
      ],
      practiceTags: ['cultural-educational-rights', 'articles-29-30'],
    ),
    LearnLesson(
      id: 'POL-LRN-012',
      subjectCode: 'POL',
      title: 'Constitutional Remedies',
      summary: 'Article 32 and the major constitutional writs used for enforcement of Fundamental Rights.',
      estimatedMinutes: 9,
      sections: [
        LearnLessonSection(
          heading: 'Article 32',
          paragraphs: [
            'Article 32 guarantees the right to move the Supreme Court by appropriate proceedings for enforcement of the rights conferred by Part III.',
            'The Supreme Court may issue directions, orders or writs, including writs in the nature of habeas corpus, mandamus, prohibition, quo warranto and certiorari, for enforcement of Fundamental Rights.',
          ],
        ),
        LearnLessonSection(
          heading: 'Five writs at a glance',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Writ', 'Simple exam meaning'],
            rows: [
              ['Habeas Corpus', 'Produce a detained person before the court; tests legality of detention'],
              ['Mandamus', 'Command to a public authority to perform a public/legal duty'],
              ['Prohibition', 'Higher court stops a lower court/tribunal from exceeding jurisdiction before completion'],
              ['Certiorari', 'Higher court can quash an order/proceeding of a lower court/tribunal on recognised grounds'],
              ['Quo Warranto', 'Questions the authority by which a person holds a public office'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Article 32 and High Courts',
          paragraphs: [
            'Article 32 concerns the Supreme Court and enforcement of Part III rights. High Courts separately have writ jurisdiction under Article 226, which is broader in text because it extends to enforcement of Fundamental Rights and “for any other purpose”.',
          ],
        ),
      ],
      quickRevision: [
        '32 = Supreme Court remedy for enforcement of Fundamental Rights.',
        'Habeas Corpus = illegal detention.',
        'Mandamus = perform public duty.',
        'Prohibition = stop excess jurisdiction.',
        'Certiorari = quash on recognised grounds.',
        'Quo Warranto = authority to hold public office.',
      ],
      examFocus: [
        'Match each writ with its function.',
        'Article 32 versus Article 226.',
        'Which writ relates to detention or public office.',
      ],
      practiceTags: ['constitutional-remedies', 'article-32', 'writs'],
    ),
    LearnLesson(
      id: 'POL-LRN-013',
      subjectCode: 'POL',
      title: 'Directive Principles of State Policy',
      summary: 'Part IV, Articles 36–51: non-justiciable principles fundamental in governance.',
      estimatedMinutes: 10,
      sections: [
        LearnLessonSection(
          heading: 'Nature of DPSPs',
          paragraphs: [
            'Directive Principles of State Policy are contained in Part IV of the Constitution, Articles 36 to 51.',
            'Article 37 says that these provisions are not enforceable by any court, but the principles are nevertheless fundamental in the governance of the country and it is the duty of the State to apply them in making laws.',
          ],
        ),
        LearnLessonSection(
          heading: 'High-yield Articles',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Article', 'Exam focus'],
            rows: [
              ['38', 'Social order promoting welfare and reducing inequalities'],
              ['39', 'Important socio-economic policy principles'],
              ['39A', 'Equal justice and free legal aid'],
              ['40', 'Organisation of village panchayats'],
              ['44', 'Uniform civil code for citizens'],
              ['45', 'Early childhood care and education for children below six years'],
              ['46', 'Educational/economic interests of weaker sections, especially SCs and STs'],
              ['47', 'Nutrition, standard of living and public health'],
              ['48A', 'Environment, forests and wildlife'],
              ['50', 'Separation of judiciary from executive in State public services'],
              ['51', 'International peace and security'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'How exams classify them',
          paragraphs: [
            'Textbooks often group Directive Principles into broad socialistic, Gandhian and liberal-intellectual categories for study. These labels are study classifications; the Constitution itself does not divide Part IV under those three headings.',
          ],
        ),
      ],
      quickRevision: [
        'DPSPs = Part IV, Articles 36–51.',
        'Article 37 = not enforceable by courts, but fundamental in governance.',
        '39A = legal aid; 40 = village panchayats; 44 = uniform civil code.',
        '48A = environment; 50 = judiciary-executive separation; 51 = international peace.',
      ],
      examFocus: [
        'Part and article range of DPSPs.',
        'Article 37 and non-justiciability.',
        'Matching high-frequency DPSP Articles with their subjects.',
        'Conventional classifications are not headings used by the Constitution itself.',
      ],
      practiceTags: ['directive-principles', 'dpsp', 'articles-36-51'],
    ),
    LearnLesson(
      id: 'POL-LRN-014',
      subjectCode: 'POL',
      title: 'Fundamental Duties',
      summary: 'Part IVA and Article 51A: the eleven Fundamental Duties of citizens.',
      estimatedMinutes: 8,
      sections: [
        LearnLessonSection(
          heading: 'Where they appear',
          paragraphs: [
            'Fundamental Duties are contained in Part IVA of the Constitution under Article 51A. The duties apply to citizens.',
            'Part IVA and the original ten duties were inserted by the 42nd Constitutional Amendment Act, 1976. An additional duty concerning educational opportunities for children aged six to fourteen was later added by the 86th Constitutional Amendment Act, 2002.',
          ],
        ),
        LearnLessonSection(
          heading: 'The eleven duties — study version',
          paragraphs: const [],
          points: [
            'Respect the Constitution, its ideals and institutions, the National Flag and National Anthem.',
            'Cherish the ideals of the freedom struggle.',
            'Uphold and protect the sovereignty, unity and integrity of India.',
            'Defend the country and render national service when called upon.',
            'Promote harmony and renounce practices derogatory to the dignity of women.',
            'Value and preserve the heritage of composite culture.',
            'Protect and improve the natural environment and show compassion for living creatures.',
            'Develop scientific temper, humanism and the spirit of inquiry and reform.',
            'Safeguard public property and abjure violence.',
            'Strive towards excellence in individual and collective activity.',
            'As parent or guardian, provide opportunities for education to a child or ward aged six to fourteen years.',
          ],
        ),
        LearnLessonSection(
          heading: 'Amendment link',
          paragraphs: [
            'For exams, connect the 42nd Amendment with insertion of Part IVA and ten Fundamental Duties, and the 86th Amendment with the additional education-related duty in Article 51A(k).',
          ],
        ),
      ],
      quickRevision: [
        'Fundamental Duties = Part IVA, Article 51A.',
        '42nd Amendment, 1976 inserted Part IVA and ten duties.',
        '86th Amendment, 2002 added the education-related duty.',
        'There are eleven duties in Article 51A today.',
      ],
      examFocus: [
        'Part IVA and Article 51A.',
        '42nd versus 86th Amendment.',
        'Total number of Fundamental Duties.',
        'Environment, scientific temper and education duty wording.',
      ],
      practiceTags: ['fundamental-duties', 'article-51a'],
    ),
    LearnLesson(
      id: 'POL-LRN-015',
      subjectCode: 'POL',
      title: 'President of India',
      summary: 'Articles 52–62: office, election, qualifications, term, oath and impeachment.',
      estimatedMinutes: 10,
      sections: [
        LearnLessonSection(
          heading: 'Office and executive power',
          paragraphs: [
            'Article 52 provides that there shall be a President of India. Article 53 vests the executive power of the Union in the President, to be exercised in accordance with the Constitution.',
          ],
        ),
        LearnLessonSection(
          heading: 'Election of the President',
          paragraphs: [
            'The President is elected indirectly. The electoral college includes the elected members of both Houses of Parliament and the elected members of the Legislative Assemblies of the States. For this purpose, the Constitution also includes the National Capital Territory of Delhi and the Union territory of Puducherry.',
            'The election uses proportional representation by means of the single transferable vote, and voting is by secret ballot.',
          ],
        ),
        LearnLessonSection(
          heading: 'Qualifications and term',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Point', 'Rule'],
            rows: [
              ['Minimum age', '35 years'],
              ['Citizenship', 'Citizen of India'],
              ['Qualification', 'Qualified for election as a member of the House of the People'],
              ['Office of profit', 'Must not hold an office of profit as constitutionally specified'],
              ['Term', '5 years from entering office'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Impeachment',
          paragraphs: [
            'Article 61 provides the procedure for impeachment of the President for violation of the Constitution. The charge may be preferred by either House of Parliament, subject to the special notice and majority requirements stated in the Constitution.',
          ],
        ),
      ],
      quickRevision: [
        '52 = President of India.',
        '53 = Union executive power vested in the President.',
        '54–55 = election and manner of election.',
        '58 = qualifications; minimum age 35.',
        '56 = five-year term.',
        '61 = impeachment for violation of the Constitution.',
      ],
      examFocus: [
        'Who belongs to the Presidential electoral college.',
        'Elected versus nominated members.',
        'Minimum age and Lok Sabha qualification requirement.',
        'Article-number matching from 52–61.',
      ],
      practiceTags: ['president-of-india', 'articles-52-62', 'presidential-election'],
    ),
    LearnLesson(
      id: 'POL-LRN-016',
      subjectCode: 'POL',
      title: 'Vice-President of India',
      summary: 'Articles 63–71: office, Rajya Sabha role, election, qualifications and removal.',
      estimatedMinutes: 8,
      sections: [
        LearnLessonSection(
          heading: 'Office and Rajya Sabha role',
          paragraphs: [
            'Article 63 provides that there shall be a Vice-President of India. Under Article 64, the Vice-President is the ex officio Chairman of the Council of States.',
          ],
        ),
        LearnLessonSection(
          heading: 'Election',
          paragraphs: [
            'The Vice-President is elected by the members of both Houses of Parliament. Unlike the Presidential electoral college, the Constitution does not include State Legislative Assemblies in this election.',
            'The election uses proportional representation by means of the single transferable vote and voting is by secret ballot.',
          ],
        ),
        LearnLessonSection(
          heading: 'Qualifications',
          paragraphs: const [],
          points: [
            'Citizen of India.',
            'At least 35 years of age.',
            'Qualified for election as a member of the Council of States.',
            'Must not hold an office of profit as constitutionally specified.',
          ],
        ),
        LearnLessonSection(
          heading: 'Term and removal',
          paragraphs: [
            'The Vice-President holds office for five years from entering office, subject to resignation or removal.',
            'Removal requires a resolution of the Council of States passed by a majority of all the then members of that House and agreed to by the House of the People. At least fourteen days’ notice is required before moving such a resolution.',
          ],
        ),
      ],
      quickRevision: [
        '63 = Vice-President.',
        '64 = ex officio Chairman of Rajya Sabha.',
        'Election: members of both Houses of Parliament.',
        'Minimum age: 35; qualification: eligible for Rajya Sabha.',
        'Removal resolution originates in Rajya Sabha.',
      ],
      examFocus: [
        'President versus Vice-President electoral colleges.',
        'Ex officio Chairman of Rajya Sabha.',
        'Rajya Sabha qualification requirement.',
        'Removal process and fourteen-day notice.',
      ],
      practiceTags: ['vice-president', 'articles-63-71'],
    ),
    LearnLesson(
      id: 'POL-LRN-017',
      subjectCode: 'POL',
      title: 'Prime Minister',
      summary: 'Appointment, constitutional position and duties of the Prime Minister.',
      estimatedMinutes: 8,
      sections: [
        LearnLessonSection(
          heading: 'Appointment',
          paragraphs: [
            'Article 75 provides that the Prime Minister is appointed by the President. The other Ministers are appointed by the President on the advice of the Prime Minister.',
          ],
        ),
        LearnLessonSection(
          heading: 'Head of the Council of Ministers',
          paragraphs: [
            'Article 74 provides for a Council of Ministers with the Prime Minister at the head to aid and advise the President. The President may require the Council of Ministers to reconsider advice, but must act in accordance with the advice tendered after reconsideration.',
          ],
        ),
        LearnLessonSection(
          heading: 'Duties towards the President — Article 78',
          paragraphs: const [],
          points: [
            'Communicate decisions of the Council of Ministers on Union administration and proposals for legislation.',
            'Furnish information relating to Union administration and proposals for legislation when the President calls for it.',
            'If the President requires, place before the Council of Ministers a matter decided by an individual Minister but not considered by the Council.',
          ],
        ),
      ],
      quickRevision: [
        '75 = Prime Minister appointed by the President.',
        'Other Ministers are appointed on the Prime Minister’s advice.',
        '74 = Council of Ministers headed by the Prime Minister aids and advises the President.',
        '78 = Prime Minister’s information duties towards the President.',
      ],
      examFocus: [
        'Articles 74, 75 and 78.',
        'Who appoints the Prime Minister and other Ministers.',
        'President’s power to require reconsideration of ministerial advice.',
      ],
      practiceTags: ['prime-minister', 'articles-74-75-78'],
    ),
    LearnLesson(
      id: 'POL-LRN-018',
      subjectCode: 'POL',
      title: 'Council of Ministers',
      summary: 'Articles 74–75: aid and advice, appointment, collective responsibility and size limit.',
      estimatedMinutes: 9,
      sections: [
        LearnLessonSection(
          heading: 'Aid and advice',
          paragraphs: [
            'Article 74 provides for a Council of Ministers with the Prime Minister at the head to aid and advise the President. The constitutional text also provides for reconsideration of advice once at the President’s request.',
          ],
        ),
        LearnLessonSection(
          heading: 'Appointment and responsibility',
          paragraphs: [
            'The Prime Minister is appointed by the President and the other Ministers are appointed by the President on the advice of the Prime Minister.',
            'Article 75 states that the Council of Ministers is collectively responsible to the House of the People.',
          ],
        ),
        LearnLessonSection(
          heading: 'Important Article 75 facts',
          paragraphs: const [],
          points: [
            'Ministers hold office during the pleasure of the President.',
            'Oaths of office and secrecy are administered by the President.',
            'A Minister who is not a member of either House of Parliament for six consecutive months ceases to be a Minister at the end of that period.',
            'The total number of Ministers, including the Prime Minister, cannot exceed 15% of the total membership of the Lok Sabha.',
          ],
        ),
        LearnLessonSection(
          heading: 'Collective responsibility',
          paragraphs: [
            'For exam purposes, connect collective responsibility with the Lok Sabha, not the Rajya Sabha. This is one of the most frequently tested distinctions in the Union executive chapter.',
          ],
        ),
      ],
      quickRevision: [
        '74 = aid and advice.',
        '75 = appointment and other provisions concerning Ministers.',
        'Collective responsibility is to Lok Sabha.',
        'Six-month rule for a Minister who is not an MP.',
        'Council size ceiling: 15% of total Lok Sabha membership.',
      ],
      examFocus: [
        'Collective responsibility: Lok Sabha.',
        'Six-month membership rule.',
        '15% size ceiling introduced through the constitutional amendment framework reflected in Article 75.',
        'Difference between Article 74 advice and Article 75 ministerial provisions.',
      ],
      practiceTags: ['council-of-ministers', 'articles-74-75'],
    ),
    LearnLesson(
      id: 'POL-LRN-019',
      subjectCode: 'POL',
      title: 'Parliament — Structure and Membership',
      summary: 'Articles 79–88: structure of Parliament, Rajya Sabha, Lok Sabha and key membership rules.',
      estimatedMinutes: 11,
      sections: [
        LearnLessonSection(
          heading: 'What Parliament consists of',
          paragraphs: [
            'Article 79 states that Parliament for the Union consists of the President and two Houses: the Council of States and the House of the People.',
          ],
        ),
        LearnLessonSection(
          heading: 'Rajya Sabha — Article 80',
          paragraphs: [
            'The Council of States includes twelve members nominated by the President for special knowledge or practical experience in literature, science, art and social service, along with representatives of the States and Union territories as provided by the Constitution.',
            'Representatives of each State in the Rajya Sabha are elected by the elected members of the State Legislative Assembly using proportional representation by means of the single transferable vote.',
          ],
        ),
        LearnLessonSection(
          heading: 'Lok Sabha — Article 81',
          paragraphs: [
            'The House of the People is composed of members chosen by direct election from territorial constituencies in the States and representatives of Union territories as provided by Parliament by law.',
          ],
        ),
        LearnLessonSection(
          heading: 'Duration and qualifications',
          paragraphs: [
            'The Rajya Sabha is not subject to dissolution. As nearly as possible, one-third of its members retire every second year.',
            'The normal term of the Lok Sabha is five years from the date appointed for its first meeting, unless sooner dissolved, subject to the special constitutional provision during a Proclamation of Emergency.',
          ],
          table: LearnLessonTable(
            headers: ['House', 'Minimum age under Article 84'],
            rows: [
              ['Rajya Sabha', '30 years'],
              ['Lok Sabha', '25 years'],
            ],
          ),
        ),
      ],
      quickRevision: [
        '79 = President + Rajya Sabha + Lok Sabha.',
        'Rajya Sabha: 12 nominated members under Article 80.',
        'Rajya Sabha is a continuing House; about one-third retire every second year.',
        'Lok Sabha normal term = 5 years unless sooner dissolved.',
        'Minimum age: Rajya Sabha 30; Lok Sabha 25.',
      ],
      examFocus: [
        'Parliament includes the President.',
        'Subjects for Rajya Sabha Presidential nominations.',
        'Continuing nature of Rajya Sabha versus dissolvable Lok Sabha.',
        'Minimum ages of the two Houses.',
      ],
      practiceTags: ['parliament', 'rajya-sabha', 'lok-sabha', 'articles-79-88'],
    ),
    LearnLesson(
      id: 'POL-LRN-020',
      subjectCode: 'POL',
      title: 'Parliament — Sessions and Procedure',
      summary: 'Sessions, prorogation, dissolution, voting, quorum and joint sittings.',
      estimatedMinutes: 10,
      sections: [
        LearnLessonSection(
          heading: 'Sessions of Parliament',
          paragraphs: [
            'Article 85 empowers the President to summon each House of Parliament. The Constitution requires that not more than six months shall intervene between the last sitting in one session and the date appointed for the first sitting in the next session.',
            'The President may prorogue either House or both Houses. The Lok Sabha may also be dissolved.',
          ],
        ),
        LearnLessonSection(
          heading: 'Voting and quorum',
          paragraphs: [
            'Article 100 provides that questions in either House are generally decided by a majority of members present and voting, excluding the presiding officer in the first instance.',
            'The Speaker, Chairman or person acting as such has a casting vote in the event of equality of votes.',
            'Unless Parliament provides otherwise by law, the quorum to constitute a meeting of either House is one-tenth of the total number of members of that House.',
          ],
        ),
        LearnLessonSection(
          heading: 'Joint sitting — Article 108',
          paragraphs: [
            'A joint sitting may be used in specified deadlock situations involving an ordinary Bill. It is summoned by the President.',
            'There is no joint sitting for a Money Bill or for a Constitution Amendment Bill.',
          ],
        ),
      ],
      quickRevision: [
        'Article 85 = summoning, prorogation and dissolution.',
        'Maximum gap between sessions: six months.',
        'Article 100 = voting and quorum.',
        'Quorum: one-tenth of total membership, unless otherwise provided by law.',
        'Article 108 = joint sitting.',
      ],
      examFocus: [
        'Six-month constitutional rule between sessions.',
        'Casting vote of the presiding officer.',
        'One-tenth quorum.',
        'Bills for which joint sitting is not available.',
      ],
      practiceTags: ['parliament-procedure', 'article-85', 'article-100', 'joint-sitting'],
    ),
    LearnLesson(
      id: 'POL-LRN-021',
      subjectCode: 'POL',
      title: 'Presiding Officers of Parliament',
      summary: 'Chairman and Deputy Chairman of Rajya Sabha; Speaker and Deputy Speaker of Lok Sabha.',
      estimatedMinutes: 9,
      sections: [
        LearnLessonSection(
          heading: 'Rajya Sabha',
          paragraphs: [
            'Under Article 89, the Vice-President of India is the ex officio Chairman of the Council of States. The Rajya Sabha chooses one of its members to be the Deputy Chairman.',
          ],
        ),
        LearnLessonSection(
          heading: 'Lok Sabha',
          paragraphs: [
            'Article 93 requires the House of the People to choose two of its members to be respectively Speaker and Deputy Speaker.',
          ],
        ),
        LearnLessonSection(
          heading: 'Voting role',
          paragraphs: [
            'When presiding, the Chairman or Speaker does not vote in the first instance but has a casting vote in the case of equality of votes under Article 100.',
          ],
        ),
        LearnLessonSection(
          heading: 'Joint sitting',
          paragraphs: [
            'At a joint sitting, the Speaker of the Lok Sabha ordinarily presides. In the Speaker’s absence, the constitutional and procedural order provides for other presiding officers.',
          ],
        ),
      ],
      quickRevision: [
        'Vice-President = ex officio Chairman of Rajya Sabha.',
        'Rajya Sabha elects its Deputy Chairman.',
        'Lok Sabha elects Speaker and Deputy Speaker.',
        'Speaker ordinarily presides over a joint sitting.',
        'Presiding officer has a casting vote in case of a tie.',
      ],
      examFocus: [
        'Articles 89 and 93.',
        'Vice-President’s Rajya Sabha role.',
        'Who elects the Deputy Chairman, Speaker and Deputy Speaker.',
        'Casting vote and joint-sitting presiding officer.',
      ],
      practiceTags: ['speaker', 'deputy-speaker', 'rajya-sabha-chairman', 'presiding-officers'],
    ),
    LearnLesson(
      id: 'POL-LRN-022',
      subjectCode: 'POL',
      title: 'Bills in Parliament',
      summary: 'Ordinary Bills, Money Bills and the constitutional rules governing their passage.',
      estimatedMinutes: 11,
      sections: [
        LearnLessonSection(
          heading: 'Ordinary Bills',
          paragraphs: [
            'Subject to the special rules for Money Bills and certain Financial Bills, a Bill may originate in either House of Parliament under Article 107.',
            'An ordinary Bill generally needs agreement of both Houses before it is presented to the President for assent.',
          ],
        ),
        LearnLessonSection(
          heading: 'Money Bills — Articles 109 and 110',
          paragraphs: [
            'A Money Bill cannot be introduced in the Rajya Sabha. After the Lok Sabha passes a Money Bill, it is transmitted to the Rajya Sabha for recommendations.',
            'The Rajya Sabha has fourteen days to return the Money Bill with its recommendations. The Lok Sabha may accept or reject any or all of those recommendations.',
            'Article 110 defines a Money Bill. If a question arises whether a Bill is a Money Bill, the decision of the Speaker of the Lok Sabha is final under the constitutional text.',
          ],
        ),
        LearnLessonSection(
          heading: 'Joint sitting',
          paragraphs: [
            'Article 108 provides a mechanism for a joint sitting in specified deadlock situations involving ordinary legislation. This mechanism does not apply to Money Bills or Constitution Amendment Bills.',
          ],
        ),
        LearnLessonSection(
          heading: 'Quick comparison',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Feature', 'Ordinary Bill', 'Money Bill'],
            rows: [
              ['Introduction', 'Either House', 'Lok Sabha only'],
              ['Rajya Sabha role', 'Generally equal legislative role', 'Recommendations within 14 days'],
              ['Joint sitting', 'Possible in specified deadlocks', 'Not available'],
              ['Speaker certification', 'Not a Money Bill certificate', 'Speaker decides Money Bill question'],
            ],
          ),
        ),
      ],
      quickRevision: [
        '107 = introduction and passing of Bills.',
        '108 = joint sitting.',
        '109 = special procedure for Money Bills.',
        '110 = definition of Money Bill.',
        'Rajya Sabha gets 14 days for Money Bill recommendations.',
      ],
      examFocus: [
        'Which House can introduce a Money Bill.',
        'Fourteen-day rule.',
        'Speaker’s constitutional role in Money Bill classification.',
        'Ordinary Bill versus Money Bill and joint sitting.',
      ],
      practiceTags: ['bills-in-parliament', 'money-bill', 'articles-107-110'],
    ),
    LearnLesson(
      id: 'POL-LRN-023',
      subjectCode: 'POL',
      title: 'Union Budget and Financial Procedure',
      summary: 'Annual Financial Statement, grants, appropriation and high-yield constitutional budget terms.',
      estimatedMinutes: 10,
      sections: [
        LearnLessonSection(
          heading: 'Annual Financial Statement — Article 112',
          paragraphs: [
            'Article 112 requires the President to cause to be laid before both Houses of Parliament a statement of the estimated receipts and expenditure of the Government of India for each financial year. This is the constitutional Annual Financial Statement.',
          ],
        ),
        LearnLessonSection(
          heading: 'Charged and voted expenditure',
          paragraphs: [
            'The Annual Financial Statement distinguishes expenditure charged on the Consolidated Fund of India from other expenditure proposed to be made from that Fund.',
            'Charged expenditure is not submitted to the vote of Parliament, although it may be discussed. Other expenditure is submitted in the form of demands for grants to the Lok Sabha.',
          ],
        ),
        LearnLessonSection(
          heading: 'Demands for grants and appropriation',
          paragraphs: [
            'Article 113 deals with procedure in Parliament concerning estimates, including demands for grants. Such demands are submitted to the House of the People.',
            'Article 114 provides for an Appropriation Bill after grants have been made, covering withdrawal from the Consolidated Fund of India for voted grants and charged expenditure.',
          ],
        ),
        LearnLessonSection(
          heading: 'High-yield sequence',
          paragraphs: const [],
          points: [
            'Annual Financial Statement — Article 112.',
            'Procedure concerning estimates and demands for grants — Article 113.',
            'Appropriation Bills — Article 114.',
            'Supplementary, additional or excess grants — Article 115.',
            'Votes on account, votes of credit and exceptional grants — Article 116.',
          ],
        ),
      ],
      quickRevision: [
        '112 = Annual Financial Statement.',
        'Demands for grants are voted by Lok Sabha.',
        'Charged expenditure is not submitted to vote.',
        '114 = Appropriation Bill.',
        '115–116 cover additional financial procedures.',
      ],
      examFocus: [
        'Annual Financial Statement versus ordinary use of the word Budget.',
        'Charged expenditure versus voted expenditure.',
        'Lok Sabha’s role in demands for grants.',
        'Article-number sequence 112–116.',
      ],
      practiceTags: ['union-budget', 'annual-financial-statement', 'articles-112-116'],
    ),
    LearnLesson(
      id: 'POL-LRN-024',
      subjectCode: 'POL',
      title: 'Parliamentary Committees',
      summary: 'Why committees matter and the structure of the three major financial committees.',
      estimatedMinutes: 10,
      sections: [
        LearnLessonSection(
          heading: 'Why Parliament uses committees',
          paragraphs: [
            'Parliamentary committees allow detailed examination of legislative, financial and administrative matters that cannot always receive the same level of scrutiny on the floor of the House.',
            'Committees may be standing or ad hoc. For competitive exams, the three financial committees are especially important.',
          ],
        ),
        LearnLessonSection(
          heading: 'Three financial committees',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Committee', 'Membership', 'Tenure'],
            rows: [
              ['Public Accounts Committee', '22: 15 Lok Sabha + 7 Rajya Sabha', '1 year'],
              ['Estimates Committee', '30: all from Lok Sabha', '1 year'],
              ['Committee on Public Undertakings', '22: 15 Lok Sabha + 7 Rajya Sabha', '1 year'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'What they broadly examine',
          paragraphs: const [],
          points: [
            'Public Accounts Committee: public accounts, appropriation-related scrutiny and CAG-based financial examination within its remit.',
            'Estimates Committee: economies, efficiency, administrative reform and how estimates are presented and used.',
            'Committee on Public Undertakings: reports, accounts and CAG reports relating to specified public undertakings, along with efficiency and sound business-practice questions within its remit.',
          ],
        ),
        LearnLessonSection(
          heading: 'Common exam distinction',
          paragraphs: [
            'The Estimates Committee has only Lok Sabha members. The Public Accounts Committee and Committee on Public Undertakings include members from both Houses.',
          ],
        ),
      ],
      quickRevision: [
        'PAC: 22 = 15 LS + 7 RS.',
        'Estimates Committee: 30, all from Lok Sabha.',
        'COPU: 22 = 15 LS + 7 RS.',
        'The tenure of these financial committees is one year.',
      ],
      examFocus: [
        'Membership composition of PAC, Estimates Committee and COPU.',
        'Which financial committee has only Lok Sabha members.',
        'Basic functional distinction among the three.',
      ],
      practiceTags: ['parliamentary-committees', 'pac', 'estimates-committee', 'copu'],
    ),
    LearnLesson(
      id: 'POL-LRN-025',
      subjectCode: 'POL',
      title: 'Supreme Court of India',
      summary: 'Articles 124–147: composition, judges, jurisdiction and major constitutional powers.',
      estimatedMinutes: 12,
      sections: [
        LearnLessonSection(
          heading: 'Constitutional position',
          paragraphs: [
            'Article 124 establishes the Supreme Court of India. It is the apex court in the Indian judicial system.',
            'Judges of the Supreme Court are appointed by the President. A Supreme Court Judge holds office until the age of sixty-five years, subject to resignation or removal under the Constitution.',
          ],
        ),
        LearnLessonSection(
          heading: 'Qualifications — Article 124',
          paragraphs: const [],
          points: [
            'Citizen of India.',
            'Has been a Judge of one or more High Courts for at least five years; or',
            'Has been an advocate of one or more High Courts for at least ten years; or',
            'Is, in the opinion of the President, a distinguished jurist.',
          ],
        ),
        LearnLessonSection(
          heading: 'Major jurisdictions',
          paragraphs: [
            'The Supreme Court has original, appellate and advisory jurisdiction. Article 131 deals with its exclusive original jurisdiction in specified disputes involving the Union and States.',
            'Article 32 gives the Supreme Court jurisdiction to enforce Fundamental Rights. Article 136 provides for special leave to appeal, while Article 143 provides for advisory jurisdiction when the President refers a question to the Court.',
          ],
          table: LearnLessonTable(
            headers: ['Article', 'Exam cue'],
            rows: [
              ['129', 'Supreme Court is a court of record'],
              ['131', 'Original jurisdiction in specified Union-State disputes'],
              ['136', 'Special leave to appeal'],
              ['137', 'Review of judgments or orders'],
              ['141', 'Law declared by Supreme Court binding on all courts'],
              ['142', 'Power to do complete justice in matters before it'],
              ['143', 'Advisory jurisdiction'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Removal of a Judge',
          paragraphs: [
            'A Supreme Court Judge may be removed by the President after an address by each House of Parliament supported by the special majority specified in Article 124, on the ground of proved misbehaviour or incapacity.',
          ],
        ),
      ],
      quickRevision: [
        '124 = establishment, appointment and conditions of Supreme Court Judges.',
        'Retirement age: 65 years.',
        '131 = original jurisdiction.',
        '136 = special leave to appeal.',
        '141 = Supreme Court law binding on all courts.',
        '143 = Presidential reference/advisory jurisdiction.',
      ],
      examFocus: [
        'Supreme Court judge qualifications and retirement age.',
        'Article-number matching for major jurisdictions.',
        'Difference between original, appellate and advisory jurisdiction.',
        'Special-majority removal process.',
      ],
      practiceTags: ['supreme-court', 'articles-124-147', 'judicial-jurisdiction'],
    ),
    LearnLesson(
      id: 'POL-LRN-026',
      subjectCode: 'POL',
      title: 'High Courts',
      summary: 'Articles 214–231: High Court structure, judges, writ jurisdiction and superintendence.',
      estimatedMinutes: 11,
      sections: [
        LearnLessonSection(
          heading: 'High Court for States',
          paragraphs: [
            'Article 214 provides that there shall be a High Court for each State, while the Constitution also permits a common High Court for two or more States or for States and a Union territory.',
            'Each High Court consists of a Chief Justice and such other Judges as the President considers necessary from time to time.',
          ],
        ),
        LearnLessonSection(
          heading: 'Appointment and qualifications',
          paragraphs: [
            'High Court Judges are appointed by the President. The constitutional consultation requirements differ for the Chief Justice and for other Judges.',
            'A person must be a citizen of India and must satisfy the judicial-office or advocacy experience requirement stated in Article 217.',
          ],
          points: [
            'Judicial office in India for at least ten years; or',
            'Advocate of a High Court, or of two or more such courts in succession, for at least ten years.',
            'Retirement age: 62 years.',
          ],
        ),
        LearnLessonSection(
          heading: 'Writ jurisdiction — Article 226',
          paragraphs: [
            'High Courts may issue directions, orders or writs for enforcement of Fundamental Rights and for any other purpose.',
            'This makes the textual scope of Article 226 wider than Article 32, which is specifically tied to enforcement of Fundamental Rights.',
          ],
        ),
        LearnLessonSection(
          heading: 'Superintendence — Article 227',
          paragraphs: [
            'Every High Court has superintendence over courts and tribunals throughout the territories in relation to which it exercises jurisdiction, subject to the constitutional scheme.',
          ],
        ),
      ],
      quickRevision: [
        '214 = High Court for each State.',
        '217 = appointment and conditions of High Court Judges.',
        'Retirement age: 62 years.',
        '226 = writs for Fundamental Rights and any other purpose.',
        '227 = superintendence over subordinate courts and tribunals.',
      ],
      examFocus: [
        'Supreme Court age 65 versus High Court age 62.',
        'Article 32 versus Article 226.',
        'Ten-year qualification routes for High Court Judges.',
        'Common High Courts under the constitutional framework.',
      ],
      practiceTags: ['high-courts', 'articles-214-231', 'article-226'],
    ),
    LearnLesson(
      id: 'POL-LRN-027',
      subjectCode: 'POL',
      title: 'Comptroller and Auditor General of India',
      summary: 'Articles 148–151: appointment, independence, duties, accounts and audit reports.',
      estimatedMinutes: 9,
      sections: [
        LearnLessonSection(
          heading: 'Article 148 — constitutional office',
          paragraphs: [
            'The Constitution provides for a Comptroller and Auditor General of India. The CAG is appointed by the President by warrant under his hand and seal.',
            'The CAG can be removed only in the same manner and on the same grounds as a Judge of the Supreme Court.',
          ],
        ),
        LearnLessonSection(
          heading: 'Articles 149–151',
          paragraphs: const [],
          table: LearnLessonTable(
            headers: ['Article', 'Focus'],
            rows: [
              ['149', 'Duties and powers of the CAG'],
              ['150', 'Form of accounts of the Union and States'],
              ['151', 'Audit reports'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Audit reports',
          paragraphs: [
            'CAG reports relating to Union accounts are submitted to the President, who causes them to be laid before each House of Parliament.',
            'Reports relating to a State are submitted to the Governor, who causes them to be laid before the State Legislature.',
          ],
        ),
        LearnLessonSection(
          heading: 'Independence safeguards',
          paragraphs: [
            'The Constitution protects the conditions of service of the CAG from disadvantageous variation after appointment and charges the administrative expenses of the CAG’s office on the Consolidated Fund of India.',
          ],
        ),
      ],
      quickRevision: [
        '148 = CAG.',
        'Appointed by the President.',
        'Removal protection parallels a Supreme Court Judge.',
        '149 = duties and powers; 150 = form of accounts; 151 = audit reports.',
        'Union reports → President → Parliament; State reports → Governor → State Legislature.',
      ],
      examFocus: [
        'Articles 148–151.',
        'Appointment and removal protection.',
        'Where Union and State audit reports are submitted.',
        'CAG link with PAC in parliamentary financial scrutiny.',
      ],
      practiceTags: ['cag', 'articles-148-151', 'constitutional-bodies'],
    ),
    LearnLesson(
      id: 'POL-LRN-028',
      subjectCode: 'POL',
      title: 'Election Commission of India',
      summary: 'Article 324 and the constitutional framework for superintendence, direction and control of elections.',
      estimatedMinutes: 9,
      sections: [
        LearnLessonSection(
          heading: 'Article 324',
          paragraphs: [
            'Article 324 vests the superintendence, direction and control of the preparation of electoral rolls and the conduct of specified elections in an Election Commission.',
            'Its constitutional responsibilities cover elections to Parliament, State Legislatures, and the offices of President and Vice-President.',
          ],
        ),
        LearnLessonSection(
          heading: 'Composition',
          paragraphs: [
            'The Election Commission consists of the Chief Election Commissioner and such number of other Election Commissioners, if any, as the President may from time to time fix, subject to the constitutional and statutory framework.',
            'The President appoints the Chief Election Commissioner and other Election Commissioners subject to any law made by Parliament.',
          ],
        ),
        LearnLessonSection(
          heading: 'Removal protection',
          paragraphs: [
            'Article 324 gives the Chief Election Commissioner protection against removal except in like manner and on like grounds as a Judge of the Supreme Court.',
            'Other Election Commissioners or a Regional Commissioner cannot be removed except on the recommendation of the Chief Election Commissioner.',
          ],
        ),
      ],
      quickRevision: [
        '324 = Election Commission.',
        'Controls electoral rolls and conduct of specified constitutional elections.',
        'Covers Parliament, State Legislatures, President and Vice-President.',
        'CEC has Supreme-Court-Judge-like removal protection under Article 324.',
      ],
      examFocus: [
        'Article 324 functions.',
        'Which elections fall within the constitutional mandate.',
        'Constitutional wording on CEC and other Election Commissioners.',
        'Removal protection distinction.',
      ],
      practiceTags: ['election-commission', 'article-324', 'constitutional-bodies'],
    ),
    LearnLesson(
      id: 'POL-LRN-029',
      subjectCode: 'POL',
      title: 'Union Public Service Commission',
      summary: 'Articles 315–323: composition, appointment, tenure, removal, functions and reports.',
      estimatedMinutes: 10,
      sections: [
        LearnLessonSection(
          heading: 'Articles 315–323',
          paragraphs: [
            'Article 315 provides for Public Service Commissions for the Union and for the States. The Union Public Service Commission is the constitutional Public Service Commission for the Union.',
          ],
          table: LearnLessonTable(
            headers: ['Article', 'Focus'],
            rows: [
              ['315', 'Public Service Commissions for Union and States'],
              ['316', 'Appointment and term'],
              ['317', 'Removal and suspension'],
              ['319', 'Restrictions on offices after ceasing to be a member'],
              ['320', 'Functions'],
              ['322', 'Expenses'],
              ['323', 'Reports'],
            ],
          ),
        ),
        LearnLessonSection(
          heading: 'Appointment and tenure',
          paragraphs: [
            'The Chairman and other members of the UPSC are appointed by the President.',
            'A member of the UPSC holds office for six years from entering office or until attaining the age of sixty-five years, whichever is earlier.',
          ],
        ),
        LearnLessonSection(
          heading: 'Functions — Article 320',
          paragraphs: [
            'The UPSC conducts examinations for appointments to Union services and is consulted on constitutionally specified recruitment, appointment, promotion, transfer and disciplinary matters, subject to the constitutional and regulatory framework.',
          ],
        ),
        LearnLessonSection(
          heading: 'Expenses and reports',
          paragraphs: [
            'UPSC expenses are charged on the Consolidated Fund of India under Article 322. Under Article 323, the Commission presents an annual report to the President, who causes it to be laid before Parliament along with the required memorandum in relevant cases.',
          ],
        ),
      ],
      quickRevision: [
        '315–323 = Public Service Commissions.',
        'UPSC members appointed by President.',
        'Term: 6 years or age 65, whichever is earlier.',
        '320 = functions.',
        '322 = expenses charged on Consolidated Fund of India.',
        '323 = reports.',
      ],
      examFocus: [
        'Article-number sequence 315–323.',
        'Six years or 65 years rule for UPSC.',
        'Appointment by President.',
        'Article 320 functions and Article 323 reports.',
      ],
      practiceTags: ['upsc', 'articles-315-323', 'public-service-commission'],
    ),
    LearnLesson(
      id: 'POL-LRN-030',
      subjectCode: 'POL',
      title: 'Finance Commission',
      summary: 'Articles 280–281: constitution, composition and recommendations on Union-State finances.',
      estimatedMinutes: 9,
      sections: [
        LearnLessonSection(
          heading: 'Article 280',
          paragraphs: [
            'The President constitutes a Finance Commission every fifth year or earlier if considered necessary.',
            'The Commission consists of a Chairman and four other members appointed by the President. Parliament may by law determine the qualifications for appointment and the manner of selection.',
          ],
        ),
        LearnLessonSection(
          heading: 'Core recommendations',
          paragraphs: const [],
          points: [
            'Distribution between the Union and the States of the net proceeds of shareable taxes.',
            'Allocation among the States of their respective shares.',
            'Principles governing grants-in-aid of State revenues from the Consolidated Fund of India.',
            'Measures needed to augment State Consolidated Funds to supplement Panchayat resources on the basis of State Finance Commission recommendations.',
            'Measures needed to augment State Consolidated Funds to supplement Municipality resources on the basis of State Finance Commission recommendations.',
            'Any other matter referred by the President in the interests of sound finance.',
          ],
        ),
        LearnLessonSection(
          heading: 'Article 281',
          paragraphs: [
            'The President causes every Finance Commission recommendation, together with an explanatory memorandum as to the action taken, to be laid before each House of Parliament.',
          ],
        ),
      ],
      quickRevision: [
        '280 = Finance Commission.',
        'Normally constituted every fifth year or earlier.',
        'Composition: Chairman + 4 other members.',
        'Recommends tax distribution and grants-in-aid principles.',
        '281 = recommendations laid before Parliament with explanatory memorandum.',
      ],
      examFocus: [
        'Article 280 and five-year cycle.',
        'Chairman plus four members.',
        'Tax devolution versus grants-in-aid.',
        'Panchayat and Municipality resource augmentation role.',
      ],
      practiceTags: ['finance-commission', 'articles-280-281', 'fiscal-federalism'],
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
