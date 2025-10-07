import "package:opencv_dart/opencv.dart" as cv;
import "dart:typed_data";

class CvMethod {
  static cv.Mat resizeImage({required cv.Mat src, required (int, int) dsize}) {
    return cv.resize(src, dsize);
  }

  //loại bỏ đi màu sắc không cần thiết, chỉ dữ lại ảnh sáng
  static cv.Mat convertGray({required cv.Mat src}) {
    return cv.cvtColor(src, cv.COLOR_BGR2GRAY);
  }

  //hàm lấy Matrix
  static cv.Mat getMat({required String path}) {
    return cv.imread(path);
  }

  //giảm làm nhiễu ảnh
  static cv.Mat blurring({
    double sigmaX = 0, //độ lệch chuẩn theo trục X
    required cv.Mat src,
    (int, int) kSize = (5, 5), // tham số này để điều chỉnh độ mờ
  }) {
    return cv.gaussianBlur(src, kSize, sigmaX);
  }

  //xử lý ảnh để nó lộ ra các đường viền  nhưng khung giấy, đường viền, ô tròn
  static cv.Mat egdering({
    required cv.Mat src,
     double lowThresh = 50,
     double highThresh = 150,
  }) {
    return cv.canny(src, lowThresh, highThresh);
  }

  //Xử lý ảnh lọc ra các đường viền, hình dạng
  static (cv.VecVecPoint, cv.VecVec4i) findContours({required cv.Mat src}) {
    return cv.findContours(src, cv.RETR_EXTERNAL, cv.CHAIN_APPROX_SIMPLE);
  }

  static double getArea(cv.VecPoint cnt, {required cv.VecPoint vecPoint}) {
    return cv.contourArea(vecPoint);
  }

  static (Uint8List, Uint8List, Uint8List) imencodeImg({
    required cv.Mat raw,
    required cv.Mat scanned,
    required cv.Mat thresh,
  }) {
    final (_, enraw) = cv.imencode(".png", raw);
    final (_, enthresh) = cv.imencode(".png", thresh);
    final (_, enscanned) = cv.imencode(".png", scanned);

    return (enraw, enthresh, enscanned);
  }
}
