enum LearnModuleKind { quant, reasoning, english, gk }

class LearnModuleDefinition {
  const LearnModuleDefinition({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.submodules,
  });

  final String id;
  final String title;
  final String subtitle;
  final String iconName;
  final List<LearnSubmoduleDefinition> submodules;
}

class LearnSubmoduleDefinition {
  const LearnSubmoduleDefinition({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.subtitle,
    required this.topicIds,
    this.available = true,
  });

  final String id;
  final String moduleId;
  final String title;
  final String subtitle;
  final List<String> topicIds;
  final bool available;
}

class LearnPracticeTopic {
  const LearnPracticeTopic({
    required this.id,
    required this.submoduleId,
    required this.title,
    required this.subtitle,
    required this.questionTarget,
    required this.practiceTags,
    this.available = true,
  });

  final String id;
  final String submoduleId;
  final String title;
  final String subtitle;
  final int questionTarget;
  final List<String> practiceTags;
  final bool available;
}

enum LearnPracticeStatus { notStarted, inProgress, completed }

class LearnPracticeProgress {
  const LearnPracticeProgress({
    required this.topicId,
    required this.status,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.updatedAt,
  });

  final String topicId;
  final LearnPracticeStatus status;
  final int currentQuestion;
  final int totalQuestions;
  final int correctAnswers;
  final DateTime updatedAt;

  double get accuracy =>
      totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions) * 100;
}
