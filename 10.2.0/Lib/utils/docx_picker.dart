import 'docx_file_model.dart';
import 'docx_picker_stub.dart'
    if (dart.library.html) 'docx_picker_web.dart'
    if (dart.library.io) 'docx_picker_io.dart';

export 'docx_file_model.dart';

Future<PickedDocxFile?> pickWordDocument() => pickWordDocumentImpl();
