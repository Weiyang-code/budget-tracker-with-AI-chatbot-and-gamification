import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:budgettracker/services/firestore.dart';

class DailyBarChart extends StatelessWidget {
  final String targetCurrency;
  final String type; // "income" or "expense"

  const DailyBarChart({
    required this.targetCurrency,
    required this.type,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, double>>(
      stream: FirestoreService().streamConvertedDailyTotals(
        type,
        targetCurrency,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Text("No data available."),
            ),
          );
        }

        final now = DateTime.now();
        final xLabels = <String>[];
        final dailyData = <BarChartGroupData>[];

        double maxY = 0;

        // Ensure correct order for the last 7 days
        for (int i = 0; i < 7; i++) {
          final date = now.subtract(Duration(days: 6 - i));
          final dayKey = DateFormat('E').format(date); // "Mon", "Tue", etc.
          final amount = snapshot.data![dayKey] ?? 0.0;

          maxY = amount > maxY ? amount : maxY;

          dailyData.add(
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: amount,
                  color: Colors.deepPurple[200],
                  width: 16,
                  borderRadius: BorderRadius.circular(6),
                ),
              ],
            ),
          );

          xLabels.add(dayKey);
        }

        // Determine a clean interval based on maxY
        final interval = (maxY / 5).clamp(10, 50);

        return Card(
          color: Colors.grey[900],
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                SizedBox(
                  height: 250,
                  child: BarChart(
                    BarChartData(
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor:
                              (BarChartGroupData group) =>
                                  Colors.deepPurple[300]!,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              NumberFormat.simpleCurrency(
                                name: targetCurrency,
                              ).format(rod.toY),
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                        ),
                      ),

                      barGroups: dailyData,
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval.toDouble(),
                            getTitlesWidget: (value, meta) {
                              final formatted = NumberFormat.compact().format(
                                value,
                              );
                              return Text(
                                formatted,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              );
                            },
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < xLabels.length) {
                                return Text(
                                  xLabels[index],
                                  style: const TextStyle(color: Colors.white),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        drawHorizontalLine: true,
                        horizontalInterval: interval.toDouble(),
                        verticalInterval: 1,
                        getDrawingHorizontalLine:
                            (value) =>
                                FlLine(color: Colors.white24, strokeWidth: 1),
                        getDrawingVerticalLine:
                            (value) =>
                                FlLine(color: Colors.white10, strokeWidth: 1),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
