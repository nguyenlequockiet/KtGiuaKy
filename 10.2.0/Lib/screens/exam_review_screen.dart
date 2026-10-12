import 'package:flutter/material.dart';
import '../data/exam_data_repository.dart';
import '../models/exam_models.dart';
import '../theme/app_colors.dart';

class ExamReviewScreen extends StatefulWidget {
  final String? examTitle;
  final List<QuestionItem>? questions;
  final Map<String, ReadingPassage>? passages;
  final int? initialQuestionNumber;

  const ExamReviewScreen({
    super.key,
    this.examTitle,
    this.questions,
    this.passages,
    this.initialQuestionNumber,
  });

  @override
  State<ExamReviewScreen> createState() => _ExamReviewScreenState();
}

class _ExamReviewScreenState extends State<ExamReviewScreen> {
  late List<QuestionItem> _questions;
  late Map<String, ReadingPassage> _passages;
  late String _examTitle;
  late PartType _selectedPart;
  late int _selectedQuestion;
  String _filterMode = 'all'; // 'all', 'wrong', 'correct', 'skipped'

  @override
  void initState() {
    super.initState();
    _questions = widget.questions ?? ExamDataRepository.instance.questions;
    _passages = widget.passages ?? ExamDataRepository.instance.passages;
    _examTitle = widget.examTitle ?? 'ETS TOEIC 2024 - Test 06';

    final initQ = widget.initialQuestionNumber;
    if (initQ != null) {
      _selectedQuestion = initQ;
      final match = _questions.firstWhere(
        (q) => q.number == initQ,
        orElse: () => _questions.first,
      );
      _selectedPart = match.part;
    } else {
      _selectedPart = PartType.part7;
      final part7Questions = _questions.where((q) => q.part == PartType.part7).toList();
      _selectedQuestion = part7Questions.isNotEmpty ? part7Questions.first.number : 147;
    }
  }

  List<QuestionItem> get _currentPartQuestions {
    return _questions.where((q) => q.part == _selectedPart).toList();
  }

  List<QuestionItem> get _filteredSelectorQuestions {
    final partQs = _currentPartQuestions;
    if (_filterMode == 'wrong') {
      return partQs.where((q) => q.selectedChoice != null && q.selectedChoice != q.correctChoiceKey).toList();
    } else if (_filterMode == 'correct') {
      return partQs.where((q) => q.selectedChoice != null && q.selectedChoice == q.correctChoiceKey).toList();
    } else if (_filterMode == 'skipped') {
      return partQs.where((q) => q.selectedChoice == null || q.selectedChoice!.isEmpty).toList();
    }
    return partQs;
  }

  void _onPartChanged(PartType part) {
    setState(() {
      _selectedPart = part;
      _filterMode = 'all';
      final partQs = _questions.where((q) => q.part == part).toList();
      if (partQs.isNotEmpty) {
        _selectedQuestion = partQs.first.number;
      }
    });
  }

  void _onQuestionSelected(int qNum) {
    setState(() {
      _selectedQuestion = qNum;
      final match = _questions.firstWhere((q) => q.number == qNum, orElse: () => _questions.first);
      _selectedPart = match.part;
    });
  }

  void _navigateDelta(int delta) {
    final currentIndex = _questions.indexWhere((q) => q.number == _selectedQuestion);
    if (currentIndex != -1) {
      final newIndex = currentIndex + delta;
      if (newIndex >= 0 && newIndex < _questions.length) {
        _onQuestionSelected(_questions[newIndex].number);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQ = _questions.firstWhere(
      (q) => q.number == _selectedQuestion,
      orElse: () => _questions.first,
    );

    final hasPassage = currentQ.passageId != null && _passages.containsKey(currentQ.passageId);
    final passage = hasPassage ? _passages[currentQ.passageId]! : null;
    final passageQuestions = hasPassage
        ? _questions.where((q) => q.passageId == currentQ.passageId).toList()
        : [currentQ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Part selector & Quality metric badges
            _buildQualityHeader(),
            const SizedBox(height: 12),

            // Quick question selector
            _buildQuickSelector(passageQuestions),
            const SizedBox(height: 14),

            // Section title
            _buildSectionHeader(passage, passageQuestions, currentQ),
            const SizedBox(height: 10),

            // Reading Passage if available (Part 6 & Part 7)
            if (passage != null) ...[
              _buildPassageCard(passage),
              const SizedBox(height: 14),
            ],

            // Questions to review
            if (hasPassage)
              ...passageQuestions.map((q) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _buildQuestionReviewCard(
                      q,
                      isHighlighted: q.number == _selectedQuestion,
                    ),
                  ))
            else
              _buildQuestionReviewCard(currentQ, isHighlighted: true),

            const SizedBox(height: 10),
            // Bottom navigation between questions
            _buildBottomNavRow(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surfaceContainerLowest,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Xem Trước & Lời Giải',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _examTitle,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              Text(
                ' • ${_questions.length} Câu • 75\'',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          tooltip: 'Thông tin bài giải',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đang hiển thị lời giải chi tiết cho $_examTitle'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildQualityHeader() {
    final p5Count = _questions.where((q) => q.part == PartType.part5).length;
    final p6Count = _questions.where((q) => q.part == PartType.part6).length;
    final p7Count = _questions.where((q) => q.part == PartType.part7).length;

    final total = _questions.length;
    final answered = _questions.where((q) => q.selectedChoice != null && q.selectedChoice!.isNotEmpty).length;
    final correct = _questions.where((q) => q.selectedChoice != null && q.selectedChoice == q.correctChoiceKey).length;
    final hasAnswers = answered > 0;

    final withExp = _questions.where((q) => q.explanation != null && q.explanation!.trim().isNotEmpty).length;
    final expPercent = total > 0 ? ((withExp / total) * 100).round() : 100;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Part tabs
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildPartButton(PartType.part5, 'Part 5', '(${p5Count}Q)'),
                _buildPartButton(PartType.part6, 'Part 6', '(${p6Count}Q)'),
                _buildPartButton(PartType.part7, 'Part 7', '(${p7Count}Q)'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Quality metrics row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.verified, size: 14, color: AppColors.secondary),
                      const SizedBox(width: 4),
                      Text(
                        hasAnswers ? 'Đúng $correct/$total' : 'Hợp lệ 100%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSecondaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_stories, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        hasAnswers ? 'Đã làm $answered/$total' : '${_passages.length} Bài đọc',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryFixed.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.psychology, size: 14, color: AppColors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Giải thích $expPercent%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onPrimaryFixedVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPartButton(PartType part, String label, String count) {
    final isSelected = _selectedPart == part;
    return Expanded(
      child: InkWell(
        onTap: () => _onPartChanged(part),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 2),
              Text(
                count,
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? Colors.white70 : AppColors.outline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickSelector(List<QuestionItem> passageQuestions) {
    final partName = _selectedPart == PartType.part5
        ? 'Part 5'
        : _selectedPart == PartType.part6
            ? 'Part 6'
            : 'Part 7';

    final rangeText = passageQuestions.length > 1
        ? 'Đang xem ${passageQuestions.first.number} - ${passageQuestions.last.number}'
        : 'Đang xem câu $_selectedQuestion';

    final selectorQuestions = _filteredSelectorQuestions;
    final answeredInPart = _currentPartQuestions.where((q) => q.selectedChoice != null).length;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.format_list_numbered, size: 16, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Chọn nhanh câu hỏi $partName',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 13, color: AppColors.secondaryEmerald),
                  const SizedBox(width: 3),
                  Text(
                    rangeText,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryEmerald,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (answeredInPart > 0) ...[
            const SizedBox(height: 8),
            // Filter mode chips (All, Wrong, Correct)
            Row(
              children: [
                _buildFilterChip('all', 'Tất cả (${_currentPartQuestions.length})'),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'wrong',
                  'Sai (${_currentPartQuestions.where((q) => q.selectedChoice != null && q.selectedChoice != q.correctChoiceKey).length})',
                  color: AppColors.error,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  'correct',
                  'Đúng (${_currentPartQuestions.where((q) => q.selectedChoice != null && q.selectedChoice == q.correctChoiceKey).length})',
                  color: AppColors.secondaryEmerald,
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: selectorQuestions.map((q) {
                final isSelected = _selectedQuestion == q.number;
                final isAnswered = q.selectedChoice != null && q.selectedChoice!.isNotEmpty;
                final isCorrect = isAnswered && q.selectedChoice == q.correctChoiceKey;
                final isWrong = isAnswered && !isCorrect;

                Color bgColor;
                Color textColor;
                Border? border;

                if (isSelected) {
                  bgColor = AppColors.primary;
                  textColor = Colors.white;
                  border = Border.all(color: AppColors.primary, width: 2);
                } else if (isCorrect) {
                  bgColor = const Color(0xFFE8F5E9);
                  textColor = const Color(0xFF1B5E20);
                  border = Border.all(color: AppColors.secondaryEmerald, width: 1.5);
                } else if (isWrong) {
                  bgColor = const Color(0xFFFFEBEE);
                  textColor = AppColors.error;
                  border = Border.all(color: AppColors.error, width: 1.5);
                } else {
                  bgColor = AppColors.surfaceContainerLow;
                  textColor = AppColors.onSurface;
                }

                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: InkWell(
                    onTap: () => _onQuestionSelected(q.number),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: border,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${q.number}',
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String mode, String label, {Color? color}) {
    final isSelected = _filterMode == mode;
    final activeColor = color ?? AppColors.primary;
    return InkWell(
      onTap: () {
        setState(() {
          _filterMode = mode;
          final filtered = _filteredSelectorQuestions;
          if (filtered.isNotEmpty && !filtered.any((q) => q.number == _selectedQuestion)) {
            _selectedQuestion = filtered.first.number;
          }
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: activeColor, width: 1) : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? activeColor : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    ReadingPassage? passage,
    List<QuestionItem> passageQuestions,
    QuestionItem currentQ,
  ) {
    String sectionTitle;
    String rangeSubtitle;

    if (passage != null) {
      final isMulti = passage.content.contains('--- TIẾP THEO ---');
      sectionTitle = isMulti
          ? 'Đoạn văn kép / ba (${passage.documentType})'
          : 'Đoạn văn đọc hiểu (${passage.documentType})';
      rangeSubtitle = passageQuestions.length > 1
          ? 'Câu ${passageQuestions.first.number} - ${passageQuestions.last.number}'
          : 'Câu ${currentQ.number}';
    } else {
      sectionTitle = _selectedPart == PartType.part5
          ? 'Part 5: Hoàn thành câu (Incomplete Sentences)'
          : 'Part 6: Điền đoạn văn (Text Completion)';
      rangeSubtitle = 'Câu ${currentQ.number} / ${_questions.last.number}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sectionTitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          rangeSubtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPassageCard(ReadingPassage passage) {
    final subDocs = passage.content.split(RegExp(r'\n*---\s*TIẾP THEO\s*---\n*'));
    final hasMeta = (passage.recipient != null && passage.recipient!.isNotEmpty) ||
        (passage.sender != null && passage.sender!.isNotEmpty) ||
        (passage.date != null && passage.date!.isNotEmpty) ||
        (passage.subject != null && passage.subject!.isNotEmpty);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      passage.documentType.toLowerCase().contains('email')
                          ? Icons.mail
                          : passage.documentType.toLowerCase().contains('chat')
                              ? Icons.chat
                              : Icons.article,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${passage.title.toUpperCase()} • ${passage.documentType.toUpperCase()}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '✓ Hợp lệ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSecondaryContainer,
                  ),
                ),
              ),
            ],
          ),
          if (hasMeta) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (passage.recipient != null && passage.recipient!.isNotEmpty)
                    Text('To: ${passage.recipient}', style: const TextStyle(fontSize: 11)),
                  if (passage.date != null && passage.date!.isNotEmpty)
                    Text('Date: ${passage.date}', style: const TextStyle(fontSize: 11)),
                  if (passage.sender != null && passage.sender!.isNotEmpty)
                    Text('From: ${passage.sender}', style: const TextStyle(fontSize: 11)),
                  if (passage.subject != null && passage.subject!.isNotEmpty) ...[
                    const Divider(height: 8),
                    Text(
                      'Subject: ${passage.subject}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 10),
          ...subDocs.asMap().entries.map((entry) {
            final idx = entry.key;
            final text = entry.value.trim();
            final isMulti = subDocs.length > 1;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (isMulti) ...[
                  if (idx > 0) const Divider(height: 24, thickness: 1),
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'VĂN BẢN ${idx + 1} / ${subDocs.length}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildQuestionReviewCard(QuestionItem q, {bool isHighlighted = false}) {
    final isAnswered = q.selectedChoice != null && q.selectedChoice!.isNotEmpty;
    final isCorrect = isAnswered && q.selectedChoice == q.correctChoiceKey;
    final isWrong = isAnswered && !isCorrect;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isHighlighted ? AppColors.primary : const Color(0xFFE2E8F0),
          width: isHighlighted ? 1.8 : 1.0,
        ),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isHighlighted ? AppColors.primary : AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Câu ${q.number}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isHighlighted ? Colors.white : AppColors.onPrimaryFixed,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      q.categoryName,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isCorrect)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check, size: 12, color: Color(0xFF2E7D32)),
                          SizedBox(width: 2),
                          Text(
                            'Bạn làm đúng',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isWrong)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.close, size: 12, color: AppColors.error),
                          const SizedBox(width: 2),
                          Text(
                            'Bạn chọn: ${q.selectedChoice}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Đáp án đúng: ${q.correctChoiceKey}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: AppColors.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Prompt
          Text(
            q.prompt,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13.5,
              height: 1.4,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 10),

          // Choices list
          ...q.choices.map((c) {
            final isChoiceCorrect = c.key == q.correctChoiceKey;
            final isUserChoice = c.key == q.selectedChoice;

            Color choiceBg;
            Color choiceBorder;
            Color textColor;
            Widget? trailingIcon;

            if (isChoiceCorrect) {
              choiceBg = const Color(0xFFE8F5E9);
              choiceBorder = const Color(0xFF81C784);
              textColor = const Color(0xFF1B5E20);
              trailingIcon = const Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32));
            } else if (isUserChoice && isWrong) {
              choiceBg = const Color(0xFFFFEBEE);
              choiceBorder = const Color(0xFFE57373);
              textColor = AppColors.error;
              trailingIcon = const Icon(Icons.cancel, size: 16, color: AppColors.error);
            } else {
              choiceBg = AppColors.surfaceContainerLow;
              choiceBorder = const Color(0xFFE2E8F0);
              textColor = AppColors.onSurface;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: choiceBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: choiceBorder),
              ),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: isChoiceCorrect
                          ? const Color(0xFF2E7D32)
                          : isUserChoice && isWrong
                              ? AppColors.error
                              : AppColors.surfaceContainerHigh,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c.key,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: (isChoiceCorrect || (isUserChoice && isWrong))
                            ? Colors.white
                            : AppColors.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      c.content,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isChoiceCorrect ? FontWeight.bold : FontWeight.normal,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) trailingIcon,
                ],
              ),
            );
          }),
          const SizedBox(height: 10),

          // Explanatory breakdown: Detailed Solution & Translation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.secondaryEmerald.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 16, color: AppColors.secondaryEmerald),
                    SizedBox(width: 6),
                    Text(
                      'Lời giải chi tiết & Dịch nghĩa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  (q.explanation != null && q.explanation!.trim().isNotEmpty)
                      ? q.explanation!
                      : 'Đang cập nhật lời giải chi tiết cho câu hỏi này.',
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.5,
                    color: AppColors.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavRow() {
    final currentIndex = _questions.indexWhere((q) => q.number == _selectedQuestion);
    final hasPrev = currentIndex > 0;
    final hasNext = currentIndex != -1 && currentIndex < _questions.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        OutlinedButton.icon(
          onPressed: hasPrev ? () => _navigateDelta(-1) : null,
          icon: const Icon(Icons.arrow_back_ios, size: 14),
          label: const Text('Câu trước'),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFCBD5E1)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        ElevatedButton.icon(
          onPressed: hasNext ? () => _navigateDelta(1) : null,
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          label: const Text('Câu tiếp theo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
