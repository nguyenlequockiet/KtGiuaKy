class PickedDocxFile {
  final String name;
  final int size;
  final List<int>? bytes;

  const PickedDocxFile({
    required this.name,
    required this.size,
    this.bytes,
  });

  String get formattedSize {
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
