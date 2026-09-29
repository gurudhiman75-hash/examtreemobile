import '../domain/learn_practice_models.dart';

const learnModules = <LearnModuleDefinition>[
  LearnModuleDefinition(
    id: 'quant',
    title: 'Quantitative Aptitude',
    subtitle: 'Arithmetic, advanced maths, DI and statistics.',
    iconName: 'calculate',
    submodules: [
      LearnSubmoduleDefinition(id: 'quant-arithmetic', moduleId: 'quant', title: 'Arithmetic', subtitle: 'Percentage, ratio, profit & loss, averages and more.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'quant-advanced', moduleId: 'quant', title: 'Advanced Mathematics', subtitle: 'Algebra, geometry, mensuration and trigonometry.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'quant-di', moduleId: 'quant', title: 'Data Interpretation', subtitle: 'Tables, charts, graphs and caselets.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'quant-statistics', moduleId: 'quant', title: 'Statistics', subtitle: 'Mean, median, mode, charts and distributions.', topicIds: [], available: false),
    ],
  ),
  LearnModuleDefinition(
    id: 'reasoning',
    title: 'Reasoning',
    subtitle: 'Verbal, analytical and non-verbal reasoning practice.',
    iconName: 'psychology',
    submodules: [
      LearnSubmoduleDefinition(id: 'reasoning-coding', moduleId: 'reasoning', title: 'Coding-Decoding', subtitle: 'Letter, word and pattern coding.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'reasoning-ranking', moduleId: 'reasoning', title: 'Ranking & Order', subtitle: 'Position, order and comparison questions.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'reasoning-relations', moduleId: 'reasoning', title: 'Blood Relations', subtitle: 'Family relationships and coded relations.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'reasoning-puzzles', moduleId: 'reasoning', title: 'Puzzles & Arrangements', subtitle: 'Seating, floor and logic arrangements.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'reasoning-venn', moduleId: 'reasoning', title: 'Venn Diagrams', subtitle: 'Logical relationships and set-based reasoning.', topicIds: [], available: false),
    ],
  ),
  LearnModuleDefinition(
    id: 'english',
    title: 'English',
    subtitle: 'Vocabulary, grammar, comprehension and usage.',
    iconName: 'translate',
    submodules: [
      LearnSubmoduleDefinition(id: 'english-vocabulary', moduleId: 'english', title: 'Vocabulary', subtitle: 'Synonyms, antonyms, idioms and one-word substitutions.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'english-grammar', moduleId: 'english', title: 'Grammar & Usage', subtitle: 'Error spotting, sentence correction and fillers.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'english-comprehension', moduleId: 'english', title: 'Reading Comprehension', subtitle: 'SSC and banking-style passages.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'english-rearrangement', moduleId: 'english', title: 'Sentence Rearrangement', subtitle: 'Para jumbles and sentence ordering.', topicIds: [], available: false),
    ],
  ),
  LearnModuleDefinition(
    id: 'gk',
    title: 'General Knowledge',
    subtitle: 'Static GK and exam-focused knowledge subjects.',
    iconName: 'public',
    submodules: [
      LearnSubmoduleDefinition(id: 'gk-polity', moduleId: 'gk', title: 'Polity', subtitle: 'Constitution, institutions, rights and governance.', topicIds: [], available: true),
      LearnSubmoduleDefinition(id: 'gk-history', moduleId: 'gk', title: 'History', subtitle: 'Ancient, medieval, modern and world history.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'gk-geography', moduleId: 'gk', title: 'Geography', subtitle: 'Indian and world geography.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'gk-economy', moduleId: 'gk', title: 'Economy', subtitle: 'Indian economy, banking and public finance.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'gk-science', moduleId: 'gk', title: 'Science', subtitle: 'Physics, chemistry and biology.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'gk-environment', moduleId: 'gk', title: 'Environment', subtitle: 'Ecology, biodiversity and environmental issues.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'gk-punjab', moduleId: 'gk', title: 'Punjab GK', subtitle: 'Punjab history, geography, culture and institutions.', topicIds: [], available: false),
      LearnSubmoduleDefinition(id: 'gk-computer', moduleId: 'gk', title: 'Computer', subtitle: 'Computer awareness and MS Office.', topicIds: [], available: false),
    ],
  ),
];

LearnModuleDefinition? learnModuleById(String id) {
  for (final module in learnModules) {
    if (module.id == id) return module;
  }
  return null;
}

LearnSubmoduleDefinition? learnSubmoduleById(String id) {
  for (final module in learnModules) {
    for (final submodule in module.submodules) {
      if (submodule.id == id) return submodule;
    }
  }
  return null;
}
