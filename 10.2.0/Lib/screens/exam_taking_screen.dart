import 'dart:async';
import 'package:flutter/material.dart';
import '../data/exam_data_repository.dart';
import '../models/exam_models.dart';
import '../theme/app_colors.dart';
import '../utils/toeic_score_calculator.dart';
import '../widgets/question_matrix_modal.dart';
import '../widgets/submit_confirmation_modal.dart';
import 'exam_result_screen.dart';

class ExamTakingScreen extends StatefulWidget {
  final ExamItem exam;

  const ExamTakingScreen({super.key, required this.exam});

  @override
  State<ExamTakingScreen> createState() => _ExamTakingScreenState();
}

class _ExamTakingScreenState extends State<ExamTakingScreen> {
  PartType _currentPart = PartType.part7;
  int _currentQuestionNumber = 147;
  double _fontSizeScale = 1.0;
  bool _isPassageExpanded = false;

  // Timer: 54 minutes 12 seconds remaining (from mock data in Stitch)
  int _secondsRemaining = 54 * 60 + 12;
  Timer? _timer;

  late List<QuestionItem> _questions;
  late ReadingPassage _part7Passage;

  @override
  void initState() {
    super.initState();
    _initData();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _submitExam();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _initData() {
    _questions = ExamDataRepository.instance.questions.map((q) => QuestionItem(
      number: q.number,
      part: q.part,
      categoryName: q.categoryName,
      prompt: q.prompt,
      choices: q.choices,
      selectedChoice: null,
      isFlagged: false,
      explanation: q.explanation,
      passageId: q.passageId,
      correctChoiceKey: q.correctChoiceKey,
    )).toList();
    _currentQuestionNumber = 101;
    _currentPart = PartType.part5;
    final passages = ExamDataRepository.instance.passages;
    if (passages.isNotEmpty) {
      _part7Passage = passages.values.first;
    } else {
      _part7Passage = const ReadingPassage(
        id: 'p7_default',
        documentType: 'Notice',
        title: 'Đoạn văn',
        content: 'Nội dung đoạn văn đọc hiểu.',
      );
    }
  }

  void _selectPart(PartType part) {
    if (part == PartType.part5) {
      _jumpToQuestion(101);
    } else if (part == PartType.part6) {
      _jumpToQuestion(131);
    } else {
      _jumpToQuestion(147);
    }
  }

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
      final passages = ExamDataRepository.instance.passages;
      if (q.passageId != null && passages.containsKey(q.passageId)) {
        _part7Passage = passages[q.passageId]!;
      }
    });
  }

  void _navigateQuestion(int delta) {
    final newNum = _currentQuestionNumber + delta;
    if (newNum >= 101 && newNum <= 200) {
      _jumpToQuestion(newNum);
    }
  }

  void _toggleBookmark(int qNum) {
    setState(() {
      final q = _questions.firstWhere((item) => item.number == qNum);
      q.isFlagged = !q.isFlagged;
    });
  }

  void _chooseAnswer(int qNum, String choiceKey) {
    setState(() {
      final q = _questions.firstWhere((item) => item.number == qNum);
      q.selectedChoice = choiceKey;
    });
  }

  void _openMatrixSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuestionMatrixModal(
        questions: _questions,
        currentQuestionNumber: _currentQuestionNumber,
        onSelectQuestion: _jumpToQuestion,
      ),
    );
  }

  void _openSubmitDialog() {
    final answeredCount = _questions.where((q) => q.selectedChoice != null).length;
    showDialog(
      context: context,
      builder: (context) => SubmitConfirmationModal(
        totalQuestions: _questions.length,
        answeredCount: answeredCount,
        remainingTimeString: '$_formattedTime còn lại',
        onConfirmSubmit: _submitExam,
      ),
    );
  }

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
        builder: (context) => ExamResultScreen(
          resultData: result,
          questions: _questions,
          exam: widget.exam,
        ),
      ),
    );
  }

  void _showPauseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tạm dừng bài thi'),
        content: const Text(
          'Đồng hồ đếm ngược vẫn tiếp tục chạy theo quy chuẩn thi thật. Bạn có muốn thoát về danh sách đề thi không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục thi'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(100, 40),
            ),
            child: const Text('Thoát'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final answeredCount = _questions.where((q) => q.selectedChoice != null).length;
    final progressFraction = answeredCount / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Sticky Sub-header with Progress & Part Tabs
          _buildStickyHeader(answeredCount, progressFraction),
          // Scrollable Questions Body
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                children: [
                  if (_currentPart == PartType.part5)
                    _buildPart5View()
                  else
                    _buildPassageAndQuestionsView(),
                  const SizedBox(height: 14),
                  // Quick Question Number Slider
                  _buildQuickQuestionSlider(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomToolbar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      leading: IconButton(
        icon: const Icon(Icons.pause_circle_outline, size: 26),
        onPressed: _showPauseDialog,
      ),
      titleSpacing: 0,
      title: Text(
        'Full Reading Mock Exam',
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        // Countdown timer badge
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _secondsRemaining < 300
                ? AppColors.errorContainer
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.timer_outlined,
                size: 16,
                color: _secondsRemaining < 300
                    ? AppColors.error
                    : AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                _formattedTime,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _secondsRemaining < 300
                      ? AppColors.error
                      : AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(right: 16),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 16),
        ),
      ],
    );
  }

  Widget _buildStickyHeader(int answeredCount, double progressFraction) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryEmerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.exam.title,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Đang thi',
                        style: TextStyle(
                          color: AppColors.onSecondaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.fact_check,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$answeredCount/100 câu',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressFraction,
              minHeight: 5,
              backgroundColor: AppColors.surfaceContainer,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          // Part Segmented Tabs
          Row(
            children: [
              _buildPartTab(PartType.part5, 'Part 5', '101 - 130'),
              const SizedBox(width: 8),
              _buildPartTab(PartType.part6, 'Part 6', '131 - 146'),
              const SizedBox(width: 8),
              _buildPartTab(PartType.part7, 'Part 7', '147 - 200'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartTab(PartType part, String label, String range) {
    final isSelected = _currentPart == part;
    return Expanded(
      child: InkWell(
        onTap: () => _selectPart(part),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                range,
                style: TextStyle(
                  color: isSelected ? Colors.white70 : AppColors.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPart5View() {
    final q = _questions.firstWhere(
      (item) => item.number == _currentQuestionNumber,
      orElse: () => _questions.first,
    );
    return _buildQuestionCard(q);
  }

  Widget _buildPassageAndQuestionsView() {
    final currentQ = _questions.firstWhere(
      (q) => q.number == _currentQuestionNumber,
      orElse: () => _questions.firstWhere((q) => q.part == _currentPart),
    );

    final passageId = currentQ.passageId;
    final passages = ExamDataRepository.instance.passages;
    final passage = (passageId != null && passages.containsKey(passageId))
        ? passages[passageId]!
        : _part7Passage;

    final passageQuestions = _questions
        .where((q) => q.passageId != null && q.passageId == passageId)
        .toList();

    final questionsToRender = passageQuestions.isNotEmpty
        ? passageQuestions
        : [currentQ];

    final hasMeta = (passage.recipient != null && passage.recipient!.isNotEmpty) ||
        (passage.sender != null && passage.sender!.isNotEmpty) ||
        (passage.date != null && passage.date!.isNotEmpty) ||
        (passage.subject != null && passage.subject!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Passage Document Card
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sticky passage toolbar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                color: AppColors.surfaceContainerLow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryFixed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              passage.title,
                              style: const TextStyle(
                                color: AppColors.onPrimaryFixedVariant,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              passage.documentType,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Text(
                            'A-',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () {
                            if (_fontSizeScale > 0.8) {
                              setState(() => _fontSizeScale -= 0.1);
                            }
                          },
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainer,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: const Text(
                            'A+',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: () {
                            if (_fontSizeScale < 1.4) {
                              setState(() => _fontSizeScale += 0.1);
                            }
                          },
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainer,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          icon: Icon(
                            _isPassageExpanded
                                ? Icons.unfold_less
                                : Icons.unfold_more,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPassageExpanded = !_isPassageExpanded;
                            });
                          },
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          padding: EdgeInsets.zero,
                          style: IconButton.styleFrom(
                            backgroundColor: AppColors.surfaceContainer,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Passage body
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                constraints: BoxConstraints(
                  maxHeight: _isPassageExpanded ? 600 : 230,
                ),
                padding: const EdgeInsets.all(14),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Đoạn văn đọc hiểu (${questionsToRender.first.number} - ${questionsToRender.last.number}):',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (hasMeta) ...[
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (passage.recipient != null && passage.recipient!.isNotEmpty)
                                _buildMetaRow('To:', passage.recipient!),
                              if (passage.sender != null && passage.sender!.isNotEmpty)
                                _buildMetaRow('From:', passage.sender!),
                              if (passage.date != null && passage.date!.isNotEmpty)
                                _buildMetaRow('Date:', passage.date!),
                              if (passage.subject != null && passage.subject!.isNotEmpty)
                                _buildMetaRow('Subject:', passage.subject!),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      SelectableText(
                        passage.content,
                        style: TextStyle(
                          fontSize: 14 * _fontSizeScale,
                          height: 1.6,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...questionsToRender.map((q) => Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: _buildQuestionCard(q),
        )),
      ],
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 55,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuestionItem question) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${question.number}',
                      style: const TextStyle(
                        color: AppColors.onPrimaryFixed,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      question.categoryName,
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _toggleBookmark(question.number),
                icon: Icon(
                  question.isFlagged ? Icons.bookmark : Icons.bookmark_border,
                  color: question.isFlagged
                      ? AppColors.tertiary
                      : AppColors.outline,
                  size: 20,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: question.isFlagged
                      ? AppColors.tertiaryFixed
                      : AppColors.surfaceContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Question prompt
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 15,
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 14),
          // 4 Choices
          Column(
            children: question.choices.map((choice) {
              final isSelected = question.selectedChoice == choice.key;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () => _chooseAnswer(question.number, choice.key),
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 1.5)
                          : null,
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : AppColors.surfaceContainerHighest,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            choice.key,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            choice.content,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.onSurface,
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionSlider() {
    final int startNum;
    final int count;
    switch (_currentPart) {
      case PartType.part5:
        startNum = 101;
        count = 30;
        break;
      case PartType.part6:
        startNum = 131;
        count = 16;
        break;
      case PartType.part7:
        startNum = 147;
        count = 54;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.dialpad, size: 18, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    _currentPart == PartType.part5
                        ? 'Part 5 (101 - 130)'
                        : _currentPart == PartType.part6
                            ? 'Part 6 (131 - 146)'
                            : 'Part 7 (147 - 200)',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: _openMatrixSheet,
                child: const Row(
                  children: [
                    Text(
                      'Xem ma trận 100 câu',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(count, (index) {
                final qNum = startNum + index;
                final isCurrent = qNum == _currentQuestionNumber;
                final q = _questions.firstWhere(
                  (item) => item.number == qNum,
                  orElse: () => _questions[0],
                );
                final isAnswered = q.selectedChoice != null;
                final isFlagged = q.isFlagged;

                Color bg = AppColors.surfaceContainer;
                Color text = AppColors.onSurfaceVariant;

                if (isCurrent) {
                  bg = AppColors.primary;
                  text = Colors.white;
                } else if (isFlagged) {
                  bg = AppColors.tertiaryFixed;
                  text = AppColors.tertiary;
                } else if (isAnswered) {
                  bg = AppColors.secondaryContainer;
                  text = AppColors.onSecondaryContainer;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _jumpToQuestion(qNum),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(10),
                        border: isCurrent
                            ? Border.all(color: AppColors.primary, width: 2)
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$qNum',
                        style: TextStyle(
                          color: text,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            // Matrix button
            OutlinedButton(
              onPressed: _openMatrixSheet,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.grid_view, size: 16),
                  SizedBox(width: 4),
                  Text('Ma trận', style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            // Prev button
            Expanded(
              child: OutlinedButton(
                onPressed: _currentQuestionNumber > 101 ? () => _navigateQuestion(-1) : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.chevron_left, size: 16),
                    Text('Trước', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Next button
            Expanded(
              child: OutlinedButton(
                onPressed: _currentQuestionNumber < 200 ? () => _navigateQuestion(1) : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Tiếp', style: TextStyle(fontSize: 12)),
                    Icon(Icons.chevron_right, size: 16),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Submit button
            ElevatedButton(
              onPressed: _openSubmitDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Nộp bài',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
