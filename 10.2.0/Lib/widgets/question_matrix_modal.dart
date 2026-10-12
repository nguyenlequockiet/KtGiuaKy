import 'package:flutter/material.dart';
import '../models/exam_models.dart';
import '../theme/app_colors.dart';

class QuestionMatrixModal extends StatelessWidget {
  final List<QuestionItem> questions;
  final int currentQuestionNumber;
  final ValueChanged<int> onSelectQuestion;

  const QuestionMatrixModal({
    super.key,
    required this.questions,
    required this.currentQuestionNumber,
    required this.onSelectQuestion,
  });

  @override
  Widget build(BuildContext context) {
    final answeredCount = questions.where((q) => q.selectedChoice != null).length;
    final flaggedCount = questions.where((q) => q.isFlagged).length;
    final unansweredCount = questions.length - answeredCount;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Danh sách ${questions.length} câu hỏi',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Chọn số câu để chuyển nhanh',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerLow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem(
                color: AppColors.primaryContainer,
                label: 'Đã làm ($answeredCount)',
              ),
              _buildLegendItem(
                color: AppColors.warning,
                label: 'Đánh dấu ($flaggedCount)',
              ),
              _buildLegendItem(
                color: AppColors.surfaceContainer,
                label: 'Chưa làm ($unansweredCount)',
                textColor: AppColors.onSurfaceVariant,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.surfaceContainer),
          const SizedBox(height: 12),
          // Questions Grid
          Expanded(
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.4,
              ),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                final isCurrent = q.number == currentQuestionNumber;
                final isAnswered = q.selectedChoice != null;
                final isFlagged = q.isFlagged;

                Color bgColor;
                Color textColor;
                Border? border;

                if (isCurrent) {
                  border = Border.all(color: AppColors.primary, width: 2);
                }

                if (isFlagged) {
                  bgColor = AppColors.warningLight;
                  textColor = AppColors.warning;
                } else if (isAnswered) {
                  bgColor = AppColors.primaryContainer;
                  textColor = AppColors.onPrimary;
                } else {
                  bgColor = AppColors.surfaceContainerLow;
                  textColor = AppColors.onSurfaceVariant;
                }

                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    onSelectQuestion(q.number);
                  },
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
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
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Close button
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: const BorderSide(color: AppColors.outlineVariant),
            ),
            child: const Text('Đóng danh sách'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    Color? textColor,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: textColor ?? AppColors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
