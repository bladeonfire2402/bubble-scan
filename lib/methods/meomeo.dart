import 'dart:typed_data';
import 'package:enhance/methods/cv_method.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:opencv_dart/opencv_dart.dart';

const Map<int, int> answerKey = {0: 1, 1: 4, 2: 0, 3: 2, 4: 0};

class OMRResult {
  final int total;
  final int correct;
  final int wrong;
  final List<int?> picked;
  final Uint8List? imageBytes;

  OMRResult({
    required this.total,
    required this.correct,
    required this.wrong,
    required this.picked,
    required this.imageBytes,
  });
}

class OMRScannerVer2 {
  static const int N_CHOICES = 5;

  static OMRResult scanFromPath(String path) {
    //Trích xuất hình ảnh ra loại Mat
    final cv.Mat src = cv.imread(path);
    //Xử lý ảnh
    final cv.Mat scanned = _extractPaperAndWarp(src);
    final cv.Mat thresh = _toBinary(scanned);

    final (cnts, _) = cv.findContours(
      thresh,
      cv.RETR_EXTERNAL,
      cv.CHAIN_APPROX_SIMPLE,
    );

    final bubbles = _filterBubbles(cnts);
    print(bubbles.length);
    if (bubbles.isEmpty) throw Exception("Không tìm thấy bubble nào.");

    List<List<int>> rows = _groupToRows(bubbles, N_CHOICES);
    rows = _reOrdersRow(rows, cnts);

    for (int r = 0; r < rows.length; r++) {
      for (int c in rows[r]) {
        final rect = cv.boundingRect(cnts[c]);
        //vẽ đường chữ nhật
        cv.rectangle(scanned, rect, cv.Scalar.all(128)); // vẽ khung bubble
        //Đặt hình lên
        cv.putText(
          scanned,
          "R$r $c",
          cv.Point(rect.x, rect.y - 5),
          cv.FONT_HERSHEY_SIMPLEX,
          0.4,
          cv.Scalar.all(0),
        );
      }
    }
    cv.imwrite("debug_rows.png", src);

    final picks = <int?>[];
    int correct = 0;
    for (var q = 0; q < rows.length; q++) {
      final choice = _pickAnswer(thresh, cnts, rows[q]);
      picks.add(choice);
    }
    final mem = picks.reversed.toList();

    for (var c = 0; c < mem.length; c++) {
      int? answer = mem[c];
      if (answer != null && answer == answerKey[c]) {
        correct++;
      }
    }

    final total = rows.length;
    final wrong = total - correct;

    final (_, encode) = cv.imencode('.png', scanned);

    src.dispose();
    scanned.dispose();
    thresh.dispose();

    return OMRResult(
      total: total,
      correct: correct,
      wrong: wrong,
      picked: picks,
      imageBytes: encode,
    );
  }

  /// --- Tìm tờ giấy và warp ---
  static cv.Mat _extractPaperAndWarp(cv.Mat src) {
    //resize lại ảnh, để hạn chế các thành phần dư thừa
    final ratio = 800 / src.rows;
    final resized = CvMethod.resizeImage(
      src: src,
      dsize: ((src.cols * ratio).round(), 800),
    );

    //Chuyển ảnh qua màu xám
    final gray = CvMethod.convertGray(src: resized);

    //Làm mờ trơn ảnh qua bộ lọc gaussianBlur
    final blurred = CvMethod.blurring(src: gray, sigmaX: 0, kSize: (5, 5));

    //xài thuật toán canny để quét ra an
    final edged = CvMethod.egdering(
      src: blurred,
      lowThresh: 50,
      highThresh: 150,
    );
    
    //Lấy danh sách các đường viền
    final (cnts, _) = CvMethod.findContours(
      src: edged,
      mode:  cv.RETR_EXTERNAL,
      method:  cv.CHAIN_APPROX_SIMPLE,
    );

    //Tạo list idx sẽ chứa các vecVecPoint sau khi sort  
    final idx = List.generate(cnts.length, (i) => i);
    //Sort theo diện tich
    idx.sort(
      (a, b) => cv.contourArea(cnts[b]).compareTo(cv.contourArea(cnts[a])),
    );

    List<cv.Point>? paper;
    for (final i in idx) {
      final c = cnts[i];
      final peri = cv.arcLength(c, true);
      final approx = cv.approxPolyDP(c, 0.02 * peri, true);
      if (approx.length == 4) {
        paper = [for (var j = 0; j < approx.length; j++) approx[j]];
        break;
      }
    }

    if (paper == null) {
      gray.dispose();
      blurred.dispose();
      edged.dispose();
      return resized;
    }

    final ordered = cv.VecPoint.fromList(_orderPoints(paper));
    final dstSize = (700, 800);
    final dstPts = cv.VecPoint.fromList([
      cv.Point(0, 0),
      cv.Point(dstSize.$1 - 1, 0),
      cv.Point(dstSize.$1 - 1, dstSize.$2 - 1),
      cv.Point(0, dstSize.$2 - 1),
    ]);

    final M = cv.getPerspectiveTransform(ordered, dstPts);
    final warped = cv.warpPerspective(resized, M, dstSize);

    gray.dispose();
    blurred.dispose();
    edged.dispose();

    return warped;
  }

  /// --- Nhị phân hoá ---
  static cv.Mat _toBinary(cv.Mat src) {
    final gray = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
    final blur = cv.gaussianBlur(gray, (5, 5), 0);
    final (_, thresh) = cv.threshold(
      blur,
      0,
      255,
      cv.THRESH_BINARY_INV + cv.THRESH_OTSU,
    );
    gray.dispose();
    blur.dispose();
    return thresh;
  }

  /// --- Lọc contour bubble ---
  static List<int> _filterBubbles(cv.Contours cnts) {
    final result = <int>[];
    for (var i = 0; i < cnts.length; i++) {
      final c = cnts[i];
      final area = cv.contourArea(c);
      if (area < 200 || area > 5000) continue;
      final rect = cv.boundingRect(c);

      final ratio = rect.width / rect.height;

      if (ratio > 0.8 && ratio < 1.2) {
        print("Tạo độ y: ${rect.y} x: ${rect.x} và vị trí ${i}");
        result.add(i);
      }
    }
    return result;
  }

  static List<List<int>> _reOrdersRow(List<List<int>> rows, VecVecPoint cnts) {
    List<List<int>> newOrders = [];

    for (var r = 0; r < rows.length; r++) {
      // Lấy danh sách index trong hàng
      List<int> temp = List.from(rows[r]);

      // Sắp xếp theo vị trí x (trái -> phải)
      temp.sort((a, b) {
        final rectA = cv.boundingRect(cnts[a]);
        final rectB = cv.boundingRect(cnts[b]);
        return rectA.x.compareTo(rectB.x);
      });

      // Thêm hàng đã sắp xếp vào danh sách mới
      newOrders.add(temp);
    }

    return newOrders;
  }

  /// --- Gom thành hàng ---
  static List<List<int>> _groupToRows(List<int> bubbles, int nChoices) {
    final rows = <List<int>>[];
    var current = <int>[];

    for (final b in bubbles) {
      current.add(b);
      if (current.length == nChoices) {
        rows.add(List.from(current));
        current.clear();
      }
    }

    return rows;
  }

  /// --- Chọn đáp án ---
  static int? _pickAnswer(
    cv.Mat binInv,
    cv.Contours cnts,
    List<int> contourIdxs,
  ) {
    int winner = -1;
    double bestRatio = -1.0;
    final ratios = <double>[];

    // kernel nhỏ để bỏ viền in sẵn
    final kernel = cv.getStructuringElement(cv.MORPH_ELLIPSE, (3, 3));

    for (var i = 0; i < contourIdxs.length; i++) {
      final mask = cv.Mat.zeros(binInv.rows, binInv.cols, cv.MatType.CV_8UC1);
      cv.drawContours(
        mask,
        cnts,
        contourIdxs[i],
        cv.Scalar.all(255),
        thickness: -1,
      );

      // thu nhỏ mask để tránh lấy cả viền tròn in sẵn
      final inner = cv.erode(mask, kernel, iterations: 2);

      // đếm pixel trắng trong vùng ô tròn
      final masked = cv.bitwiseAND(binInv, inner);
      final white = cv.countNonZero(masked);
      final area = cv.countNonZero(inner); // diện tích vùng tròn sau erode
      final ratio = (area == 0) ? 0.0 : white / area;
      ratios.add(ratio);

      mask.dispose();
      inner.dispose();
      masked.dispose();

      if (ratio > bestRatio) {
        bestRatio = ratio;
        winner = i;
      }
    }

    kernel.dispose();

    // không đủ tô đậm → bỏ qua
    if (bestRatio < 0.15) return null;

    // tránh tô hai ô (hai ratio gần bằng nhau)
    final sorted = [...ratios]..sort();
    final second = (sorted.length >= 2) ? sorted[sorted.length - 2] : 0.0;
    if (second > 0.9 * bestRatio) return null;

    return winner;
  }

  /// --- Sắp xếp 4 đỉnh ---
  static List<cv.Point> _orderPoints(List<cv.Point> pts) {
    pts.sort((a, b) => (a.x + a.y).compareTo(b.x + b.y));
    final tl = pts.first;
    final br = pts.last;
    final remain = pts.where((p) => p != tl && p != br).toList();
    remain.sort((a, b) => (a.y - a.x).compareTo(b.y - b.x));
    final tr = remain.first;
    final bl = remain.last;
    return [tl, tr, br, bl];
  }
}
