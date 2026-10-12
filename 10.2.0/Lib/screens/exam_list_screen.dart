import 'package:flutter/material.dart';
import '../data/exam_data_repository.dart';
import '../models/exam_models.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_bottom_nav.dart';
import 'exam_import_screen.dart';
import 'exam_taking_screen.dart';
import 'exam_question_editor_screen.dart';
import 'exam_review_screen.dart';

class ExamListScreen extends StatefulWidget {
  const ExamListScreen({super.key});

  @override
  State<ExamListScreen> createState() => _ExamListScreenState();
}

class _ExamListScreenState extends State<ExamListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  int _navIndex = 0;

  // Danh sách đề thi được làm rỗng để chuẩn bị import từ file Word
  final List<ExamItem> _allExams = [];

  void _openImportScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ExamImportScreen()),
    );
    if (result != null) {
      final title = (result is String && result.isNotEmpty)
          ? result
          : 'ETS TOEIC 2024 - Test 06';
      setState(() {
        _allExams.add(
          ExamItem(
            id: 'exam_${DateTime.now().millisecondsSinceEpoch}',
            title: title,
            description: 'Độ khó: Tiêu chuẩn ETS (100 câu Part 5, 6, 7)',
            category: 'full',
            durationMinutes: 75,
            totalQuestions: 100,
            isLatest: true,
            actionText: 'Bắt đầu làm bài',
          ),
        );
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ExamItem> get _filteredExams {
    final query = _searchController.text.trim().toLowerCase();
    return _allExams.where((exam) {
      final matchesQuery = query.isEmpty ||
          exam.title.toLowerCase().contains(query) ||
          exam.description.toLowerCase().contains(query);
      final matchesFilter =
          _selectedFilter == 'all' || exam.category == _selectedFilter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  void _startExam(ExamItem exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamTakingScreen(exam: exam),
      ),
    );
  }

  void _openQuestionEditor(ExamItem exam) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExamQuestionEditorScreen(exam: exam),
      ),
    );
  }

  void _showEditExamDialog(ExamItem exam) {
    final titleController = TextEditingController(text: exam.title);
    final descController = TextEditingController(text: exam.description);
    final durationController =
        TextEditingController(text: exam.durationMinutes.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.edit, color: AppColors.primary, size: 22),
            SizedBox(width: 8),
            Text('Sửa thông tin đề thi'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tên đề thi:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Mô tả đề thi:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Thời gian làm bài (phút):',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: durationController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTitle = titleController.text.trim();
              if (newTitle.isEmpty) return;
              final newDuration =
                  int.tryParse(durationController.text.trim()) ??
                      exam.durationMinutes;

              setState(() {
                final index = _allExams.indexWhere((e) => e.id == exam.id);
                if (index != -1) {
                  _allExams[index] = ExamItem(
                    id: exam.id,
                    title: newTitle,
                    description: descController.text.trim(),
                    category: exam.category,
                    durationMinutes: newDuration,
                    totalQuestions: exam.totalQuestions,
                    scoreBadge: exam.scoreBadge,
                    isLatest: exam.isLatest,
                    inProgressQuestions: exam.inProgressQuestions,
                    remainingMinutes: exam.remainingMinutes,
                    difficultyBadge: exam.difficultyBadge,
                    viewCount: exam.viewCount,
                    averageScore: exam.averageScore,
                    actionText: exam.actionText,
                  );
                }
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã cập nhật thông tin đề thi!'),
                  backgroundColor: AppColors.secondary,
                ),
              );
            },
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  void _showDeleteExamDialog(ExamItem exam) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            SizedBox(width: 8),
            Text('Xác nhận xóa đề thi'),
          ],
        ),
        content: Text(
          'Bạn có chắc chắn muốn xóa đề thi "${exam.title}" không? Hành động này sẽ loại bỏ đề thi khỏi danh sách.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _allExams.removeWhere((e) => e.id == exam.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xóa đề thi "${exam.title}" thành công!'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Xóa đề thi'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredExams;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Motivational Greeting Section
            _buildGreetingSection(),
            const SizedBox(height: 16),
            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 14),
            // Filter Pills Horizontal Bar
            _buildFilterPills(),
            const SizedBox(height: 16),
            // Goal & 7-Day Streak Card
            _buildGoalStreakCard(),
            const SizedBox(height: 20),
            // Section Title
            _buildSectionHeader(filtered.length),
            const SizedBox(height: 12),
            // Exam Cards List or Empty State
            if (filtered.isEmpty)
              _buildEmptyState()
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  return _buildExamCard(filtered[index]);
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openImportScreen,
        backgroundColor: AppColors.primaryContainer,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.upload_file),
        label: const Text(
          'Import từ Word',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _navIndex,
        onTap: (index) {
          setState(() => _navIndex = index);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TOEIC Reading',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Đề Thi Chuẩn ETS',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        // Import Word action button
        IconButton(
          tooltip: 'Nhập đề từ file Word (.docx)',
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.upload_file,
              color: AppColors.primaryContainer,
              size: 20,
            ),
          ),
          onPressed: _openImportScreen,
        ),
        // Streak pill
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppColors.tertiaryContainer,
                size: 18,
              ),
              SizedBox(width: 4),
              Text(
                '0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // Avatar
        Container(
          width: 34,
          height: 34,
          margin: const EdgeInsets.only(right: 16),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 18),
        ),
      ],
    );
  }

  Widget _buildGreetingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.school, size: 14, color: AppColors.primary),
                ),
                const SizedBox(width: 6),
                Text(
                  'Luyện thi TOEIC Reading',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondaryFixed,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Bộ đề 2024',
                style: TextStyle(
                  color: AppColors.onSecondaryFixed,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Sẵn sàng chinh phục 450+ Reading!',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                fontSize: 22,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Luyện tập phản xạ, tối ưu quản lý thời gian 75 phút cho trọn vẹn 100 câu đọc hiểu.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Tìm đề thi, bộ đề ETS, Hacker...',
          hintStyle: const TextStyle(color: AppColors.outline, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: AppColors.outline),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.cancel, color: AppColors.outline, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilterPills() {
    final filters = [
      {'key': 'all', 'label': 'Tất cả'},
      {'key': 'full', 'label': 'Full Test Reading'},
      {'key': 'part5', 'label': 'Part 5'},
      {'key': 'part6', 'label': 'Part 6'},
      {'key': 'part7', 'label': 'Part 7'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() => _selectedFilter = f['key']!);
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
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
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalStreakCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.military_tech,
                      color: AppColors.primaryContainer,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mục tiêu: 450+ Reading',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontSize: 16,
                            ),
                      ),
                      Text(
                        'Hoàn thành 4/5 đề tuần này',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tertiaryFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: AppColors.tertiary,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      '7 Ngày',
                      style: TextStyle(
                        color: AppColors.onTertiaryFixedVariant,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Weekly progress bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tiến độ tuần (80%)',
                style: Theme.of(context).textTheme.labelSmall,
              ),
              const Text(
                '4/5 Đề',
                style: TextStyle(
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.8,
              minHeight: 8,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryContainer),
            ),
          ),
          const SizedBox(height: 14),
          // Day streak dots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStreakDot('T2', true),
              _buildStreakDot('T3', true),
              _buildStreakDot('T4', true),
              _buildStreakDot('T5', true),
              _buildStreakDot('T6', true),
              _buildStreakDot('T7', true),
              _buildStreakDot('CN', false, isToday: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStreakDot(String day, bool completed, {bool isToday = false}) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            color: isToday ? AppColors.primary : AppColors.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: isToday
                ? AppColors.primaryContainer
                : completed
                    ? AppColors.secondaryFixed
                    : AppColors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: isToday
              ? const Text(
                  '●',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                )
              : completed
                  ? const Text(
                      '✓',
                      style: TextStyle(
                        color: AppColors.onSecondaryFixed,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  : null,
        ),
      ],
    );
  }

  Widget _buildSectionHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              'Danh sách đề thi',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontSize: 18,
                  ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count Đề',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        const Row(
          children: [
            Icon(Icons.swap_vert, size: 16, color: AppColors.onSurfaceVariant),
            SizedBox(width: 2),
            Text(
              'Mới nhất',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExamCard(ExamItem exam) {
    final isInProgress = exam.inProgressQuestions != null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
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
          // Badges row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (isInProgress)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Đang làm dở (${exam.inProgressQuestions}/${exam.totalQuestions})',
                        style: const TextStyle(
                          color: AppColors.onTertiaryFixedVariant,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryFixed,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        exam.category == 'part7' ? 'Chuyên đề Part 7' : 'Full Reading',
                        style: const TextStyle(
                          color: AppColors.onPrimaryFixed,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    if (exam.isLatest) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryFixed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Mới nhất',
                          style: TextStyle(
                            color: AppColors.onSecondaryFixed,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
              if (exam.scoreBadge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.emoji_events,
                        size: 16,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        exam.scoreBadge!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                )
              else if (isInProgress)
                Text(
                  'Còn ${exam.remainingMinutes} phút',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
          const SizedBox(height: 10),
          // Title & Description
          Text(
            exam.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 17,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            exam.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (isInProgress) ...[
            const SizedBox(height: 10),
            // In progress bar
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Đã hoàn thành',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                      Text(
                        '42% (${exam.inProgressQuestions}/${exam.totalQuestions} câu)',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: const LinearProgressIndicator(
                      value: 0.42,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor:
                          AlwaysStoppedAnimation(AppColors.primaryContainer),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Metrics 2-column grid
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.schedule, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Thời gian',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                ),
                          ),
                          Text(
                            '${exam.durationMinutes} phút',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description, size: 18, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tổng số câu',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontSize: 10,
                                ),
                          ),
                          Text(
                            '${exam.totalQuestions} câu',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Actions row: Start exam button + Edit button + Delete button
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _startExam(exam),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isInProgress
                            ? Icons.play_arrow
                            : exam.category == 'part7'
                                ? Icons.auto_stories
                                : Icons.play_circle,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        exam.actionText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Nút Sửa đề
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: IconButton(
                  tooltip: 'Sửa thông tin đề thi',
                  icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  onPressed: () => _showEditExamDialog(exam),
                ),
              ),
              const SizedBox(width: 6),
              // Nút Xóa đề
              Container(
                decoration: BoxDecoration(
                  color: AppColors.errorContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: IconButton(
                  tooltip: 'Xóa đề thi',
                  icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.error),
                  onPressed: () => _showDeleteExamDialog(exam),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExamReviewScreen(
                          examTitle: exam.title,
                          questions: ExamDataRepository.instance.questions,
                          passages: ExamDataRepository.instance.passages,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.menu_book, size: 16, color: AppColors.secondaryEmerald),
                  label: const Text(
                    'Xem lời giải & dịch',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.secondaryEmerald,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    side: const BorderSide(color: AppColors.secondaryEmerald),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _openQuestionEditor(exam),
                  icon: const Icon(Icons.edit_note, size: 16, color: AppColors.primary),
                  label: const Text(
                    'Sửa câu (Admin)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(38),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasNoExamsAtAll = _allExams.isEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasNoExamsAtAll ? Icons.description_outlined : Icons.search_off,
              color: AppColors.primaryContainer,
              size: 34,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasNoExamsAtAll
                ? 'Danh sách đề thi đang trống'
                : 'Không tìm thấy đề thi phù hợp',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            hasNoExamsAtAll
                ? 'Toàn bộ nội dung đề thi đã được làm sạch. Bạn có thể nhập bộ đề thi mới tự động từ file Word (.docx) theo chuẩn ETS.'
                : 'Hãy thử từ khóa khác hoặc bỏ chọn bộ lọc hiện tại.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 13,
                  height: 1.5,
                ),
          ),
          const SizedBox(height: 20),
          if (hasNoExamsAtAll)
            ElevatedButton.icon(
              onPressed: _openImportScreen,
              icon: const Icon(Icons.file_upload, size: 20),
              label: const Text('Import đề thi từ file Word (.docx)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryContainer,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
            )
          else
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() => _selectedFilter = 'all');
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 42),
              ),
              child: const Text('Đặt lại bộ lọc'),
            ),
        ],
      ),
    );
  }
}
