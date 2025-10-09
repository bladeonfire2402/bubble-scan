// ignore_for_file: avoid_print

import "package:enhance/root.dart";
import "package:enhance/screen/splash_screen/index.dart";
import "package:flutter/material.dart";

Future<void> main() async {
  //// Đảm bảo rằng binding Flutter được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const Root());
}
