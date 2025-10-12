import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MyPieChart extends StatefulWidget {
  const MyPieChart({
    super.key,
    required this.wrongPer,
    required this.correctPer,
  });

  final double wrongPer;
  final double correctPer;

  @override
  State<MyPieChart> createState() => _PieChartState();
}

class _PieChartState extends State<MyPieChart> {
  int touchedIndex = -1;

  List<PieChartSectionData> showingSections() {
    return List.generate(2, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 25.0 : 16.0;
      final radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
      return switch (i) {
        0 => PieChartSectionData(
          color: const Color.fromARGB(255, 214, 230, 238),
          value: widget.correctPer,
          title: '${widget.correctPer}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
        ),
        1 => PieChartSectionData(
          color: const Color.fromARGB(255, 150, 206, 248),
          value: widget.wrongPer,
          title: '${widget.wrongPer}%',
          radius: radius,
          titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          ),
        ),
        int() => throw UnimplementedError(),
      };
    });
  }

  Widget _buildIndicator({required Color color, required String title}) {
    return Row(
      spacing: 5,
      children: [
        Container(width: 20, height: 20, color: color),
        Text(title, style: TextStyle(color: Colors.white),),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AspectRatio(
          aspectRatio: 1.1,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 10,
              centerSpaceRadius: 35,
              sections: showingSections(),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          spacing: 10,
          children: [
            _buildIndicator(
              color: const Color.fromARGB(255, 214, 230, 238),
              title: "Correct",
            ),
            _buildIndicator(
              color: const Color.fromARGB(255, 150, 206, 248),
              title: "Wrong",
            ),
            SizedBox(height: 10,)
          ],
        ),
      ],
    );
  }
}
