import "package:enhance/core/enum/index.dart";
import "dart:typed_data";

class OMRResult {
  final int total;
  final int wrong;
  final int correct;
  final List<int?> picked;
  final ProccessType process;
  final Uint8List? rawBytes;
  final Uint8List? imageBytes;
  final Uint8List? threshBytes;

  OMRResult({
    this.rawBytes,
    this.total = 0,
    this.wrong = 0,
    this.imageBytes,
    this.threshBytes,
    this.correct = 0,
    required this.picked,
    this.process = ProccessType.unloaded,
  });
}
