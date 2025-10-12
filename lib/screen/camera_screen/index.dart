import "dart:typed_data";
import "package:enhance/controller/omr_controller.dart";
import "package:enhance/main.dart";
import "package:enhance/methods/cv_method.dart";
import "package:enhance/screen/input_image.dart";
// import "package:opencv_dart/opencv.dart" as cv;
import "package:enhance/interface/index.dart";
import "package:flutter/material.dart";
import 'package:camera/camera.dart';
// found in the LICENSE file.
import 'dart:async';
import 'dart:ui' as ui;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String error = "";
  CameraController? _controller;
  ui.Image? _opencvPreviewImage;

  OMRResult result = OMRResult(picked: []);
  //biến này để hạn chế gọi lại hàm xử lý ảnh
  int frameCounter = 0;

  void initCamera() async {
    _controller = CameraController(cameras![0], ResolutionPreset.max);
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

  Future<void> startVideo() async {
    if (_controller != null) {
      _controller!.startImageStream((CameraImage image) async {
        frameCounter++;
        // final XFile picture = await _controller!.takePicture();
        //sau 31 frame mới gọi 1 lần
        if (frameCounter % 49 == 0) {
          // final imgMat = convertCameraImageToMat(image);

          // final matImg = CvMethod.convertGray(src: imgMat);
        }
      });
    }
  }

  // Future<cv.Mat> convertCameraImageToMat(CameraImage image) async {
  //   if (image.format.group != ImageFormatGroup.yuv420) {
  //     throw Exception("Sai format ảnh");
  //   }

  //   // Lấy dữ liệu từ các kênh Y, U, V của CameraImage
  //   final Plane yPlane = image.planes[0]; // Y plane
  //   final Plane uPlane = image.planes[1]; // U plane
  //   final Plane vPlane = image.planes[2]; // V plane

  //   // Chuyển đổi dữ liệu từ các plane YUV sang BGR
  //   final List<int> uvBytes = <int>[];
  //   uvBytes.addAll(uPlane.bytes);
  //   uvBytes.addAll(vPlane.bytes);

  //   // Lấy toàn bộ dữ liệu ảnh
  //   // final Uint8List imageBytes = yPlane.bytes + uvBytes;
  // }

  // bool isHomeWork({required cv.Mat img}) {
  //   //chuyển đổi sang xám
  //   final matImg = CvMethod.convertGray(src: img);
  //   //phát hiện cạnh
  //   final edges = CvMethod.egdering(src: matImg);
  //   //tìm các đường viền
  //   final (cnts, _) = CvMethod.findContours(src: edges);

  //   //Tạo list idx sẽ chứa các vecVecPoint sau khi sort
  //   final idx = List.generate(cnts.length, (i) => i);
  //   //Sort theo diện tich
  //   idx.sort(
  //     (a, b) => cv.contourArea(cnts[b]).compareTo(cv.contourArea(cnts[a])),
  //   );

  //   final paper = OmrController.getPaper(cnts: cnts);

  //   return paper == null ? false : true;
  // }

  // cv.Mat _convertCameraImageToMat(CameraImage image) {
  //   final planes = image.planes;
  //   final bytes = planes[0].bytes;

  //   // Ensure the byte data is in the correct format for Mat
  //   final List<int> byteList = bytes.toList(); // Convert to List<int>

  //   // Create a Mat object with the correct dimensions (width, height, and channels)
  //   final cv.Mat imgMat = cv.Mat.fromList(
  //     image.height,
  //     image.width,
  //     cv.MatType.CV_8UC1,
  //     byteList,
  //   );

  //   return imgMat;
  // }

  void setUp() async {
    // Lấy danh sách các camera

    // Kiểm tra xem có camera hay không
    if (cameras.isEmpty) {
      setState(() {
        error = "Không có camera nào khả dụng";
        print(error);
      });
      return;
    }

    // Khởi tạo camera
    _controller = CameraController(cameras[0], ResolutionPreset.max);

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

  @override
  void initState() {
    // setUp();
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller!.value.isInitialized) {
      return Container();
    }
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.blue, width: 3.0),
            ),
            child: CameraPreview(_controller!, child: Text("meomeo")),
          ),
        ),
        Expanded(child: Container(color: Colors.white)),
      ],
    );
  }
}
