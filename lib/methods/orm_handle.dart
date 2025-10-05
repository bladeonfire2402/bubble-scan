import 'package:opencv_dart/opencv.dart' as cv;
import 'package:opencv_dart/opencv_dart.dart';

class OMRScanner {
  static const int N_CHOICES = 5;

  static cv.Mat toBinary(cv.Mat src) {
    final gray = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
    final cv.Mat blur = cv.gaussianBlur(
      gray,
      (5, 5), // kernel size (width, height)
      0, // sigmaX
    );
    final (a, thresh) = cv.threshold(
      blur,
      0,
      255,
      cv.THRESH_BINARY_INV + cv.THRESH_OTSU,
    );
    gray.dispose();
    blur.dispose();
    return thresh;
  }

  static cv.Mat extractPaperAndWarp({required cv.Mat image}) {
    //lấy được cái tỉ lệ để cắt ảnh
    final double ratio = 800 / image.rows;
    //cắt ảnh để dễ xử lý
    final cv.Mat resizedImage = cv.resize(
      image,
      ((image.cols * ratio).round(), 800), //
      interpolation: cv.INTER_AREA,
    );
    //Chuyển nó sang màu xám
    final cv.Mat gray = cv.cvtColor(resizedImage, cv.COLOR_BGR2GRAY);
    //Làm nhiễu ảnh để
    final cv.Mat blurred = cv.gaussianBlur(
      gray,
      (5, 5), // kernel size (width, height)
      0, // sigmaX
    );
    //Lấy ra mấy cái cạnh, vật thể trong hình ảnh
    final cv.Mat edged = cv.canny(blurred, 50, 50);

    //tìm contours
    final (VecVecPoint cnts, _hier) = cv.findContours(
      edged,
      cv.RETR_EXTERNAL,
      cv.CHAIN_APPROX_SIMPLE,
    );

    final List<int> idx = List.generate(cnts.length, (i) => i);

    idx.sort(
      (a, b) => cv.contourArea(cnts[b]).compareTo(cv.contourArea(cnts[a])),
    );

    List<cv.Point>? paper;
    for (final i in idx) {
      final cv.VecPoint c = cnts[i];
      final peri = cv.arcLength(c, true);
      final approx = cv.approxPolyDP(c, 0.02 * peri, true);

      final approxLen = approx.length;
      if (approxLen == 4) {
        // Lấy 4 đỉnh
        paper = [for (var j = 0; j < approx.length; j++) approx[j]];
        break;
      }
    }

    if (paper == null) {
      // nếu không tìm được 4 đỉnh, fallback: dùng ảnh resized luôn
      gray.dispose();
      blurred.dispose();
      edged.dispose();
      return resizedImage;
    }

    final cv.VecPoint ordered = cv.VecPoint.fromList(_orderPoints(paper));
    final dstSize = (700, 800);
    final VecPoint dstPts = cv.VecPoint.fromList([
      cv.Point(0, 0),
      cv.Point(dstSize.$1 - 1, 0),
      cv.Point(dstSize.$1 - 1, dstSize.$2 - 1),
      cv.Point(0, dstSize.$2 - 1),
    ]);

    final M = cv.getPerspectiveTransform(ordered, dstPts);
    final warped = cv.warpPerspective(resizedImage, M, dstSize);

    return M;

    gray.dispose();
    blurred.dispose();
    edged.dispose();
    return edged;
  }

  static List<cv.Point> _orderPoints(List<cv.Point> pts) {
    pts.sort(
      (a, b) => (a.x + a.y).compareTo(b.x + b.y),
    ); // tl (min sum), br (max sum)
    final tl = pts.first;
    final br = pts.last;
    final remain = pts.where((p) => p != tl && p != br).toList();
    remain.sort(
      (a, b) => (a.y - a.x).compareTo(b.y - b.x),
    ); // tr(min diff), bl(max diff)
    final tr = remain.first;
    final bl = remain.last;
    return [tl, tr, br, bl];
  }

  static List<int> filterBubbles(cv.Contours cnts) {
    final result = <int>[];
    for (var i = 0; i < cnts.length; i++) {
      final c = cnts[i];
      final area = cv.contourArea(c);
      if (area < 200 || area > 5000) continue;
      final rect = cv.boundingRect(c);
      final ratio = rect.width / rect.height;
      if (ratio > 0.8 && ratio < 1.2) result.add(i);
    }
    return result;
  }
}
