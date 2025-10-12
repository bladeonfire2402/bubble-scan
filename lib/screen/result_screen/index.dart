import 'package:enhance/controller/omr_controller.dart';
import 'package:enhance/widgets/pie_chart/index.dart';
import 'package:enhance/interface/index.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.result});
  final OMRResult result;

  @override
  Widget build(BuildContext context) {
    String handleAnswer(int answer) {
      List<String> formatAnswer = ["A", "B", "C", "D", "E"];
      return formatAnswer[answer];
    }

    double getPercent({required int percent}) {
      return percent / result.total * 100;
    }

    Widget buildBadge({
      required Color color,
      required String title,
      required IconData icon,
    }) {
      return Row(
        spacing: 4,
        children: [
          Icon(icon, color: color),
          Text(title, style: TextStyle(color: color)),
        ],
      );
    }

    Widget buildAnswer({
      required int pick,
      required int index,
      required int answer,
    }) {
      bool isCorrect = pick == answer;
      Color color = isCorrect ? Colors.blue : Colors.orange;
      IconData icon = isCorrect ? Icons.check_circle : Icons.cancel;
      return Card(
        elevation: 3,
        shadowColor: color,
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: Icon(icon, color: color),
          title: Text("Question ${index + 1}"),
          subtitle: Row(
            spacing: 4,
            children: [
              Text(handleAnswer(pick), style: TextStyle(color: color)),
              if (isCorrect == false)
                Text(
                  "- The answer is ${handleAnswer(answer)}!",
                  style: TextStyle(color: color),
                ),
            ],
          ),
        ),
      );
    }

    Widget resultBadgeSection() {
      return Row(
        spacing: 10,
        children: [
          buildBadge(
            color: Colors.blue,
            icon: Icons.check_circle,
            title: result.correct.toString(),
          ),
          buildBadge(
            icon: Icons.cancel,
            color: Colors.orange,
            title: result.wrong.toString(),
          ),
        ],
      );
    }

    Widget buildCardSection() {
      return Expanded(
        flex: 4,
        child: Card(
          elevation: 3,
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      "Average",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Text(
                  "${getPercent(percent: result.correct)}%",
                  style: TextStyle(
                    fontSize: 32,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8,),
                Expanded(
                  child: MyPieChart(
                    wrongPer: getPercent(percent: result.wrong),
                    correctPer: getPercent(percent: result.correct),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget buildGradingSection() {
      return Expanded(
        flex: 6,
        child: SizedBox(
          child: ListView.builder(
            itemCount: result.picked.length,
            itemBuilder: (context, index) {
              final pick = result.picked[index];
              final answer = OmrController.answerKey[index];
              return buildAnswer(pick: pick!, answer: answer!, index: index);
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          "Result",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          spacing: 10,
          children: [
            buildCardSection(),
            resultBadgeSection(),
            buildGradingSection(),
          ],
        ),
      ),
    );
  }
}
