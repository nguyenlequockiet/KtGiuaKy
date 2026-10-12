import 'package:flutter/material.dart';
import '../data/exam_data_repository.dart';
import '../models/exam_models.dart';
import '../theme/app_colors.dart';
import 'exam_review_screen.dart';

class ExamQuestionEditorScreen extends StatefulWidget {
  final ExamItem exam;

  const ExamQuestionEditorScreen({super.key, required this.exam});

  @override
  State<ExamQuestionEditorScreen> createState() => _ExamQuestionEditorScreenState();
}

class _ExamQuestionEditorScreenState extends State<ExamQuestionEditorScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedPartFilter = 'all'; // 'all', 'part5', 'part6', 'part7'
  late List<QuestionItem> _questions;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    _questions = List.from(ExamDataRepository.instance.questions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<QuestionItem> get _filteredQuestions {
    final query = _searchController.text.trim().toLowerCase();
    return _questions.where((q) {
      final matchesPart = _selectedPartFilter == 'all' ||
          (_selectedPartFilter == 'part5' && q.part == PartType.part5) ||
          (_selectedPartFilter == 'part6' && q.part == PartType.part6) ||
          (_selectedPartFilter == 'part7' && q.part == PartType.part7);

      final matchesQuery = query.isEmpty ||
          q.number.toString().contains(query) ||
          q.prompt.toLowerCase().contains(query) ||
          q.categoryName.toLowerCase().contains(query);

      return matchesPart && matchesQuery;
    }).toList();
  }

  void _editQuestion(QuestionItem q) {
    final promptCtrl = TextEditingController(text: q.prompt);
    final catCtrl = TextEditingController(text: q.categoryName);
    final expCtrl = TextEditingController(text: q.explanation ?? '');

    String getChoice(String key) {
      final found = q.choices.where((c) => c.key == key);
      return found.isNotEmpty ? found.first.content : '';
    }

    final choiceACtrl = TextEditingController(text: getChoice('A'));
    final choiceBCtrl = TextEditingController(text: getChoice('B'));
    final choiceCCtrl = TextEditingController(text: getChoice('C'));
    final choiceDCtrl = TextEditingController(text: getChoice('D'));

    String selectedCorrectKey = q.correctChoiceKey ?? 'A';
    PartType selectedPart = q.part;

    // Check if question has a passage
    final passage = q.passageId != null && ExamDataRepository.instance.passages.containsKey(q.passageId)
        ? ExamDataRepository.instance.passages[q.passageId]
        : null;
    final passageCtrl = TextEditingController(text: passage?.content ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'Câu ${q.number}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Chỉnh sửa chi tiết câu hỏi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ),

                  // Form content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Part selection & Category
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Phần thi (Part)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<PartType>(
                                          isExpanded: true,
                                          value: selectedPart,
                                          items: const [
                                            DropdownMenuItem(value: PartType.part5, child: Text('Part 5')),
                                            DropdownMenuItem(value: PartType.part6, child: Text('Part 6')),
                                            DropdownMenuItem(value: PartType.part7, child: Text('Part 7')),
                                          ],
                                          onChanged: (val) {
                                            if (val != null) setModalState(() => selectedPart = val);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Dạng câu hỏi / Chủ điểm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: catCtrl,
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.surfaceContainerLow,
                                        hintText: 'VD: Từ loại (Danh từ)',
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Prompt
                          const Text('Đề bài / Câu hỏi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: promptCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Correct Choice Selector
                          const Text('Đáp án đúng:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          Row(
                            children: ['A', 'B', 'C', 'D'].map((key) {
                              final isSelected = selectedCorrectKey == key;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: InkWell(
                                    onTap: () => setModalState(() => selectedCorrectKey = key),
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppColors.secondaryEmerald : AppColors.surfaceContainerLow,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: isSelected ? AppColors.secondaryEmerald : const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        key,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: isSelected ? Colors.white : AppColors.onSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 14),

                          // 4 Choices Inputs
                          const Text('Các lựa chọn trả lời:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 8),
                          _buildChoiceInput('A', choiceACtrl, selectedCorrectKey == 'A'),
                          const SizedBox(height: 8),
                          _buildChoiceInput('B', choiceBCtrl, selectedCorrectKey == 'B'),
                          const SizedBox(height: 8),
                          _buildChoiceInput('C', choiceCCtrl, selectedCorrectKey == 'C'),
                          const SizedBox(height: 8),
                          _buildChoiceInput('D', choiceDCtrl, selectedCorrectKey == 'D'),
                          const SizedBox(height: 14),

                          // Explanation
                          const Text('Giải thích / Dịch nghĩa / Từ khóa:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: expCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: AppColors.surfaceContainerLow,
                              hintText: 'Nhập lời giải chi tiết cho câu hỏi...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Passage content if applicable
                          if (passage != null) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Đoạn văn đọc hiểu (${passage.title}):',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryFixed,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    passage.documentType,
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.onPrimaryFixedVariant),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: passageCtrl,
                              maxLines: 4,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: AppColors.surfaceContainerLow,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.all(12),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Buttons
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Hủy'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final updatedQuestion = QuestionItem(
                                number: q.number,
                                part: selectedPart,
                                categoryName: catCtrl.text.trim().isEmpty ? q.categoryName : catCtrl.text.trim(),
                                prompt: promptCtrl.text.trim(),
                                correctChoiceKey: selectedCorrectKey,
                                explanation: expCtrl.text.trim(),
                                passageId: q.passageId,
                                isFlagged: q.isFlagged,
                                selectedChoice: q.selectedChoice,
                                choices: [
                                  QuestionChoice(key: 'A', content: choiceACtrl.text.trim()),
                                  QuestionChoice(key: 'B', content: choiceBCtrl.text.trim()),
                                  QuestionChoice(key: 'C', content: choiceCCtrl.text.trim()),
                                  QuestionChoice(key: 'D', content: choiceDCtrl.text.trim()),
                                ],
                              );

                              // Save in repository
                              ExamDataRepository.instance.updateQuestion(updatedQuestion);

                              // Update passage if edited
                              if (passage != null && passageCtrl.text.trim() != passage.content) {
                                ExamDataRepository.instance.updatePassage(
                                  passage.id,
                                  passageCtrl.text.trim(),
                                );
                              }

                              setState(() {
                                _loadQuestions();
                              });

                              Navigator.pop(ctx);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                      const SizedBox(width: 8),
                                      Text('Đã cập nhật thành công Câu ${q.number}!'),
                                    ],
                                  ),
                                  backgroundColor: AppColors.secondaryEmerald,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text('Lưu câu hỏi', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryContainer,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChoiceInput(String key, TextEditingController ctrl, bool isCorrect) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isCorrect ? AppColors.secondaryEmerald : AppColors.surfaceContainerHigh,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            key,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isCorrect ? Colors.white : AppColors.onSurface,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: isCorrect ? const BorderSide(color: AppColors.secondaryEmerald, width: 1.5) : BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredQuestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.surfaceContainerLowest,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản Lý Nội Dung Đề Thi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.exam.title} • 100 câu',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Xem trước lời giải & Dịch nghĩa',
            icon: const Icon(Icons.menu_book, color: AppColors.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExamReviewScreen(
                    examTitle: widget.exam.title,
                    questions: ExamDataRepository.instance.questions,
                    passages: ExamDataRepository.instance.passages,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search bar
          Container(
            color: AppColors.surfaceContainerLowest,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Tìm theo số câu (VD: 101, 147) hoặc từ khóa...',
                    hintStyle: const TextStyle(fontSize: 13),
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.surfaceContainerLow,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),
                // Part Filter Pills
                Row(
                  children: [
                    _buildPartFilterChip('all', 'Tất cả (100)'),
                    const SizedBox(width: 6),
                    _buildPartFilterChip('part5', 'Part 5 (30)'),
                    const SizedBox(width: 6),
                    _buildPartFilterChip('part6', 'Part 6 (16)'),
                    const SizedBox(width: 6),
                    _buildPartFilterChip('part7', 'Part 7 (54)'),
                  ],
                ),
              ],
            ),
          ),

          // List of questions
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 48, color: AppColors.outline),
                        SizedBox(height: 12),
                        Text(
                          'Không tìm thấy câu hỏi phù hợp!',
                          style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(14),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildQuestionCard(filtered[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartFilterChip(String key, String label) {
    final isSelected = _selectedPartFilter == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedPartFilter = key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(QuestionItem q) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primaryFixed,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${q.number}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onPrimaryFixed,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      q.part == PartType.part5
                          ? 'Part 5'
                          : q.part == PartType.part6
                              ? 'Part 6'
                              : 'Part 7',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      q.categoryName,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Đáp án: ${q.correctChoiceKey ?? "-"}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Question Prompt
          Text(
            q.prompt,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),

          // Choices mini overview
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: q.choices.map((c) {
              final isCorrect = c.key == q.correctChoiceKey;
              return Text(
                '${c.key}. ${c.content}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isCorrect ? FontWeight.bold : FontWeight.normal,
                  color: isCorrect ? AppColors.secondaryEmerald : AppColors.onSurfaceVariant,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExamReviewScreen(
                        examTitle: widget.exam.title,
                        questions: ExamDataRepository.instance.questions,
                        passages: ExamDataRepository.instance.passages,
                        initialQuestionNumber: q.number,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book, size: 15, color: AppColors.secondaryEmerald),
                label: const Text(
                  'Xem lời giải',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.secondaryEmerald),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: AppColors.secondaryEmerald),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _editQuestion(q),
                icon: const Icon(Icons.edit, size: 15, color: AppColors.primary),
                label: const Text(
                  'Sửa câu này',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
