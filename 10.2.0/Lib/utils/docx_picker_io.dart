import 'package:file_picker/file_picker.dart';
import 'docx_file_model.dart';

Future<PickedDocxFile?> pickWordDocumentImpl() async {
  try {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['docx', 'doc'],
    );

    if (files.isNotEmpty) {
      final file = files.first;
      final size = file.lengthSync() ?? (await file.length()) ?? 0;
      final bytes = await file.readAsBytes();
      return PickedDocxFile(
        name: file.name,
        size: size,
        bytes: bytes,
      );
    }
  } catch (_) {
    // Return null if user cancelled or error
  }
  return null;
}
