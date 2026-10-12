enum PartType { part5, part6, part7 }

class ExamItem {
  final String id;
  final String title;
  final String description;
  final String category; // 'all', 'full', 'part5', 'part6', 'part7'
  final int durationMinutes;
  final int totalQuestions;
  final String? scoreBadge;
  final bool isLatest;
  final int? inProgressQuestions;
  final int? remainingMinutes;
  final String? difficultyBadge;
  final String? viewCount;
  final String? averageScore;
  final String actionText;

  const ExamItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.durationMinutes,
    required this.totalQuestions,
    this.scoreBadge,
    this.isLatest = false,
    this.inProgressQuestions,
    this.remainingMinutes,
    this.difficultyBadge,
    this.viewCount,
    this.averageScore,
    this.actionText = 'Bắt đầu làm bài',
  });
}

class QuestionChoice {
  final String key; // 'A', 'B', 'C', 'D'
  final String content;

  const QuestionChoice({
    required this.key,
    required this.content,
  });
}

class QuestionItem {
  final int number;
  final PartType part;
  final String categoryName;
  final String prompt;
  final List<QuestionChoice> choices;
  String? selectedChoice;
  bool isFlagged;
  final String? explanation;
  final String? passageId;
  final String? correctChoiceKey; // 'A', 'B', 'C', 'D'

  QuestionItem({
    required this.number,
    required this.part,
    required this.categoryName,
    required this.prompt,
    required this.choices,
    this.selectedChoice,
    this.isFlagged = false,
    this.explanation,
    this.passageId,
    this.correctChoiceKey,
  });
}

class ReadingPassage {
  final String id;
  final String documentType;
  final String title;
  final String? recipient;
  final String? sender;
  final String? date;
  final String? subject;
  final String content;

  const ReadingPassage({
    required this.id,
    required this.documentType,
    required this.title,
    this.recipient,
    this.sender,
    this.date,
    this.subject,
    required this.content,
  });
}

class PartAnalytics {
  final String partName;
  final String subtitle;
  final int correct;
  final int total;

  const PartAnalytics({
    required this.partName,
    required this.subtitle,
    required this.correct,
    required this.total,
  });

  double get percentage => (correct / total) * 100;
}

class ExamResultData {
  final String examTitle;
  final int score;
  final int maxScore;
  final String cefrLevel;
  final int totalCorrect;
  final int totalIncorrect;
  final int totalSkipped;
  final int scoreDiff;
  final String aiFeedback;
  final String timeTakenString;
  final String timeSavedString;
  final List<PartAnalytics> partAnalytics;

  const ExamResultData({
    required this.examTitle,
    required this.score,
    this.maxScore = 495,
    required this.cefrLevel,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.totalSkipped,
    required this.scoreDiff,
    required this.aiFeedback,
    required this.timeTakenString,
    required this.timeSavedString,
    required this.partAnalytics,
  });

  int get totalQuestions => totalCorrect + totalIncorrect + totalSkipped;
  int get accuracyPercentage => ((totalCorrect / totalQuestions) * 100).round();
}
