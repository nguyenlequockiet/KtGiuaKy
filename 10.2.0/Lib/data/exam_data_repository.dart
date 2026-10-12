import '../models/exam_models.dart';
import 'ets_2024_test_06_data.dart';

class ExamDataRepository {
  ExamDataRepository._();
  static final ExamDataRepository instance = ExamDataRepository._();

  List<QuestionItem>? _questions;
  Map<String, ReadingPassage>? _passages;

  List<QuestionItem> get questions {
    _questions ??= getEtsTest06Questions();
    return _questions!;
  }

  Map<String, ReadingPassage> get passages {
    _passages ??= Map<String, ReadingPassage>.from(etsTest06Passages);
    return _passages!;
  }

  QuestionItem? getQuestionByNumber(int number) {
    try {
      return questions.firstWhere((q) => q.number == number);
    } catch (_) {
      return null;
    }
  }

  void updateQuestion(QuestionItem updated) {
    final index = questions.indexWhere((q) => q.number == updated.number);
    if (index != -1) {
      questions[index] = updated;
    }
  }

  void updatePassage(String passageId, String newContent, {String? newTitle, String? newDocType}) {
    if (passages.containsKey(passageId)) {
      final old = passages[passageId]!;
      passages[passageId] = ReadingPassage(
        id: old.id,
        documentType: newDocType ?? old.documentType,
        title: newTitle ?? old.title,
        recipient: old.recipient,
        sender: old.sender,
        date: old.date,
        subject: old.subject,
        content: newContent,
      );
    }
  }
}
