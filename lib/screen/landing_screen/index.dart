// import "package:enhance/widgets/camera_scan_section/index.dart";
// import "package:enhance/widgets/image_picking_section/index.dart";
// import "package:enhance/widgets/toggle_section/index.dart";
// import "package:enhance/controller/switch_controller.dart";
// import "package:flutter/material.dart";
// import "package:get/get.dart";

// class LandingScreen extends StatefulWidget {
//   const LandingScreen({super.key});

//   @override
//   State<LandingScreen> createState() => _LandingScreenState();
// }

// class _LandingScreenState extends State<LandingScreen> {
//   final SwitchController sc = Get.find();
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           Expanded(flex: 1, child: MyToggleSwitch()),
//           Expanded(
//             flex: 3,
//             child: sc.index == 0 ? ImagePickingSection() : CameraScanSection(),
//           ),
//         ],
//       ),
//     );
//   }
// }
