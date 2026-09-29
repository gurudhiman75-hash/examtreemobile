import '../domain/learn_practice_models.dart';

const englishVocabularyPracticeTopics = <LearnPracticeTopic>[
  LearnPracticeTopic(
    id: 'ENG-VOC-SYN',
    submoduleId: 'english-vocabulary',
    title: 'Synonyms',
    subtitle: 'Choose the word closest in meaning.',
    questionTarget: 20,
    practiceTags: ['english-eng004-synonyms-antonyms-v1', 'synonym'],
  ),
  LearnPracticeTopic(
    id: 'ENG-VOC-ANT',
    submoduleId: 'english-vocabulary',
    title: 'Antonyms',
    subtitle: 'Choose the word opposite in meaning.',
    questionTarget: 20,
    practiceTags: ['english-eng004-synonyms-antonyms-v1', 'antonym'],
  ),
  LearnPracticeTopic(
    id: 'ENG-VOC-IDIOM',
    submoduleId: 'english-vocabulary',
    title: 'Idioms & Phrases',
    subtitle: 'Practice meanings and phrase recognition.',
    questionTarget: 20,
    practiceTags: ['english-eng005-idioms-phrases-v1'],
  ),
  LearnPracticeTopic(
    id: 'ENG-VOC-OWS',
    submoduleId: 'english-vocabulary',
    title: 'One-word Substitution',
    subtitle: 'Choose the single word that matches the definition.',
    questionTarget: 20,
    practiceTags: ['english-eng006-one-word-substitution-v1'],
  ),
];

List<LearnPracticeTopic> learnPracticeTopicsForSubmodule(String submoduleId) {
  if (submoduleId == 'english-vocabulary') {
    return englishVocabularyPracticeTopics;
  }
  return const <LearnPracticeTopic>[];
}

LearnPracticeTopic? learnPracticeTopicById(String id) {
  for (final topic in englishVocabularyPracticeTopics) {
    if (topic.id == id) return topic;
  }
  return null;
}
