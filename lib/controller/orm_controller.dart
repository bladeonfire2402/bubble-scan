// import "package:enhance/services/orm_service.dart";
// import "package:enhance/core/enum/index.dart";
// import "package:enhance/interface/index.dart";
// import "package:get/get.dart";

// const Map<int, int> answerKey = {0: 1, 1: 4, 2: 0, 3: 2, 4: 0};

// class OrmController extends GetxController {
//   static const int _questionPerRows = 5;
//   static const Map<int, int> _answerKey = {0: 1, 1: 4, 2: 0, 3: 2, 4: 0};
  
//   Rx<OMRResult> data = Rx<OMRResult>(
//     OMRResult(
//       total: 0,
//       wrong: 0,
//       correct: 1,
//       picked: [],
//       rawBytes: null,
//       imageBytes: null,
//       threshBytes: null,
//       process: ProccessType.init,
//     ),
//   );

//   void handleImage({String? path, String? stringParam, required Enum method}) {
//     //báo lỗi lúc debug
//     assert(
//       (method == HandleImgMethod.picking && path != null) ||
//           (method == HandleImgMethod.scanning && stringParam != null),
//       "Method requires the correct parameter. "picking" requires intParam, "scanning" requires stringParam.",
//     );

//     if (method == HandleImgMethod.picking) {
//       data.value = OrmService.scanPickImg(path: path!);
//     } else {
//       data.value = OrmService.scanCamera();
//     }
//   }
// }
