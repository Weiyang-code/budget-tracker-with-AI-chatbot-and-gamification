import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:budgettracker/services/firestore.dart';

class CategoryPieChart extends StatelessWidget {
  final String targetCurrency;

  const CategoryPieChart({super.key, required this.targetCurrency});

  // Define a list of distinct colors to cycle through
  static List<Color> sectionColors = [
    Colors.pinkAccent.shade100,
    Colors.purpleAccent.shade100,
    Colors.blueAccent.shade100,
    Colors.cyanAccent.shade100,
    Colors.tealAccent.shade100,
    Colors.greenAccent.shade100,
    Colors.limeAccent.shade100,
    Colors.yellowAccent.shade100,
    Colors.orangeAccent.shade100,
    Colors.redAccent.shade100,
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: FirestoreService().streamConvertedCategoryTotals(targetCurrency),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final byCategory = snapshot.data!;

        if (byCategory.isEmpty) {
          return const SizedBox(
            height: 200,
            child: Center(child: Text('No spending yet')),
          );
        }

        final sections = <PieChartSectionData>[];

        int colorIndex = 0;
        for (final entry in byCategory.entries) {
          sections.add(
            PieChartSectionData(
              value: entry.value,
              title: entry.key,
              radius: 55,
              color: sectionColors[colorIndex % sectionColors.length],
              titleStyle: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
          colorIndex++;
        }

        return Card(
          color: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: sections,
              ),
            ),
          ),
        );
      },
    );
  }
}
