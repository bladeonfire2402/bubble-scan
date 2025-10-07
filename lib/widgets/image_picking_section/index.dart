// import "package:enhance/controller/image_picking_controller.dart";
// import "package:image_picker/image_picker.dart";
// import "package:enhance/core/enum/index.dart";
// import "package:flutter/material.dart";
// import "package:get/get.dart";

// class ImagePickingSection extends StatelessWidget {
//   ImagePickingSection({super.key});

//   final ImagePickingController _imgCtrl = Get.find();

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         border: Border.all(color: Colors.black, width: 2),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Obx(
//         () {
//           //để display img mặc định hay img lấy từ file img picker
//           Widget displayedImage;
//           if (_imgCtrl.state == ProccessType.successfull && _imgCtrl.imgBytes != null) {
//             displayedImage = Image.memory(_imgCtrl.imgBytes!);
//           } else {
//             displayedImage = Image.asset("assets/images/noimg.jpg", fit: BoxFit.fill);
//           }

//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Expanded(child: displayedImage),
//               if (_imgCtrl.state == ProccessType.pending)
//                 Center(child: CircularProgressIndicator()), // Show loading indicator when pending
//               if (_imgCtrl.state != ProccessType.pending)
//                 IconButton(
//                   onPressed: _pickImage,
//                   icon: Text("Pick image"),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   // Method to handle image picking
//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     _imgCtrl.changeState(ProccessType.pending);
//     final img = await picker.pickImage(source: ImageSource.gallery);

//     if (img != null) {
//       final bytes = await img.readAsBytes();
//       _imgCtrl.changeState(ProccessType.successfull);
//       _imgCtrl.setImage(bytes: bytes);
//     } else {
//       _imgCtrl.changeState(ProccessType.error);
//     }
//   }
// }
