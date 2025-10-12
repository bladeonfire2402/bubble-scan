// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import "package:opencv_dart/opencv.dart" as cv;

// class CameraController {
//   Future<void> convertCameraImageToMat({
//     required CameraImage image,
//     required CameraController controller,
//   }) async {
//     if (image.format.group != ImageFormatGroup.yuv420) {
//       throw Exception("Unsupported image format.");
//     }

//     final width = image.width;
//     final height = image.height;

//     final Plane yPlane = image.planes[0];
//     final Plane uPlane = image.planes[1];
//     final Plane vPlane = image.planes[2];

//     final int yRowStride = yPlane.bytesPerRow;
//     final int uRowStride = uPlane.bytesPerRow;
//     final int vRowStride = vPlane.bytesPerRow;
//     final int uvPixStride =
//         uPlane.bytesPerPixel ?? 1; // 1 => I420, 2 => NV21/NV12

//     // Buffer YUV420 compact (width*height*3/2)
//     final int ySize = width * height;
//     final int uvH = height ~/ 2;
//     final int uvW = width ~/ 2;
//     final Uint8List yuv420 = Uint8List(ySize + 2 * uvW * uvH);

//     // 1) Copy Y (tôn trọng row stride)
//     int dst = 0;
//     for (int r = 0; r < height; r++) {
//       final int srcOff = r * yRowStride;
//       yuv420.setRange(
//         dst,
//         dst + width,
//         yPlane.bytes.sublist(srcOff, srcOff + width),
//       );
//       dst += width;
//     }

//     // 2) Copy UV
//     if (uvPixStride == 1) {
//       // ==> I420: U plane (width/2 per row) rồi V plane (width/2 per row)
//       // Copy U
//       int uDst = ySize;
//       for (int r = 0; r < uvH; r++) {
//         final int srcOff = r * uRowStride;
//         yuv420.setRange(
//           uDst,
//           uDst + uvW,
//           uPlane.bytes.sublist(srcOff, srcOff + uvW),
//         );
//         uDst += uvW;
//       }
//       // Copy V
//       int vDst = ySize + uvW * uvH;
//       for (int r = 0; r < uvH; r++) {
//         final int srcOff = r * vRowStride;
//         yuv420.setRange(
//           vDst,
//           vDst + uvW,
//           vPlane.bytes.sublist(srcOff, srcOff + uvW),
//         );
//         vDst += uvW;
//       }
//     } else {
//       // uvPixStride == 2  ==> NV21 (VU interleaved). Android thường là NV21 (V trước U)
//       // Mỗi hàng UV compact dài 'width' byte (VU VU ...), nên ta ghi từng cặp (V,U)
//       int uvDst = ySize;
//       for (int r = 0; r < uvH; r++) {
//         for (int c = 0; c < uvW; c++) {
//           final int uSrc = r * uRowStride + c * uvPixStride;
//           final int vSrc = r * vRowStride + c * uvPixStride;
//           yuv420[uvDst++] = vPlane.bytes[vSrc]; // V
//           yuv420[uvDst++] = uPlane.bytes[uSrc]; // U
//         }
//       }
//     }

//     // 3) Tạo Mat YUV (1 kênh, h + h/2 x w)
//     final matYUV = cv.Mat.fromList(
//       height + height ~/ 2, // rows
//       width, // cols
//       cv.MatType.CV_8UC1,
//       yuv420.cast<num>(),
//     );

//     final isFront =
//         controller.description.lensDirection == CameraLensDirection.front;
//     final sensor = controller.description.sensorOrientation; // 0/90/180/270

//     // 4) Đổi màu về BGR
//     final code = (uvPixStride == 1)
//         ? cv.COLOR_YUV2BGR_I420
//         : cv.COLOR_YUV2BGR_NV21;

//     final matBGR = cv.cvtColor(matYUV, code);

//     final matDisplay = await rotateForDisplay(
//       srcBGR: matBGR,
//       sensorOrientation: sensor,
//       isFrontCamera: isFront,
//       mirrorSelfie: true, // nếu muốn ảnh như gương cho camera trước
//     );

//     // 5) (Tuỳ chọn) xoay đúng hướng nếu cần, ví dụ:
//     // final matRot = await cv.rotate(matBGR, cv.ROTATE_90_CLOCKWISE);

//     // 6) Mã hoá PNG từ ảnh màu
//     final (_, pngBytes) = cv.imencode(".png", matDisplay);
//   }

//   Future<cv.Mat> rotateForDisplay({
//     required cv.Mat srcBGR,
//     required int sensorOrientation, // 0 | 90 | 180 | 270
//     required bool isFrontCamera, // lensDirection == CameraLensDirection.front
//     bool mirrorSelfie = false, // muốn lật gương cho camera trước thì true
//   }) async {
//     // Quy ước thường dùng:
//     // - Back camera: xoay theo sensorOrientation
//     // - Front camera: xoay ngược lại (360 - sensorOrientation)
//     final int degrees = isFrontCamera
//         ? (360 - sensorOrientation) % 360
//         : sensorOrientation;

//     cv.Mat rotated = srcBGR;
//     switch (degrees) {
//       case 90:
//         rotated = cv.rotate(rotated, cv.ROTATE_90_CLOCKWISE);
//         break;
//       case 180:
//         rotated = cv.rotate(rotated, cv.ROTATE_180);
//         break;
//       case 270:
//         rotated = cv.rotate(rotated, cv.ROTATE_90_COUNTERCLOCKWISE);
//         break;
//       default:
//         // 0 độ: giữ nguyên
//         break;
//     }

//     // Tuỳ chọn lật gương cho camera trước (selfie)
//     if (isFrontCamera && mirrorSelfie) {
//       rotated = cv.flip(rotated, 1); // 1 = lật ngang
//     }

//     return rotated;
//   }
// }
