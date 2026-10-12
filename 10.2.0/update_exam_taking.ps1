$path = 'c:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\Lib\screens\exam_taking_screen.dart'
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# Replace _initData
$regexInit = '(?s)  void _initData\(\) \{.*?\}\r?\n\r?\n  void _selectPart'
$newInit = @'
  void _initData() {
    _questions = getEtsTest06Questions();
    _currentQuestionNumber = 101;
    _currentPart = PartType.part5;
    if (etsTest06Passages.isNotEmpty) {
      _part7Passage = etsTest06Passages.values.first;
    } else {
      _part7Passage = const ReadingPassage(
        id: 'p7_default',
        documentType: 'Notice',
        title: 'Đoạn văn',
        content: 'Nội dung đoạn văn đọc hiểu.',
      );
    }
  }

  void _selectPart
'@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $regexInit, $newInit)

# Replace _jumpToQuestion
$regexJump = '(?s)  void _jumpToQuestion\(int qNum\) \{.*?\}\r?\n\r?\n  void _navigateQuestion'
$newJump = @'
  void _jumpToQuestion(int qNum) {
    setState(() {
      _currentQuestionNumber = qNum;
      if (qNum <= 130) {
        _currentPart = PartType.part5;
      } else if (qNum <= 146) {
        _currentPart = PartType.part6;
      } else {
        _currentPart = PartType.part7;
      }

      final q = _questions.firstWhere(
        (item) => item.number == qNum,
        orElse: () => _questions.first,
      );
      if (q.passageId != null && etsTest06Passages.containsKey(q.passageId)) {
        _part7Passage = etsTest06Passages[q.passageId]!;
      }
    });
  }

  void _navigateQuestion
'@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $regexJump, $newJump)

# Replace _submitExam
$regexSubmit = '(?s)  void _submitExam\(\) \{.*?\}\r?\n\r?\n  void _showPauseDialog'
$newSubmit = @'
  void _submitExam() {
    _timer?.cancel();
    final timeSpentSeconds = (75 * 60) - _secondsRemaining;
    final result = ToeicScoreCalculator.calculateResult(
      examTitle: widget.exam.title,
      questions: _questions,
      durationSeconds: timeSpentSeconds > 0 ? timeSpentSeconds : 0,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ExamResultScreen(resultData: result),
      ),
    );
  }

  void _showPauseDialog
'@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $regexSubmit, $newSubmit)

[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
Write-Output "Successfully updated exam_taking_screen.dart"
