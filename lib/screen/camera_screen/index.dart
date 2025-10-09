import "package:enhance/controller/omr_controller.dart";
import "package:enhance/methods/cv_method.dart";
import "package:opencv_dart/opencv.dart" as cv;
import "package:enhance/core/enum/index.dart";
import "package:enhance/interface/index.dart";
import "package:flutter/material.dart";
import "package:camera/camera.dart";

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String error = "";
  CameraController? _controller;
  List<CameraDescription>? _cameras;

  OMRResult result = OMRResult(picked: []);
  //biến này để hạn chế gọi lại hàm xử lý ảnh
  int frameCounter = 0;

  void initCamera() async {
    _controller = CameraController(_cameras![0], ResolutionPreset.max);
    _controller!
        .initialize()
        .then((_) {
          if (!mounted) {
            return;
          }
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case "CameraAccessDenied":
                error = "Vui lòng cho phép truy cập camera";
                setState(() {});
                break;
              default:
                error = "Lỗi camera";
                setState(() {});
                break;
            }
          }
        });
  }

  void startVideo() {
    _controller!.startImageStream((CameraImage image) {
      frameCounter++;
      // Chỉ xử lý mỗi 5 khung hình
      if (frameCounter % 3 == 0) {
        final imgMat = _convertCameraImageToMat(image);
        if (imgMat.channels == 3) {
          print("working");
          print(frameCounter);
          // bool ishomeWork = isHomeWork(img: imgMat);

          //final mat = cv.cvtColor(imgMat, cv.COLOR_BGR2GRAY);
          imgMat.release();
        }
        // bool ishomeWork = isHomeWork(img: imgMat);
        // if (ishomeWork == true) {
        //   //call hàm chấm điểm
        //   result = OmrController.handleGrade(img: imgMat);
        // }
      }
    });
  }

  bool isHomeWork({required cv.Mat img}) {
    //chuyển đổi sang xám
    final matImg = CvMethod.convertGray(src: img);
    //phát hiện cạnh
    final edges = CvMethod.egdering(src: matImg);
    //tìm các đường viền
    final (cnts, _) = CvMethod.findContours(src: edges);

    //Tạo list idx sẽ chứa các vecVecPoint sau khi sort
    final idx = List.generate(cnts.length, (i) => i);
    //Sort theo diện tich
    idx.sort(
      (a, b) => cv.contourArea(cnts[b]).compareTo(cv.contourArea(cnts[a])),
    );

    final paper = OmrController.getPaper(cnts: cnts);

    return paper == null ? false : true;
  }

  cv.Mat _convertCameraImageToMat(CameraImage image) {
    final planes = image.planes;
    final bytes = planes[0].bytes;

    // Ensure the byte data is in the correct format for Mat
    final List<int> byteList = bytes.toList(); // Convert to List<int>

    // Create a Mat object with the correct dimensions (width, height, and channels)
    final cv.Mat imgMat = cv.Mat.fromList(
      image.height,
      image.width,
      cv.MatType.CV_8UC1,
      byteList,
    );

    return imgMat;
  }

  void setUp() async {
    // Lấy danh sách các camera
    _cameras = await availableCameras();

    // Kiểm tra xem có camera hay không
    if (_cameras!.isEmpty) {
      setState(() {
        error = "Không có camera nào khả dụng";
      });
      return;
    }

    // Khởi tạo camera
    _controller = CameraController(_cameras![0], ResolutionPreset.max);

    // Khởi tạo camera
    await _controller!
        .initialize()
        .then((_) {
          // Sau khi camera đã khởi tạo, bắt đầu xử lý video
          startVideo();
          setState(() {});
        })
        .catchError((Object e) {
          if (e is CameraException) {
            switch (e.code) {
              case "CameraAccessDenied":
                error = "Vui lòng cho phép truy cập camera";
                break;
              default:
                error = "Lỗi camera";
                break;
            }
            setState(() {});
          }
        });
  }

  String handleAnswer(int answer) {
    List<String> formatAnswer = ["A", "B", "C", "D", "E"];
    return formatAnswer[answer];
  }

  @override
  void initState() {
    setUp();
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller!.value.isInitialized) {
      return Container();
    }
    return MaterialApp(
      home: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          if (result.process == ProccessType.loaded)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tổng số câu hỏi: ${result.total}\n"
                    "Số câu trả lời chính xác: ${result.correct}\n"
                    "Số câu trả lời sai: ${result.wrong}",
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: result.picked.length,
                      itemBuilder: (context, index) {
                        final pick = result.picked[index]!;
                        final correctAnswer = OmrController.answerKey[index]!;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Câu đã chọn: ${handleAnswer(pick)}"),
                            if (pick != correctAnswer)
                              Text(
                                "Câu trả lời đúng: ${handleAnswer(correctAnswer)}",
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
