import "dart:typed_data";
import "package:enhance/controller/omr_controller.dart";
import "package:enhance/core/enum/index.dart";
import "package:enhance/main.dart";
import "package:enhance/screen/result_screen/index.dart";
import "package:opencv_dart/opencv.dart" as cv;
import "package:enhance/interface/index.dart";
import "package:flutter/material.dart";
import 'package:camera/camera.dart';
// found in the LICENSE file.
import 'dart:async';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  String error = "";
  CameraController? _controller;
  bool isCall = false;
  StreamController resultController = StreamController<bool>();

  OMRResult result = OMRResult(picked: []);
  //biến này để hạn chế gọi lại hàm xử lý ảnh
  int frameCounter = 0;

  void initCamera() async {
    _controller = CameraController(cameras[0], ResolutionPreset.max);
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

  Future<void> startHandleGrade() async {
    if (_controller != null) {
      _controller!.startImageStream((CameraImage image) async {
        frameCounter++;
        // final XFile picture = await _controller!.takePicture();
        //sau 31 frame mới gọi 1 lần
        if (frameCounter % 23 == 0) {
          await convertCameraImageToMat(image);
          // final imgMat = convertCameraImageToMat(image);

          // final matImg = CvMethod.convertGray(src: imgMat);
        }
      });
    }
  }

  Future<void> startVideo() async {
    if (_controller != null) {
      _controller!.startImageStream((CameraImage image) async {
        frameCounter++;
        // final XFile picture = await _controller!.takePicture();
        //sau 31 frame mới gọi 1 lần
        if (frameCounter % 37 == 0) {
          final img = await convertCameraImageToMat(image);

          final (isTest, bubbles, png) = OmrController.isTest(img: img);

          if (isTest) {
            result = OmrController.handleGrade(img: img);

            if (result.process == ProccessType.successfull) {
              if (!isCall) {
                resultController.sink.add(true);
              }
              setState(() {
                isCall = true;
              });
            }
          } else {
            setState(() {
              error = "Not found the test yet";
              // rgbAImg = png;
            });
          }
          // final imgMat = convertCameraImageToMat(image);

          // final matImg = CvMethod.convertGray(src: imgMat);
        }
      });
    }
  }

  Future<cv.Mat> rotateForDisplay({
    required cv.Mat srcBGR,
    required int sensorOrientation, // 0 | 90 | 180 | 270
    required bool isFrontCamera, // lensDirection == CameraLensDirection.front
    bool mirrorSelfie = false, // muốn lật gương cho camera trước thì true
  }) async {
    // Quy ước thường dùng:
    // - Back camera: xoay theo sensorOrientation
    // - Front camera: xoay ngược lại (360 - sensorOrientation)
    final int degrees = isFrontCamera
        ? (360 - sensorOrientation) % 360
        : sensorOrientation;

    cv.Mat rotated = srcBGR;
    switch (degrees) {
      case 90:
        rotated = cv.rotate(rotated, cv.ROTATE_90_CLOCKWISE);
        break;
      case 180:
        rotated = cv.rotate(rotated, cv.ROTATE_180);
        break;
      case 270:
        rotated = cv.rotate(rotated, cv.ROTATE_90_COUNTERCLOCKWISE);
        break;
      default:
        // 0 độ: giữ nguyên
        break;
    }

    // Tuỳ chọn lật gương cho camera trước (selfie)
    if (isFrontCamera && mirrorSelfie) {
      rotated = cv.flip(rotated, 1); // 1 = lật ngang
    }

    return rotated;
  }

  Future<cv.Mat> convertCameraImageToMat(CameraImage image) async {
    if (image.format.group != ImageFormatGroup.yuv420) {
      throw Exception("Unsupported image format.");
    }

    final width = image.width;
    final height = image.height;

    final Plane yPlane = image.planes[0];
    final Plane uPlane = image.planes[1];
    final Plane vPlane = image.planes[2];

    final int yRowStride = yPlane.bytesPerRow;
    final int uRowStride = uPlane.bytesPerRow;
    final int vRowStride = vPlane.bytesPerRow;
    final int uvPixStride =
        uPlane.bytesPerPixel ?? 1; // 1 => I420, 2 => NV21/NV12

    // Buffer YUV420 compact (width*height*3/2)
    final int ySize = width * height;
    final int uvH = height ~/ 2;
    final int uvW = width ~/ 2;
    final Uint8List yuv420 = Uint8List(ySize + 2 * uvW * uvH);

    // 1) Copy Y (tôn trọng row stride)
    int dst = 0;
    for (int r = 0; r < height; r++) {
      final int srcOff = r * yRowStride;
      yuv420.setRange(
        dst,
        dst + width,
        yPlane.bytes.sublist(srcOff, srcOff + width),
      );
      dst += width;
    }

    // 2) Copy UV
    if (uvPixStride == 1) {
      // ==> I420: U plane (width/2 per row) rồi V plane (width/2 per row)
      // Copy U
      int uDst = ySize;
      for (int r = 0; r < uvH; r++) {
        final int srcOff = r * uRowStride;
        yuv420.setRange(
          uDst,
          uDst + uvW,
          uPlane.bytes.sublist(srcOff, srcOff + uvW),
        );
        uDst += uvW;
      }
      // Copy V
      int vDst = ySize + uvW * uvH;
      for (int r = 0; r < uvH; r++) {
        final int srcOff = r * vRowStride;
        yuv420.setRange(
          vDst,
          vDst + uvW,
          vPlane.bytes.sublist(srcOff, srcOff + uvW),
        );
        vDst += uvW;
      }
    } else {
      // uvPixStride == 2  ==> NV21 (VU interleaved). Android thường là NV21 (V trước U)
      // Mỗi hàng UV compact dài 'width' byte (VU VU ...), nên ta ghi từng cặp (V,U)
      int uvDst = ySize;
      for (int r = 0; r < uvH; r++) {
        for (int c = 0; c < uvW; c++) {
          final int uSrc = r * uRowStride + c * uvPixStride;
          final int vSrc = r * vRowStride + c * uvPixStride;
          yuv420[uvDst++] = vPlane.bytes[vSrc]; // V
          yuv420[uvDst++] = uPlane.bytes[uSrc]; // U
        }
      }
    }

    // 3) Tạo Mat YUV (1 kênh, h + h/2 x w)
    final matYUV = cv.Mat.fromList(
      height + height ~/ 2, // rows
      width, // cols
      cv.MatType.CV_8UC1,
      yuv420.cast<num>(),
    );

    final isFront =
        _controller!.description.lensDirection == CameraLensDirection.front;
    final sensor = _controller!.description.sensorOrientation; // 0/90/180/270

    // 4) Đổi màu về BGR
    final code = (uvPixStride == 1)
        ? cv.COLOR_YUV2BGR_I420
        : cv.COLOR_YUV2BGR_NV21;

    final matBGR = cv.cvtColor(matYUV, code);

    final matDisplay = await rotateForDisplay(
      srcBGR: matBGR,
      sensorOrientation: sensor,
      isFrontCamera: isFront,
      mirrorSelfie: true, // nếu muốn ảnh như gương cho camera trước
    );

    // 5) (Tuỳ chọn) xoay đúng hướng nếu cần, ví dụ:
    // final matRot = await cv.rotate(matBGR, cv.ROTATE_90_CLOCKWISE);

    return matDisplay;
  }

  void setUp() async {
    // Lấy danh sách các camera

    // Kiểm tra xem có camera hay không
    if (cameras.isEmpty) {
      setState(() {
        error = "Không có camera nào khả dụng";
        debugPrint(error.toString());
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

  void setUpStream() {
    resultController.stream.listen((data) {
      if (!mounted) return; // ✅ Guard against disposed widget
      if (data) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ResultScreen(result: result)),
        );
      }
    });
  }

  @override
  void initState() {
    setUp();
    setUpStream();
    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    resultController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Placeholder();
    }
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.blue,
              border: Border.all(color: Colors.blue, width: 3.0),
            ),
            child: CameraPreview(
              _controller!,
              child: Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        offset: Offset(2, 2), // Độ lệch của bóng (x, y)
                        blurRadius: 3.0, // Độ mờ của bóng
                        color: const Color.fromARGB(
                          66,
                          255,
                          254,
                          254,
                        ), // Màu bóng
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
