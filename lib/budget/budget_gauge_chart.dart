import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class BudgetGaugeChart extends StatelessWidget {
  final double spent;
  final double limit;

  const BudgetGaugeChart({super.key, required this.spent, required this.limit});

  @override
  Widget build(BuildContext context) {
    double percentage = (spent / limit) * 100;

    Color gaugeColor;
    if (percentage < 50) {
      gaugeColor = Colors.green;
    } else if (percentage < 80) {
      gaugeColor = Colors.orange;
    } else {
      gaugeColor = Colors.red;
    }

    return SizedBox(
      height: 150,
      child: SfRadialGauge(
        axes: [
          RadialAxis(
            minimum: 0,
            maximum: 100,
            showLabels: false,
            showTicks: false,
            axisLineStyle: AxisLineStyle(
              thickness: 0.2,
              thicknessUnit: GaugeSizeUnit.factor,
              color: Colors.grey[850]!, // Deeper grey
            ),

            pointers: [
              RangePointer(
                value: percentage,
                width: 0.2,
                sizeUnit: GaugeSizeUnit.factor,
                color: gaugeColor,
              ),
            ],
            annotations: [
              GaugeAnnotation(
                widget: Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: gaugeColor,
                  ),
                ),
                angle: 90,
                positionFactor: 0.1,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
