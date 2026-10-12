import '../models/exam_models.dart';

class ToeicScoreCalculator {
  // Bảng quy đổi điểm TOEIC Reading chuẩn ETS theo số câu đúng (0 - 100 câu)
  static const List<int> _readingScoreTable = [
    5,   // 0 câu đúng
    5,   // 1
    5,   // 2
    5,   // 3
    5,   // 4
    5,   // 5
    5,   // 6
    5,   // 7
    5,   // 8
    5,   // 9
    10,  // 10
    15,  // 11
    20,  // 12
    25,  // 13
    30,  // 14
    35,  // 15
    40,  // 16
    45,  // 17
    50,  // 18
    55,  // 19
    60,  // 20
    65,  // 21
    70,  // 22
    75,  // 23
    80,  // 24
    85,  // 25
    90,  // 26
    95,  // 27
    100, // 28
    110, // 29
    115, // 30
    120, // 31
    125, // 32
    130, // 33
    135, // 34
    140, // 35
    145, // 36
    150, // 37
    160, // 38
    165, // 39
    170, // 40
    175, // 41
    180, // 42
    185, // 43
    190, // 44
    195, // 45
    200, // 46
    210, // 47
    215, // 48
    220, // 49
    225, // 50
    230, // 51
    235, // 52
    240, // 53
    245, // 54
    250, // 55
    255, // 56
    260, // 57
    270, // 58
    275, // 59
    280, // 60
    285, // 61
    290, // 62
    295, // 63
    300, // 64
    310, // 65
    315, // 66
    320, // 67
    325, // 68
    330, // 69
    335, // 70
    340, // 71
    350, // 72
    355, // 73
    360, // 74
    365, // 75
    370, // 76
    380, // 77
    385, // 78
    390, // 79
    395, // 80
    400, // 81
    405, // 82
    410, // 83
    415, // 84
    420, // 85
    425, // 86
    430, // 87
    435, // 88
    445, // 89
    450, // 90
    455, // 91
    465, // 92
    470, // 93
    475, // 94
    480, // 95
    485, // 96
    490, // 97
    495, // 98
    495, // 99
    495, // 100 câu đúng
  ];

  static int getToeicReadingScore(int correctCount) {
    if (correctCount <= 0) return 5;
    if (correctCount >= _readingScoreTable.length) return 495;
    return _readingScoreTable[correctCount];
  }

  static String getCefrLevel(int readingScore) {
    if (readingScore >= 455) return 'C1 (Advanced)';
    if (readingScore >= 385) return 'B2 (Vantage)';
    if (readingScore >= 275) return 'B1 (Threshold)';
    if (readingScore >= 160) return 'A2 (Waystage)';
    return 'A1 (Breakthrough)';
  }

  static ExamResultData calculateResult({
    required String examTitle,
    required List<QuestionItem> questions,
    required int durationSeconds,
  }) {
    int p5Correct = 0, p5Total = 0;
    int p6Correct = 0, p6Total = 0;
    int p7Correct = 0, p7Total = 0;
    int totalSkipped = 0;

    for (final q in questions) {
      final isSelected = q.selectedChoice != null && q.selectedChoice!.isNotEmpty;
      final isCorrect = isSelected && q.selectedChoice == q.correctChoiceKey;

      if (!isSelected) {
        totalSkipped++;
      }

      switch (q.part) {
        case PartType.part5:
          p5Total++;
          if (isCorrect) p5Correct++;
          break;
        case PartType.part6:
          p6Total++;
          if (isCorrect) p6Correct++;
          break;
        case PartType.part7:
          p7Total++;
          if (isCorrect) p7Correct++;
          break;
      }
    }

    final totalCorrect = p5Correct + p6Correct + p7Correct;
    final totalQuestions = questions.isNotEmpty ? questions.length : 100;
    final totalIncorrect = totalQuestions - totalCorrect - totalSkipped;
    final readingScore = getToeicReadingScore(totalCorrect);
    final cefr = getCefrLevel(readingScore);

    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    final timeTakenStr = '${minutes}m ${seconds}s';
    final savedMinutes = (75 - minutes).clamp(0, 75);

    String feedback;
    if (readingScore >= 400) {
      feedback = 'Xuất sắc! Khả năng đọc hiểu và ngữ pháp của bạn đạt chuẩn B2/C1 ($totalCorrect/$totalQuestions câu đúng). Duy trì tốc độ này khi thi thật!';
    } else if (readingScore >= 300) {
      feedback = 'Kết quả khá tốt ($totalCorrect/$totalQuestions câu đúng)! Bạn xử lý tốt Part 5 & 6. Hãy cải thiện thêm khả năng đọc lướt (Skim/Scan) ở Part 7.';
    } else {
      feedback = 'Bạn đạt $totalCorrect/$totalQuestions câu đúng ($readingScore/495). Cần củng cố thêm từ vựng Part 5 và rèn luyện phân bổ thời gian cho bài đọc dài Part 7.';
    }

    return ExamResultData(
      examTitle: examTitle,
      score: readingScore,
      maxScore: 495,
      cefrLevel: cefr,
      totalCorrect: totalCorrect,
      totalIncorrect: totalIncorrect < 0 ? 0 : totalIncorrect,
      totalSkipped: totalSkipped,
      scoreDiff: 25,
      aiFeedback: feedback,
      timeTakenString: timeTakenStr,
      timeSavedString: '${savedMinutes}m',
      partAnalytics: [
        PartAnalytics(
          partName: 'Part 5',
          subtitle: 'Incomplete Sentences ($p5Correct/${p5Total > 0 ? p5Total : 30})',
          correct: p5Correct,
          total: p5Total > 0 ? p5Total : 30,
        ),
        PartAnalytics(
          partName: 'Part 6',
          subtitle: 'Text Completion ($p6Correct/${p6Total > 0 ? p6Total : 16})',
          correct: p6Correct,
          total: p6Total > 0 ? p6Total : 16,
        ),
        PartAnalytics(
          partName: 'Part 7',
          subtitle: 'Reading Comprehension ($p7Correct/${p7Total > 0 ? p7Total : 54})',
          correct: p7Correct,
          total: p7Total > 0 ? p7Total : 54,
        ),
      ],
    );
  }
}
