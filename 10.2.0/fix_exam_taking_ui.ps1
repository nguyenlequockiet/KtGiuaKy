$path = 'c:\Users\nguye\Downloads\KiemTraGiuaKy\10.2.0\Lib\screens\exam_taking_screen.dart'
$content = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)

# 1. Update build() to use _buildPassageAndQuestionsView and bottomNavigationBar
$oldBuildRegex = '(?s)                  if \(_currentPart == PartType\.part5\)\r?\n                    _buildPart5View\(\)\r?\n                  else\r?\n                    _buildPart7View\(\),\r?\n                  const SizedBox\(height: 14\),\r?\n                  // Quick Question Number Slider\r?\n                  _buildQuickQuestionSlider\(\),\r?\n                  const SizedBox\(height: 80\),\r?\n                \],\r?\n              \),\r?\n            \),\r?\n          \),\r?\n        \],\r?\n      \),\r?\n      bottomSheet: _buildBottomToolbar\(\),\r?\n    \);'

$newBuildText = @'
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
'@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldBuildRegex, $newBuildText)

# 2. Update _buildStickyHeader to prevent 140px overflow
$oldHeaderRegex = '(?s)  Widget _buildStickyHeader\(int answeredCount, double progressFraction\) \{.*?// Part Segmented Tabs'
$newHeaderText = @'
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
'@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldHeaderRegex, $newHeaderText)

# 3. Replace _buildPart5View and _buildPart7View with dynamic implementation
$oldPartViewsRegex = '(?s)  Widget _buildPart5View\(\) \{.*?  Widget _buildMetaRow'
$newPartViewsText = @'
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
    final passage = (passageId != null && etsTest06Passages.containsKey(passageId))
        ? etsTest06Passages[passageId]!
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

  Widget _buildMetaRow
'@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldPartViewsRegex, $newPartViewsText)

# 4. Replace _buildQuickQuestionSlider to cover all questions in part
$oldSliderRegex = '(?s)  Widget _buildQuickQuestionSlider\(\) \{.*?  Widget _buildBottomToolbar'
$newSliderText = @'
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

  Widget _buildBottomToolbar
'@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldSliderRegex, $newSliderText)

# 5. Replace _buildBottomToolbar to fix 49px and 39px overflows
$oldToolbarRegex = '(?s)  Widget _buildBottomToolbar\(\) \{.*?\}\r?\n\}'
$newToolbarText = @'
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: SafeArea(
        child: Row(
          children: [
            // Matrix button
            OutlinedButton(
              onPressed: _openMatrixSheet,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.grid_view, size: 18),
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chevron_left, size: 18),
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
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Tiếp', style: TextStyle(fontSize: 12)),
                    Icon(Icons.chevron_right, size: 18),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'Nộp bài',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
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
'@

$content = [System.Text.RegularExpressions.Regex]::Replace($content, $oldToolbarRegex, $newToolbarText)

[System.IO.File]::WriteAllText($path, $content, [System.Text.Encoding]::UTF8)
Write-Output "Successfully updated exam_taking_screen.dart layout and dynamic Part 6/7 views!"
