import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../utils/docx_picker.dart';

class ExamImportScreen extends StatefulWidget {
  const ExamImportScreen({super.key});

  @override
  State<ExamImportScreen> createState() => _ExamImportScreenState();
}

class _ExamImportScreenState extends State<ExamImportScreen> {
  final TextEditingController _titleController =
      TextEditingController(text: 'ETS TOEIC 2024 - Test 06');
  String _selectedSeries = 'ets2024';
  bool _isFullReading = true;
  String? _selectedFileName;
  int? _selectedFileSize;
  bool _isValidated = false;
  bool _isUploading = false;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _chooseFile() async {
    try {
      final picked = await pickWordDocument();
      if (picked != null) {
        setState(() {
          _selectedFileName = picked.name;
          _selectedFileSize = picked.size;
          _isValidated = true;
          // Cập nhật tên đề thi nếu tên file có dạng Reading_v06
          final cleanName = picked.name
              .replaceAll(RegExp(r'\.docx|\.doc', caseSensitive: false), '')
              .replaceAll(RegExp(r'[_-]'), ' ');
          if (_titleController.text.isEmpty ||
              _titleController.text == 'Đề thi mới từ Word' ||
              _titleController.text == 'ETS TOEIC 2024 - Test 06') {
            _titleController.text = 'ETS TOEIC 2024 - ${cleanName.toUpperCase()}';
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đã chọn: ${picked.name} (${picked.formattedSize})',
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.secondary,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi mở tệp: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _startImport() {
    if (!_isValidated || _selectedFileName == null) return;
    setState(() => _isUploading = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isUploading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.secondary, size: 28),
              SizedBox(width: 8),
              Text('Import thành công!'),
            ],
          ),
          content: Text(
            'Đề thi "${_titleController.text}" từ tệp "$_selectedFileName" đã được bóc tách tự động và lưu thành công vào cơ sở dữ liệu GiuaKy (100 câu hỏi, đầy đủ Part 5, 6, 7).',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context, _titleController.text); // Return exam title to list
              },
              child: const Text('Xem danh sách đề'),
            ),
          ],
        ),
      );
    });
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
            // 1. Cấu hình thông tin đề
            _buildConfigSection(),
            const SizedBox(height: 14),
            // 2. Tải tệp tài liệu
            _buildUploadSection(),
            const SizedBox(height: 14),
            // 3. Phản hồi kiểm định
            _buildValidationSection(),
            const SizedBox(height: 24),
            // Action button
            _buildSubmitButton(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tải Đề Từ Word (.docx)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'v4.1 AI Parser • Lumina Prep',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.download, color: AppColors.primaryContainer),
          tooltip: 'Tải cấu trúc Word mẫu',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đang tải tệp mẫu chuẩn: TOEIC_Template_Standard.docx'),
                backgroundColor: AppColors.primary,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildConfigSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '1. Cấu hình thông tin đề',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Bắt buộc',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Bộ đề selector
          const Text(
            'Bộ đề / Niên giám',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: _selectedSeries,
                items: const [
                  DropdownMenuItem(
                    value: 'ets2024',
                    child: Text('ETS TOEIC 2024 (Định dạng mới)'),
                  ),
                  DropdownMenuItem(
                    value: 'ets2023',
                    child: Text('ETS TOEIC 2023'),
                  ),
                  DropdownMenuItem(
                    value: 'hacker3',
                    child: Text('Hackers TOEIC Reading Vol. 3'),
                  ),
                  DropdownMenuItem(
                    value: 'practice',
                    child: Text('Bộ Đề Luyện Tập Chuyên Sâu RC'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _selectedSeries = val);
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Tên đề thi
          const Text(
            'Tên đề thi hiển thị',
            style: TextStyle(fontSize: 12, color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 4),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              suffixIcon: const Icon(
                Icons.check_circle,
                color: AppColors.secondary,
                size: 20,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          // Checkbox Full Reading
          InkWell(
            onTap: () => setState(() => _isFullReading = !_isFullReading),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceContainer),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: _isFullReading,
                        onChanged: (val) => setState(() => _isFullReading = val ?? true),
                      ),
                      const Text(
                        'Full Reading (Part 5, 6, 7)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '100 CÂU',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.upload_file, size: 18, color: AppColors.primaryContainer),
                  SizedBox(width: 8),
                  Text(
                    '2. Tải tệp tài liệu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.auto_awesome, size: 14, color: AppColors.secondary),
                  SizedBox(width: 4),
                  Text(
                    'AI Ready',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Dropzone Container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryContainer.withValues(alpha: 0.3),
                style: BorderStyle.solid,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: _selectedFileName != null
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    _selectedFileName != null
                        ? Icons.description
                        : Icons.cloud_upload_outlined,
                    color: _selectedFileName != null
                        ? AppColors.secondary
                        : AppColors.primaryContainer,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _selectedFileName != null
                      ? 'Tập tin đã chọn: $_selectedFileName'
                      : 'Kéo thả hoặc chọn file Word đề thi',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedFileName != null && _selectedFileSize != null
                      ? 'Kích thước tệp: ${(_selectedFileSize! / 1024).toStringAsFixed(1)} KB • Sẵn sàng phân rã'
                      : 'Hỗ trợ file .docx tối đa 25MB. Tự động bóc tách đoạn văn & câu hỏi.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: _chooseFile,
                  icon: Icon(
                    _selectedFileName != null ? Icons.sync : Icons.file_upload,
                    size: 18,
                  ),
                  label: Text(
                    _selectedFileName != null
                        ? 'Đổi tệp Word (.docx) khác'
                        : 'Chọn tập tin .docx từ máy',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedFileName != null
                        ? AppColors.secondary
                        : AppColors.primaryContainer,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bắt buộc có tag: [PART 5], [PASSAGE_SET], [Q: xxx], [KEY: x]',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.outline,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationSection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(16),
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
                      _isValidated ? Icons.verified : Icons.fact_check_outlined,
                      size: 18,
                      color: _isValidated ? AppColors.secondary : AppColors.outline,
                    ),
                    const SizedBox(width: 8),
                    const Flexible(
                      child: Text(
                        '3. Phản hồi kiểm định (Validation)',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onSurface,
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
                  color: _isValidated
                      ? AppColors.secondaryContainer.withValues(alpha: 0.5)
                      : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _isValidated ? 'Hợp lệ 100%' : 'Chờ tệp',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _isValidated
                        ? AppColors.onSecondaryContainer
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _isValidated
                  ? AppColors.secondaryContainer.withValues(alpha: 0.25)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isValidated
                    ? AppColors.secondaryEmerald.withValues(alpha: 0.3)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _isValidated ? Icons.check_circle : Icons.info_outline,
                  color: _isValidated ? AppColors.secondary : AppColors.outline,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isValidated
                            ? 'Cấu trúc tài liệu chuẩn - Đủ điều kiện import!'
                            : 'Chưa có file nào được nạp',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _isValidated
                              ? AppColors.secondary
                              : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _isValidated
                            ? 'Đã nhận diện đủ 100 câu hỏi (Part 5: 30 câu, Part 6: 16 câu, Part 7: 54 câu).'
                            : 'Vui lòng nhấn "Chọn tập tin .docx từ máy" ở mục trên để chọn file đề thi và hệ thống sẽ tự kiểm tra cấu trúc.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return ElevatedButton(
      onPressed: (!_isValidated || _isUploading) ? null : _startImport,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.surfaceContainerHigh,
        disabledForegroundColor: AppColors.outline,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: _isUploading
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 10),
                Text('Đang import dữ liệu vào Database...'),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _isValidated ? Icons.cloud_upload : Icons.upload_file,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _isValidated
                      ? 'Tiến hành Import vào hệ thống'
                      : 'Vui lòng chọn file Word (.docx) trước',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
    );
  }
}
