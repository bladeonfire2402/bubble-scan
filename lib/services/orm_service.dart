
// import "package:enhance/core/enum/index.dart";
// import "package:enhance/interface/index.dart";
// import "package:enhance/methods/cv_method.dart";
// import "package:opencv_dart/opencv.dart" as cv;

// class OrmService {
//   static OMRResult scanPickImg({required String path}) {
//     //Trích xuất hình ảnh ra loại Mat
//     final cv.Mat src = cv.imread(path);
//     //Xử lý ảnh
//     final cv.Mat scanned = _extractPaperAndWarp(src);
//     //Tách hết màu, chỉ để lại đen trắng
//     final cv.Mat thresh = _toBinary(scanned);

//     return OMRResult(
//       total: 0,
//       wrong: 0,
//       correct: 1,
//       picked: [],
//       rawBytes: null,
//       imageBytes: null,
//       threshBytes: null,
//       process: ProccessType.init,
//     );
//   }

//   static OMRResult scanCamera() {
//     return OMRResult(
//       total: 0,
//       wrong: 0,
//       correct: 1,
//       picked: [],
//       rawBytes: null,
//       imageBytes: null,
//       threshBytes: null,
//       process: ProccessType.init,
//     );
//   }

//    /// --- Nhị phân hoá ---
//   static cv.Mat _toBinary(cv.Mat src) {
//     final gray = cv.cvtColor(src, cv.COLOR_BGR2GRAY);
//     final blur = cv.gaussianBlur(gray, (5, 5), 0);
//     final (_, thresh) = cv.threshold(
//       blur,
//       0,
//       255,
//       cv.THRESH_BINARY_INV + cv.THRESH_OTSU,
//     );
//     gray.dispose();
//     blur.dispose();
//     return thresh;
//   }

//   /// --- Tìm tờ giấy mặt phẳng ---
//   static cv.Mat _extractPaperAndWarp(cv.Mat src) {
//     //resize lại ảnh, để hạn chế các thành phần dư thừa
//     final ratio = 800 / src.rows;
//     final resized = CvMethod.resizeImage(
//       src: src,
//       dsize: ((src.cols * ratio).round(), 800),
//     );

//     //Chuyển ảnh qua màu xám
//     final gray = CvMethod.convertGray(src: resized);

//     //Làm mờ trơn ảnh qua bộ lọc gaussianBlur
//     final blurred = CvMethod.blurring(src: gray, sigmaX: 0, kSize: (5, 5));

//     //xài thuật toán canny để quét ra an
//     final edged = CvMethod.egdering(
//       src: blurred,
//       lowThresh: 50,
//       highThresh: 150,
//     );

//     //Lấy danh sách các đường viền
//     final (cnts, _) = CvMethod.findContours(
//       src: edged,
//       mode: cv.RETR_EXTERNAL,
//       method: cv.CHAIN_APPROX_SIMPLE,
//     );

//     //Tạo list idx sẽ chứa các vecVecPoint sau khi sort
//     final idx = List.generate(cnts.length, (i) => i);
//     //Sort theo diện tich
//     idx.sort(
//       (a, b) => cv.contourArea(cnts[b]).compareTo(cv.contourArea(cnts[a])),
//     );

//     //Tìm vị trí contours lớn nhất, mảnh giấy, trang giấy làm bài
//     List<cv.Point>? paper;

//     //Dựa vào chu vi để biết được
//     for (final i in idx) {
//       final c = cnts[i];
//       final peri = cv.arcLength(c, true); //tính chu vi
//       //vì contours lớn nhất có rất nhiều điểm, nên gọi đến approx để làm giảm nhiễu
//       final approx = cv.approxPolyDP(c, 0.02 * peri, true);
//       //nếu mà approx ra được countour có 4 cạnh gán tờ giấy bằng approx
//       if (approx.length == 4) {
//         paper = [for (var j = 0; j < approx.length; j++) approx[j]];
//         break;
//       }
//     }

//     if (paper == null) {
//       gray.dispose();
//       blurred.dispose();
//       edged.dispose();
//       return resized;
//     }

//     //Xếp lại vị trí 4 đỉnh theo thứ thự
//     //[top-left, top-right, bottom-right, bottom-left]
//     final ordered = cv.VecPoint.fromList(_orderPoints(paper));

//     //vì tờ giấy xong khi được lấy ra sẽ có thể bị nghiêng góc,
//     //nên phải xử lý để nó trở thành 1 mặt phẳng hoàn toàn
//     final dstSize = (700, 800);
//     final dstPts = cv.VecPoint.fromList([
//       cv.Point(0, 0),
//       cv.Point(dstSize.$1 - 1, 0),
//       cv.Point(dstSize.$1 - 1, dstSize.$2 - 1),
//       cv.Point(0, dstSize.$2 - 1),
//     ]);

//     //Tính ma trận biến đổi phối cảnh (perspective matrix) giữa 2 tập điểm (4 góc thật và 4 góc chuẩn).
//     final M = cv.getPerspectiveTransform(ordered, dstPts);
//     //Dùng ma trận đó để biến đổi toàn bộ ảnh – kéo, xoay, làm thẳng ảnh.
//     final warped = cv.warpPerspective(resized, M, dstSize);

//     gray.dispose();
//     blurred.dispose();
//     edged.dispose();

//     return warped;
//   }

//   /// --- Sắp xếp 4 đỉnh ---
//   static List<cv.Point> _orderPoints(List<cv.Point> pts) {
//     pts.sort((a, b) => (a.x + a.y).compareTo(b.x + b.y));
//     final tl = pts.first; // top left
//     final br = pts.last; // bottom right
//     final remain = pts.where((p) => p != tl && p != br).toList();
//     remain.sort((a, b) => (a.y - a.x).compareTo(b.y - b.x));
//     final tr = remain.first; // top right
//     final bl = remain.last; // bottom left
//     // [top left, top right, bottom right, bottom left]
//     return [tl, tr, br, bl];
//   }
// }
