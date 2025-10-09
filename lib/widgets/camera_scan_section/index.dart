  // import "package:flutter/material.dart";
  // import "package:opencv_dart/opencv.dart" as cv;
  // import "package:camera/camera.dart";

  // class CameraScanSection extends StatelessWidget {
  //   const CameraScanSection({super.key});

  //   @override
  //   Widget build(BuildContext context) {
  //     return const Placeholder();
  //   }
  // }


  // class RealTimeScan extends StatefulWidget {
  //   const RealTimeScan({super.key});

  //   @override
  //   _RealTimeScanState createState() => _RealTimeScanState();
  // }

  // class _RealTimeScanState extends State<RealTimeScan> {
  //   late CameraController _controller;
  //   late Future<void> _initializeControllerFuture;

  //   // Camera feed sẽ được xử lý ở đây
  //   late List<CameraDescription> cameras;

  //   @override
  //   void initState() {
  //     super.initState();
  //     // Lấy danh sách camera
  //     availableCameras().then((availableCameras) {
  //       cameras = availableCameras;
  //       _controller = CameraController(cameras[0], ResolutionPreset.high);
  //       _initializeControllerFuture = _controller.initialize();
  //       _controller.startImageStream((CameraImage image) {
  //         processCameraFrame(image);
  //       });
  //     });
  //   }

  //   @override
  //   void dispose() {
  //     _controller.dispose();
  //     super.dispose();
  //   }

  //   // Xử lý từng frame từ camera
  //   void processCameraFrame(CameraImage image) async {
  //     // Chuyển đổi ảnh từ CameraImage (YUV) thành Mat (OpenCV)
  //     final imgBytes = await _convertCameraImageToMat(image);

  //     // Áp dụng các thao tác xử lý ảnh OpenCV (ví dụ: thresholding)
  //     final cv.Mat gray = cv.cvtColor(imgBytes, cv.COLOR_YUV2GRAY_NV21);
  //     final (_, thresh) = cv.threshold(gray, 0, 255, cv.THRESH_BINARY + cv.THRESH_OTSU);

  //     // Tìm cạnh
  //     final cv.Mat edged = cv.canny(thresh, 50, 150);

  //     // Hiển thị kết quả quét (nếu cần)
  //     showProcessedFrame(edged);
  //   }

  //   // Chuyển CameraImage thành Mat (OpenCV)
  //   Future<cv.Mat> _convertCameraImageToMat(CameraImage image) async {
  //     final planes = image.planes;
  //     final bytes = planes[0].bytes;

  //     // Đọc byte dữ liệu của ảnh vào Mat
  //     //Đoạn này lưu ý về xem lại
  //     final cv.Mat imgMat = cv.imencode(".png", bytes as cv.InputArray) as cv.Mat;

  //     return imgMat;
  //   }

  //   // Hiển thị kết quả quét
  //   void showProcessedFrame(cv.Mat frame) {
  //     // Đây có thể là một cách để hiển thị ảnh sau khi xử lý, chẳng hạn như:
  //     // Chuyển đổi Mat thành image và hiển thị trên giao diện người dùng.
  //     // Cách này có thể phức tạp vì Flutter không hỗ trợ trực tiếp Mat -> Image
  //   }

  //   @override
  //   Widget build(BuildContext context) {
  //     return Scaffold(
  //       appBar: AppBar(title: Text("Real-time Scan")),
  //       body: FutureBuilder<void>(
  //         future: _initializeControllerFuture,
  //         builder: (context, snapshot) {
  //           if (snapshot.connectionState == ConnectionState.done) {
  //             return CameraPreview(_controller); // Hiển thị ảnh từ camera
  //           } else {
  //             return Center(child: CircularProgressIndicator());
  //           }
  //         },
  //       ),
  //     );
  //   }
  // }
