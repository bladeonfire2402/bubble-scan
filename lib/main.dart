// ignore_for_file: avoid_print

import "package:camera/camera.dart";
import "package:enhance/root.dart";
import "package:flutter/material.dart";

List<CameraDescription> get cameras => _cameras;
List<CameraDescription> _cameras = <CameraDescription>[];

Future<void> main() async {
  //// Đảm bảo rằng binding Flutter được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const Root());
}
