// import "package:enhance/methods/meomeo.dart";
// import "package:flutter/material.dart";
// import "package:image_picker/image_picker.dart";

// class BubblePicking extends StatefulWidget {
//   const BubblePicking({super.key});

//   @override
//   State<BubblePicking> createState() => _BubblePickingState();
// }

// class _BubblePickingState extends State<BubblePicking> {
//   OMRResult omrResult = OMRResult(
//     total: 0,
//     wrong: 0,
//     correct: 0,
//     picked: [],
//     imageBytes: null,
//     rawBytes: null,
//     threshBytes: null,
//   );

//   @override
//   void initState() {
//     super.initState();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(title: const Text("ORM")),
//         body: Container(
//           alignment: Alignment.center,
//           child: Column(
//             children: [
//               ElevatedButton(
//                 onPressed: () async {
//                   final picker = ImagePicker();
//                   final img = await picker.pickImage(
//                     source: ImageSource.gallery,
//                   );
//                   if (img != null) {
//                     setState(() {
//                       omrResult = OMRScannerVer2.scanFromPath(img.path);
//                     });
//                   }
//                 },
//                 child: Text("Chọn ảnh"),
//               ),
//               SizedBox(height: 20),

//               // Hiển thị ảnh nếu đã có _imageBytes
//               if (omrResult.imageBytes != null)
//                 Expanded(
//                   flex: 2,
//                   child: ListView(
//                     scrollDirection: Axis.horizontal,
//                     children: [
//                       Expanded(
//                         child: Image.memory(
//                           omrResult.rawBytes!,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       SizedBox(width: 20),
//                       Expanded(
//                         child: Image.memory(
//                           omrResult.imageBytes!,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       SizedBox(width: 20),

//                       Expanded(
//                         child: Image.memory(
//                           omrResult.threshBytes!,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               SizedBox(height: 20),
//               Expanded(
//                 child: Text(
//                   "Tổng số câu hỏi: ${omrResult.total}, số câu đúng: ${omrResult.correct}, số câu sai: ${omrResult.wrong}",
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
