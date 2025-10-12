import "package:enhance/methods/cv_method.dart";
import "package:opencv_dart/opencv.dart" as cv;
import "package:enhance/core/enum/index.dart";
import "package:enhance/interface/index.dart";
import "package:opencv_dart/opencv_dart.dart";

class OmrController {
  // ignore: constant_identifier_names
  static const int N_CHOICES = 5;
  static const Map<int, int> answerKey = {0: 1, 1: 4, 2: 0, 3: 2, 4: 0};

  //hàm Chấm Điểm
  static OMRResult handleGrade({String? path, cv.Mat? img}) {
    late cv.Mat mat = path != null ? CvMethod.getMat(path: path) : img!;

    //Xử lý để các phần dư thừa
    final resized = _resizeImage(src: mat);

    //Chuyển ảnh qua màu xám
    final gray = CvMethod.convertGray(src: resized);

    //Làm mờ trơn ảnh qua bộ lọc gaussianBlur
    final blurred = CvMethod.blurring(src: gray);
    //xài thuật toán canny để quét ra các cạnh và biên
    final edged = CvMethod.egdering(src: blurred);

    cv.Mat? scanned;

    //Lấy danh sách các đường viền
    var (cnts, _) = CvMethod.findContours(src: edged);

    //khuôn giấy
    final paper = getPaper(cnts: cnts);

    if (paper == null) {
      scanned = resized;
    } else {
      scanned = _wrappedMatrix(list: paper, resized: resized);
    }

    //lọc tất cả thành đen trắng
    final thresh = _toBinary(scanned);

    //lấy cnts lại lần 2
    (cnts, _) = CvMethod.findContours(src: thresh);

    // Lọc các câu hỏi
    final bubbles = _filterBubbles(cnts);
    if (bubbles.isEmpty) throw Exception("Không tìm thấy câu hỏi nào.");

    //lọc ra các câu hỏi cùng hàng, một mảng 2 chiều
    List<List<int>> rows = _groupToRows(bubbles, N_CHOICES);
    rows = _reOrdersRow(rows, cnts);
    print(rows);

    final (picks, corrects) = _getAnswerAndCorrect(
      cnts: cnts,
      rows: rows,
      src: thresh,
    );

    //Vẽ các điểm lên cho dễ nhìn
    _drawPoints(rows: rows, cnts: cnts, scanned: scanned);

    final (_, raw) = cv.imencode(".png", mat);
    final (_, black) = cv.imencode(".png", thresh);
    final (_, encode) = cv.imencode(".png", scanned);
    final (_, edge) = cv.imencode(".png", edged);

    return OMRResult(
      picked: picks,
      rawBytes: raw,
      edgeBytes: edge,
      correct: corrects,
      total: rows.length,
      imageBytes: encode,
      threshBytes: black,
      wrong: rows.length - corrects,
      process: ProccessType.successfull,
    );
  }

  //Hàm cắt hình
  static cv.Mat _resizeImage({required cv.Mat src}) {
    final ratio = 800 / src.rows;
    return CvMethod.resizeImage(
      src: src,
      dsize: ((src.cols * ratio).round(), 800),
    );
  }

  static (List<int?>, int) _getAnswerAndCorrect({
    required List<List<int>> rows,
    required cv.Mat src,
    required cv.VecVecPoint cnts,
  }) {
    //Danh sách các câu trả lời
    final picks = <int?>[];
    //Số câu trả lời đúng
    int correct = 0;
    for (var q = rows.length - 1; q >= 0; q--) {
      final choice = _pickAnswer(src, cnts, rows[q]);
      picks.add(choice);

      // Tính đúng ngay trong khi lặp, theo thứ tự đảo ngược
      final answerIndex = rows.length - 1 - q;
      if (choice != null && choice == answerKey[answerIndex]) {
        correct++;
      }
    }

    print(picks);

    return (picks, correct);
  }

  //Hàm lấy các điểm 4 cạnh khuôn hình chữ nhật của tờ giấy để sau đó có thể sử dụng
  // làm phẳng tờ giấy góc vuông không để tờ giấy bị nghiêng, tăng được độ chính xác
  static List<cv.Point>? getPaper({required cv.VecVecPoint cnts}) {
    //Tạo list idx sẽ chứa các vecVecPoint sau khi sort
    final idx = List.generate(cnts.length, (i) => i);

    //Sort theo diện tich
    idx.sort(
      (a, b) => cv.contourArea(cnts[b]).compareTo(cv.contourArea(cnts[a])),
    );

    List<cv.Point>? paper;
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
    return paper;
  }

  //hàm tạo matrix mới từ vecpoint
  static cv.Mat _wrappedMatrix({
    required List<Point> list,
    required cv.Mat resized,
  }) {
    final ordered = cv.VecPoint.fromList(_orderPoints(list));

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

  //Hàm xếp lại 4 cạnh hình chữ nhật
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

  static List<int> filterBubbless(cv.VecVecPoint cnts) {
    final result = <int>[];
    for (var i = 0; i < cnts.length; i++) {
      final c = cnts[i];
      final area = cv.contourArea(c);
      if (area < 200 || area > 5000) continue;
      final rect = cv.boundingRect(c);
      final ratio = rect.width / rect.height;
      if (ratio > 0.8 && ratio < 1.2) {
        result.add(i);
      }
    }
    return result;
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

  static void _drawPoints({
    required List<List<int>> rows,
    required cv.VecVecPoint cnts,
    required cv.Mat scanned,
  }) {
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
  }
}
