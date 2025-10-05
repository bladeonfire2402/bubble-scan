import 'package:enhance/methods/meomeo.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:opencv_dart/opencv.dart' as cv;

import 'package:opencv_dart/opencv_dart.dart';

class BubblePicking extends StatefulWidget {
  const BubblePicking({super.key});

  @override
  State<BubblePicking> createState() => _BubblePickingState();
}

class _BubblePickingState extends State<BubblePicking> {
  final String filePath =
      "/data/user/0/com.example.enhance/cache/3e75f4bf-9802-4652-bf6b-ce85970803c3/Screenshot_2025-10-05-15-17-11-605_com.zing.zalo.jpg";
  Uint8List? _imageBytes;

  OMRResult omrResult = OMRResult(
    total: 0,
    correct: 0,
    wrong: 0,
    picked: [],
    imageBytes: null,
  );

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Native Packages')),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    omrResult = OMRScannerVer2.scanFromPath(filePath);
                  });
                },
                child: Text("Process"),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Đọc ảnh từ file
                  final image = cv.imread(filePath);
                  //chuyển màu hình sang màu xám
                  final gray = cv.cvtColor(image, cv.COLOR_BGR2GRAY);
                  //làm mờ
                  final blurred = cv.gaussianBlur(gray, (5, 5), 0);

                  //phát hiện các cạnh
                  //Ngưỡng thấp của Canny. Các giá trị gradient thấp hơn ngưỡng này sẽ không được xem là cạnh.
                  //Ngưỡng cao của Canny. Các giá trị gradient cao hơn ngưỡng này sẽ được xem là cạnh chắc chắn.
                  final edged = cv.canny(blurred, 75, 200);

                  final copyEdged = edged;
                  VecPoint docCnt;
                  var paper_contours = image;

                  var cnts = cv.findContours(
                    copyEdged,
                    cv.RETR_EXTERNAL,
                    cv.CHAIN_APPROX_SIMPLE,
                  );

                  cv.VecVecPoint contours =
                      cnts.$1; // Đây là List<List<cv.VecPoint>>

                  if (contours.isNotEmpty) {
                    for (var cnt in contours) {
                      var perimeter = cv.arcLength(cnt, true);
                      var approx = cv.approxPolyDP(cnt, 0.02 * perimeter, true);

                      if (approx.length == 4) {
                        docCnt = approx;
                        cv.drawContours(
                          paper_contours,
                          contours,
                          -1,
                          cv.Scalar(0, 0, 255),
                          thickness: 3,
                        );
                      }
                    }
                  }

                  // var thresh = cv.threshold(
                  //   image,
                  //   0,
                  //   255,
                  //   cv.THRESH_BINARY_INV | cv.THRESH_OTSU,
                  // );

                  //version 2
                  // final scanned = OMRScanner.extractPaperAndWarp(image: image);
                  // final thresh = OMRScanner.toBinary(scanned);

                  // final (cntss, _) = cv.findContours(
                  //   thresh,
                  //   cv.RETR_EXTERNAL,
                  //   cv.CHAIN_APPROX_SIMPLE,
                  // );

                  // final bubbles = OMRScanner.filterBubbles(cntss);

                  // if (bubbles.length == 0) {
                  //   print("Không tìm thấy");
                  // }

                  // Mã hóa ảnh thành PNG (hoặc bạn có thể chọn định dạng khác)
                  // final encodedImage = cv.imencode('.png', scanned);

                  // Chuyển đổi dữ liệu ảnh thành Uint8List
                  // setState(() {
                  //   _imageBytes = encodedImage.$2;
                  // });
                },
                child: const Text("Process"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final img = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) {
                    final path = img.path;
                    print(path);
                  }
                },
                child: Text("Pick"),
              ),
              // Hiển thị ảnh nếu đã có _imageBytes
              if (omrResult.imageBytes != null)
                Expanded(child: Image.memory(omrResult.imageBytes!, fit: BoxFit.cover)),

              Text(
                "Tổng số câu hỏi: ${omrResult.total}, số câu đúng: ${omrResult.correct}, số câu sai: ${omrResult.wrong}",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
