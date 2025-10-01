import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'dart:typed_data';

class BubblePicking extends StatefulWidget {
  const BubblePicking({super.key});

  @override
  State<BubblePicking> createState() => _BubblePickingState();
}

class _BubblePickingState extends State<BubblePicking> {
  final String filePath =
      "/data/user/0/com.example.enhance/cache/9362e094-a8a2-4e35-9abf-7ff3930b5458/test_01.png";
  Uint8List? _imageBytes;

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
                  var docCnt;
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

                  

                  // Mã hóa ảnh thành PNG (hoặc bạn có thể chọn định dạng khác)
                  final encodedImage = cv.imencode('.png', edged);

                  // Chuyển đổi dữ liệu ảnh thành Uint8List
                  setState(() {
                    _imageBytes = encodedImage.$2;
                  });
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
                  }
                },
                child: Text("Pick"),
              ),
              // Hiển thị ảnh nếu đã có _imageBytes
              if (_imageBytes != null)
                Image.memory(_imageBytes!, fit: BoxFit.cover),
            ],
          ),
        ),
      ),
    );
  }
}
