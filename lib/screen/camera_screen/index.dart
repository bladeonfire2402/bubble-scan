import "package:enhance/controller/omr_controller.dart";
import "package:enhance/main.dart";
import "package:enhance/methods/cv_method.dart";
import "package:enhance/screen/input_image.dart";
import "package:opencv_dart/opencv.dart" as cv;
import "package:enhance/interface/index.dart";
import "package:flutter/material.dart";
import 'package:camera/camera.dart';
// found in the LICENSE file.
import 'dart:async';
import 'dart:async';
import 'dart:io';
import 'dart:math';
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

  // void _processImage(CameraImage image) async {
  //   final format = InputImageFormatValue.fromRawValue(image.format.raw);
  //   if (format == null) return;

  //   final bytes = switch (format) {
  //     InputImageFormat.yuv_420_888 => yuv420ToRGBA8888(image),
  //     InputImageFormat.nv21 => nv21ToRGBA8888(image),
  //     InputImageFormat.bgra8888 => bgraToRgbaInPlace(image.planes.first.bytes),
  //     _ => throw UnimplementedError(),
  //   };

   

  //   cv.Mat mat = cv.Mat.fromList(
  //     image.height,
  //     image.width,
  //     cv.MatType.CV_8UC4,
  //     bytes,
  //   );

  //   final sensorOrientation = _controller?.description.sensorOrientation;
  //   var rotationCompensation = _orientations[_controller?.value.deviceOrientation];
  //   if (rotationCompensation == null || sensorOrientation == null) return;
  //   if (controller?.description.lensDirection == CameraLensDirection.front) {
  //     // front-facing
  //     rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
  //   } else {
  //     // back-facing
  //     rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
  //   }
  //   switch (rotationCompensation) {
  //     case 90:
  //       await cv.rotateAsync(mat, cv.ROTATE_90_CLOCKWISE, dst: mat);
  //     case 180:
  //       await cv.rotateAsync(mat, cv.ROTATE_180, dst: mat);
  //     case 270:
  //       await cv.rotateAsync(mat, cv.ROTATE_90_COUNTERCLOCKWISE, dst: mat);
  //     default:
  //   }

  //   // downsampling
  //   await cv.resizeAsync(mat, (mat.width ~/ 2, mat.height ~/ 2), dst: mat);

  //   // simulate object detection drawing
  //   final x = Random().nextInt(50);
  //   final y = Random().nextInt(50);
  //   await cv.rectangleAsync(
  //     mat,
  //     cv.Rect(
  //       x,
  //       y,
  //       Random().nextInt(mat.width),
  //       Random().nextInt(mat.height),
  //     ),
  //     cv.Scalar.red,
  //     thickness: 3,
  //   );
  //   await cv.putTextAsync(
  //     mat,
  //     'Hello World',
  //     cv.Point(x, y),
  //     cv.FONT_HERSHEY_SIMPLEX,
  //     1,
  //     cv.Scalar.blue,
  //     thickness: 3,
  //   );

  //   // convert to ui.Image
  //   final uiImage = await mat.toUiImage();
  //   mat.dispose();

  //   setState(() {
  //     _opencvPreviewImage = uiImage;
  //   });
  // }

  Future<void> startVideo() async {
    if (_controller != null) {
      _controller!.startImageStream((CameraImage image) {
        frameCounter++;
        //sau 31 frame mới gọi 1 lần
        if (frameCounter % 37 == 0) {
          final planes = image.planes;
          final bytes = planes[0].bytes;

          // final matImg = CvMethod.convertGray(src: imgMat);
        }
      });
    }
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
    if (_controller == null) {
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
