// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'docx_file_model.dart';

Future<PickedDocxFile?> pickWordDocumentImpl() async {
  final completer = Completer<PickedDocxFile?>();

  final uploadInput = html.FileUploadInputElement()
    ..accept = '.docx,.doc'
    ..multiple = false;

  uploadInput.style.display = 'none';
  html.document.body?.children.add(uploadInput);

  uploadInput.onChange.listen((event) async {
    final files = uploadInput.files;
    if (files != null && files.isNotEmpty) {
      final file = files[0];
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoadEnd.first;

      List<int>? bytes;
      final result = reader.result;
      if (result is List<int>) {
        bytes = result;
      }

      uploadInput.remove();
      if (!completer.isCompleted) {
        completer.complete(
          PickedDocxFile(
            name: file.name,
            size: file.size,
            bytes: bytes,
          ),
        );
      }
    } else {
      uploadInput.remove();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    }
  });

  uploadInput.addEventListener('cancel', (event) {
    uploadInput.remove();
    if (!completer.isCompleted) {
      completer.complete(null);
    }
  });

  uploadInput.click();

  return completer.future;
}
