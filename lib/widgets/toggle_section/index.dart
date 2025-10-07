// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:enhance/controller/switch_controller.dart';
// import 'package:toggle_switch/toggle_switch.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class MyToggleSwitch extends StatelessWidget {
//   const MyToggleSwitch({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final SwitchController sc = Get.find();
//     final color = Theme.of(context).colorScheme;
//     return ToggleSwitch(
//       minWidth: 90.0,
//       iconSize: 30.0,
//       minHeight: 70.0,
//       totalSwitches: 2,
//       cornerRadius: 20.0,
//       initialLabelIndex: 0,
//       activeFgColor: Colors.white,
//       inactiveBgColor: Colors.grey,
//       inactiveFgColor: Colors.white,
//       activeBgColors: [
//         [Colors.black45, Colors.black26],
//         [Colors.yellow, Colors.orange],
//       ],
//       icons: [FontAwesomeIcons.lightbulb, FontAwesomeIcons.solidLightbulb],
//       animate:
//           true, // with just animate set to true, default curve = Curves.easeIn
//       curve: Curves
//           .bounceInOut, // animate must be set to true when using custom curve
//       onToggle: (_) {
//         sc.toggleIndex();
//       },
//     );
//   }
// }
