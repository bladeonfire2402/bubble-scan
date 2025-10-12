import "package:enhance/core/enum/index.dart";
import "package:flutter/widgets.dart";
import "dart:typed_data";

class OMRResult {
  final int total;
  final int wrong;
  final int correct;
  final List<int?> picked;
  final Uint8List? rawBytes;
  final ProccessType process;
  final Uint8List? edgeBytes;
  final Uint8List? imageBytes;
  final Uint8List? threshBytes;

  OMRResult({
    this.rawBytes,
    this.total = 0,
    this.wrong = 0,
    this.imageBytes,
    this.edgeBytes,
    this.threshBytes,
    this.correct = 0,
    required this.picked,
    this.process = ProccessType.unloaded,
  });
}

// Sửa onChange thành non-nullable cho rõ ràng
class MenuItem {
  final IconData icon;
  final Widget widget;

  const MenuItem({required this.icon, required this.widget});
}
