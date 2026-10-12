import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../data/exam_data_repository.dart';
import '../models/exam_models.dart';
import '../theme/app_colors.dart';
import 'exam_review_screen.dart';

class ExamResultScreen extends StatefulWidget {
  final ExamResultData? resultData;
  final List<QuestionItem>? questions;
  final ExamItem? exam;
  final Map<String, ReadingPassage>? passages;

  const ExamResultScreen({
    super.key,
    this.resultData,
    this.questions,
    this.exam,
    this.passages,
  });

  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}

class _ExamResultScreenState extends State<ExamResultScreen>
    with SingleTickerProviderStateMixin {
  late final ExamResultData _data;
  late final AnimationController _animController;
  late final Animation<double> _gaugeAnimation;

  @override
  void initState() {
    super.initState();
    _data = widget.resultData ??
        const ExamResultData(
          examTitle: 'ETS 2024 - Test 01',
          score: 385,
          maxScore: 495,
          cefrLevel: 'CEFR B2 • Khá tốt',
          totalCorrect: 72,
          totalIncorrect: 18,
          totalSkipped: 10,
          scoreDiff: 35,
          aiFeedback:
              'Bạn làm rất tốt Part 5 & 6, cần cải thiện tốc độ đọc hiểu ở Part 7 các đoạn văn kép để bứt phá mốc 450+.',
          timeTakenString: '62 phút 15 giây',
          timeSavedString: '-12:45',
          partAnalytics: [
            PartAnalytics(
              partName: 'Part 5',
              subtitle: 'Incomplete Sentences',
              correct: 24,
              total: 30,
            ),
            PartAnalytics(
              partName: 'Part 6',
              subtitle: 'Text Completion',
              correct: 13,
              total: 16,
            ),
            PartAnalytics(
              partName: 'Part 7',
              subtitle: 'Reading Comprehension',
              correct: 35,
              total: 54,
            ),
          ],
        );

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _gaugeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _shareResult() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã sao chép liên kết chia sẻ kết quả thi!'),
        backgroundColor: AppColors.secondary,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Session Banner
            _buildSessionBanner(),
            const SizedBox(height: 14),
            // Hero Score Card
            _buildHeroScoreCard(),
            const SizedBox(height: 16),
            // 3 Big Metric Cards Grid
            _buildMetricCardsRow(),
            const SizedBox(height: 16),
            // Part by Part Analytics Section
            _buildPartAnalyticsSection(),
            const SizedBox(height: 16),
            // Timing Summary Card
            _buildTimingSummaryCard(),
            const SizedBox(height: 24),
            // Bottom Action Buttons
            _buildActionButtons(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: AppColors.surface.withValues(alpha: 0.95),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOEIC Reading',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          Text(
            'Kết Quả & Giải Thích',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
      actions: [
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

  Widget _buildSessionBanner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PHIÊN LUYỆN TẬP',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                _data.examTitle,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 16,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.share, size: 20, color: AppColors.primary),
              onPressed: _shareResult,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.surfaceContainerLow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroScoreCard() {
    final targetFraction = _data.score / _data.maxScore;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              // Circular animated gauge
              SizedBox(
                width: 110,
                height: 110,
                child: AnimatedBuilder(
                  animation: _gaugeAnimation,
                  builder: (context, child) {
                    final progress = targetFraction * _gaugeAnimation.value;
                    return CustomPaint(
                      painter: _ScoreGaugePainter(progress: progress),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'ĐIỂM SỐ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              '${(_data.score * _gaugeAnimation.value).round()}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              '/ ${_data.maxScore}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              // Level & Stats
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryFixed,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.workspace_premium,
                            size: 15,
                            color: AppColors.onSecondaryFixed,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _data.cefrLevel,
                            style: const TextStyle(
                              color: AppColors.onSecondaryFixed,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${_data.accuracyPercentage}%',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                fontSize: 22,
                              ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'tổng tỷ lệ chính xác',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.trending_up,
                          size: 16,
                          color: AppColors.secondaryEmerald,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+${_data.scoreDiff} điểm so với bài trước',
                          style: const TextStyle(
                            color: AppColors.secondaryEmerald,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Personalized AI Feedback
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 12,
                        height: 1.4,
                      ),
                      children: [
                        const TextSpan(
                          text: 'Lời khuyên: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        TextSpan(text: _data.aiFeedback),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCardsRow() {
    return Row(
      children: [
        // Đúng
        Expanded(
          child: _buildMetricCard(
            bgColor: AppColors.secondaryContainer,
            textColor: AppColors.onSecondaryContainer,
            icon: Icons.check_circle,
            label: 'Đúng',
            count: _data.totalCorrect,
            percentage: _data.accuracyPercentage,
          ),
        ),
        const SizedBox(width: 8),
        // Sai
        Expanded(
          child: _buildMetricCard(
            bgColor: AppColors.errorContainer,
            textColor: AppColors.onErrorContainer,
            icon: Icons.cancel,
            label: 'Sai',
            count: _data.totalIncorrect,
            percentage: ((_data.totalIncorrect / _data.totalQuestions) * 100).round(),
          ),
        ),
        const SizedBox(width: 8),
        // Bỏ qua
        Expanded(
          child: _buildMetricCard(
            bgColor: AppColors.surfaceContainer,
            textColor: AppColors.onSurfaceVariant,
            icon: Icons.do_not_disturb_on,
            label: 'Bỏ qua',
            count: _data.totalSkipped,
            percentage: ((_data.totalSkipped / _data.totalQuestions) * 100).round(),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required Color bgColor,
    required Color textColor,
    required IconData icon,
    required String label,
    required int count,
    required int percentage,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 22),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          Text(
            '($percentage%)',
            style: TextStyle(
              fontSize: 10,
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartAnalyticsSection() {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bar_chart, color: AppColors.primary, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Phân tích từng phần thi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Chuẩn TOEIC ETS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ..._data.partAnalytics.map((stat) {
            final fraction = stat.correct / stat.total;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
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
                              stat.partName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.onPrimaryFixed,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            stat.subtitle,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${stat.correct}/${stat.total} (${stat.percentage.round()}%)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: stat.percentage >= 80
                              ? AppColors.secondaryEmerald
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 7,
                      backgroundColor: AppColors.surfaceContainer,
                      valueColor: AlwaysStoppedAnimation(
                        stat.percentage >= 80
                            ? AppColors.secondaryEmerald
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimingSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.timer_outlined,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Thời gian làm bài',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    _data.timeTakenString,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryFixed,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bolt,
                      size: 14,
                      color: AppColors.onSecondaryFixed,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      _data.timeSavedString,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSecondaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'nhanh hơn dự kiến',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Primary Review Button
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ExamReviewScreen(
                  examTitle: _data.examTitle,
                  questions: widget.questions ?? ExamDataRepository.instance.questions,
                  passages: widget.passages ?? ExamDataRepository.instance.passages,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryContainer,
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book, size: 20),
              SizedBox(width: 8),
              Text(
                'Xem lời giải chi tiết & Dịch nghĩa',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Retake Button
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            side: const BorderSide(color: AppColors.outlineVariant),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.refresh, size: 20, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                'Làm lại đề thi',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScoreGaugePainter extends CustomPainter {
  final double progress;

  _ScoreGaugePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 16) / 2;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.surfaceContainer
      ..strokeWidth = 9
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(center, radius, trackPaint);

    // Progress Arc
    final progressPaint = Paint()
      ..color = AppColors.primaryContainer
      ..strokeWidth = 9.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScoreGaugePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
