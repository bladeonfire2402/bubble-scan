// ignore_for_file: avoid_print

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:opencv_dart/opencv.dart' as cv;

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var images = <Uint8List>[];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<(cv.Mat, cv.Mat)> heavyTaskAsync(cv.Mat im, {int count = 1000}) async {
    late cv.Mat gray, blur;
    for (var i = 0; i < count; i++) {
      gray = await cv.cvtColorAsync(im, cv.COLOR_BGR2GRAY);
      blur = await cv.gaussianBlurAsync(im, (7, 7), 2, sigmaY: 2);
      if (i != count - 1) {
        gray.dispose(); // manually dispose
        blur.dispose(); // manually dispose
      }
    }
    return (gray, blur);
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
                  final data = await DefaultAssetBundle.of(context).load("assets/images/logo.png");
                  final bytes = data.buffer.asUint8List();
                  final (gray, blur) = await heavyTaskAsync(cv.imdecode(bytes, cv.IMREAD_COLOR));
                  setState(() {
                    images = [bytes, cv.imencode(".png", gray).$2, cv.imencode(".png", blur).$2];
                  });
                },
                child: const Text("Process"),
              ),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: images.length,
                        itemBuilder: (ctx, idx) => Card(child: Image.memory(images[idx])),
                      ),
                    ),
                    Expanded(child: SingleChildScrollView(child: Text(cv.getBuildInformation()))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}