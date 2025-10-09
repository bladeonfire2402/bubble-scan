import "package:enhance/interface/index.dart";
import "package:enhance/methods/cv_method.dart";
import "package:flutter/widgets.dart";
import "package:opencv_dart/opencv.dart" as cv;
import "package:opencv_dart/opencv_dart.dart";

const Map<int, int> answerKey = {0: 1, 1: 4, 2: 0, 3: 2, 4: 0};


class OMRScannerVer2 {
  // ignore: constant_identifier_names
  static const int N_CHOICES = 5;

  static OMRResult cameraScaning(Mat src) {
    final cv.Mat scanned = _extractPaperAndWarp(src);

    final cv.Mat thresh = _toBinary(scanned);

    //tiếp tục tìm đường viền
    final (cnts, _) = cv.findContours(
      thresh,
      cv.RETR_EXTERNAL,
      cv.CHAIN_APPROX_SIMPLE,
    );

    //tìm kiếm những lựa chọn
    final bubbles = _filterBubbles(cnts);
    debugPrint(bubbles.length.toString());
    if (bubbles.isEmpty) throw Exception("Không tìm thấy bubble nào.");

    //lọc ra các câu hỏi cùng hàng, một mảng 2 chiều
    List<List<int>> rows = _groupToRows(bubbles, N_CHOICES);
    //Sắp xếp lại thứ tự câu hỏi trong 1 hàng theo thứ tự từ trái sang phải
    rows = _reOrdersRow(rows, cnts);

    //đoạn này chỉ để vẽ ảnh thôi
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

    //Danh sách các câu trả lời
    final picks = <int?>[];
    //Số câu trả lời đúng
    int correct = 0;

    //lặp qua các câu hỏi, tìm câu trả lời
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

    final (_, raw) = cv.imencode(".png", src);
    final (_, encode) = cv.imencode(".png", scanned);
    final (_, black) = cv.imencode(".png", thresh);

    src.dispose();
    scanned.dispose();
    thresh.dispose();

    return OMRResult(
      total: total,
      correct: correct,
      wrong: wrong,
      picked: picks,
      imageBytes: encode,
      rawBytes: raw,
      threshBytes: black,
    );
  }

  static OMRResult scanFromPath(String path) {
    //Trích xuất hình ảnh ra loại Mat
    final cv.Mat src = cv.imread(path);

    final cv.Mat scanned = _extractPaperAndWarp(src);
    //Tách hết màu, chỉ để lại đen trắng
    final cv.Mat thresh = _toBinary(scanned);

    //tiếp tục tìm đường viền
    final (cnts, _) = cv.findContours(
      thresh,
      cv.RETR_EXTERNAL,
      cv.CHAIN_APPROX_SIMPLE,
    );

    //tìm kiếm những lựa chọn
    final bubbles = _filterBubbles(cnts);
    debugPrint(bubbles.length.toString());
    if (bubbles.isEmpty) throw Exception("Không tìm thấy bubble nào.");

    //lọc ra các câu hỏi cùng hàng, một mảng 2 chiều
    List<List<int>> rows = _groupToRows(bubbles, N_CHOICES);
    //Sắp xếp lại thứ tự câu hỏi trong 1 hàng theo thứ tự từ trái sang phải
    rows = _reOrdersRow(rows, cnts);

    //đoạn này chỉ để vẽ ảnh thôi
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

    //Danh sách các câu trả lời
    final picks = <int?>[];
    //Số câu trả lời đúng
    int correct = 0;

    //lặp qua các câu hỏi, tìm câu trả lời
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

    final (_, raw) = cv.imencode(".png", src);
    final (_, encode) = cv.imencode(".png", scanned);
    final (_, black) = cv.imencode(".png", thresh);

    src.dispose();
    scanned.dispose();
    thresh.dispose();

    return OMRResult(
      total: total,
      correct: correct,
      wrong: wrong,
      picked: picks,
      imageBytes: encode,
      rawBytes: raw,
      threshBytes: black,
    );
  }

  /// --- Tìm tờ giấy mặt phẳng ---
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
    final (cnts, _) = CvMethod.findContours(src: edged);

    //Tạo list idx sẽ chứa các vecVecPoint sau khi sort
    final idx = List.generate(cnts.length, (i) => i);
    //Sort theo diện tich
    idx.sort(
      (a, b) => cv.contourArea(cnts[b]).compareTo(cv.contourArea(cnts[a])),
    );

    //Tìm vị trí contours lớn nhất, mảnh giấy, trang giấy làm bài
    List<cv.Point>? paper;
    print(paper);

    //Dựa vào chu vi để biết được
    for (final i in idx) {
      final c = cnts[i];
      final peri = cv.arcLength(c, true); //tính chu vi
      //vì contours lớn nhất có rất nhiều điểm, nên gọi đến approx để làm giảm nhiễu
      final approx = cv.approxPolyDP(c, 0.02 * peri, true);
      //nếu mà approx ra được countour có 4 cạnh gán tờ giấy bằng approx
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

    //Xếp lại vị trí 4 đỉnh theo thứ thự
    //[top-left, top-right, bottom-right, bottom-left]
    final ordered = cv.VecPoint.fromList(_orderPoints(paper));

    //vì tờ giấy xong khi được lấy ra sẽ có thể bị nghiêng góc,
    //nên phải xử lý để nó trở thành 1 mặt phẳng hoàn toàn
    final dstSize = (700, 800);
    final dstPts = cv.VecPoint.fromList([
      cv.Point(0, 0),
      cv.Point(dstSize.$1 - 1, 0),
      cv.Point(dstSize.$1 - 1, dstSize.$2 - 1),
      cv.Point(0, dstSize.$2 - 1),
    ]);

    //Tính ma trận biến đổi phối cảnh (perspective matrix) giữa 2 tập điểm (4 góc thật và 4 góc chuẩn).
    final M = cv.getPerspectiveTransform(ordered, dstPts);
    //Dùng ma trận đó để biến đổi toàn bộ ảnh – kéo, xoay, làm thẳng ảnh.
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
  static List<int> _filterBubbles(cv.VecVecPoint cnts) {
    final result = <int>[];
    //Duyệt qua từng đường viền
    for (var i = 0; i < cnts.length; i++) {
      final c = cnts[i];
      final area = cv.contourArea(c); //tính diện tích
      // Nếu diện tích quá nhỏ (< 200) → bỏ, vì có thể là nhiễu hoặc chữ in.
      // Nếu diện tích quá lớn (> 5000) → bỏ, vì đó có thể là khung giấy, bảng câu hỏi, logo.
      if (area < 200 || area > 5000) continue;
      //Tạo một hình chữ nhật bao quanh contours đó
      final rect = cv.boundingRect(c);
      //tính tỉ lệ ratio
      final ratio = rect.width / rect.height;
      //Nếu tỉ ratio = 1 chắc chắc là 1 hình vuông
      // => Cái đường viền của trong đó sẽ là một hình tròn
      // nếu mà bé < 0.8 hoặc  >1.2 hình rect sẽ có hình một hình chữ nhật, hẹp ngang
      // => đó là một hình ellispe không gần giống với hình tròn
      if (ratio > 0.8 && ratio < 1.2) {
        //từ đó lọc ra những vị trí của contours có câu hỏi
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
    //kernel: là một ma trận nhỏ (3x3), có dạng hình elip, dùng để làm erode (co lại) các vùng tô, giúp bỏ đi các viền in sẵn hoặc nhiễu.
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
    final tl = pts.first; // top left
    final br = pts.last; // bottom right
    final remain = pts.where((p) => p != tl && p != br).toList();
    remain.sort((a, b) => (a.y - a.x).compareTo(b.y - b.x));
    final tr = remain.first; // top right
    final bl = remain.last; // bottom left
    // [top left, top right, bottom right, bottom left]
    return [tl, tr, br, bl];
  }
}
