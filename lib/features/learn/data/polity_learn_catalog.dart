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
  ],
);

LearnLesson? polityLessonById(String id) {
  final normalized = id.trim().toUpperCase();
  for (final lesson in polityLearnSubject.lessons) {
    if (lesson.id == normalized) return lesson;
  }
  return null;
}
