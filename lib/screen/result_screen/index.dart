import 'package:enhance/interface/index.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  // final OMRResult result;

  @override
  Widget build(BuildContext context) {
    String handleAnswer(int answer) {
      List<String> formatAnswer = ["A", "B", "C", "D", "E"];
      return formatAnswer[answer];
    }

    return Column(children: []);
  }
}
