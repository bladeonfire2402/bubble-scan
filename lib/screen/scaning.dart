import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv.dart' as cv;
import 'package:camera/camera.dart';

class Scaning extends StatefulWidget {
  const Scaning({super.key});

  @override
  State<Scaning> createState() => _ScaningState();
}

class _ScaningState extends State<Scaning> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras = [];

  @override
  void initState() {
    super.initState();
    // Initialize the camera
    _initializeCamera();
  }

  // Declare 'availableCameras' before use
  Future<void> _initializeCamera() async {
    
    // Now, we can safely assign it to the cameras list
    cameras = await availableCameras();

    // Set up the CameraController for the first camera
    _controller = CameraController(cameras[0], ResolutionPreset.high);
    _initializeControllerFuture = _controller!.initialize();
    
    // Start the camera image stream
    _controller!.startImageStream((CameraImage image) {
      processCameraFrame(image);
    });
  }

  void processCameraFrame(CameraImage image) async {
    // Convert CameraImage (YUV) to Mat (OpenCV)
    final imgMat = await _convertCameraImageToMat(image);

    // Apply OpenCV image processing (e.g., thresholding)
    final cv.Mat gray = cv.cvtColor(imgMat, cv.COLOR_YUV2GRAY_NV21);
    final (_, thresh) = cv.threshold(
      gray,
      0,
      255,
      cv.THRESH_BINARY + cv.THRESH_OTSU,
    );

    // Find edges
    final cv.Mat edged = cv.canny(thresh, 50, 150);

    // Show processed frame (if needed)
    showProcessedFrame(edged);
  }

  void showProcessedFrame(cv.Mat frame) {
    // This method will display the processed image, 
    // but you need to convert Mat to Image for Flutter display.
    // You can convert the processed frame to an image here.
  }

  Future<cv.Mat> _convertCameraImageToMat(CameraImage image) async {
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

  @override
  void dispose() {
    _controller?.dispose(); // Safely dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Real-time Scan")),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture, // Wait for the controller to be initialized
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller!); // Show camera preview when done
          } else {
            return Center(child: CircularProgressIndicator()); // Show loading while initializing
          }
        },
      ),
    );
  }
}
