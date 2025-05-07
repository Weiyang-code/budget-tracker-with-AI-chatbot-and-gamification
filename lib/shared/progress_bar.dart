import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:budgettracker/services/models.dart';

class AnimatedProgressBar extends StatelessWidget {
  final double value;
  final double height;
  const AnimatedProgressBar({
    super.key,
    required this.height,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints box) {
        return Container(
          padding: const EdgeInsets.all(10),
          width: box.maxWidth,
          child: Stack(
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.all(Radius.circular(height)),
                ),
              ),
              AnimatedContainer(
                duration: Duration(milliseconds: 800),
                curve: Curves.easeOutCubic,
                height: height,
                width: box.maxWidth * floor(value),
                decoration: BoxDecoration(
                  color: colorGen(value),
                  borderRadius: BorderRadius.all(Radius.circular(height)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  floor(double value, [min = 0.0]) {
    return value.sign <= min ? min : value;
  }

  colorGen(double value) {
    int rbg = (value * 255).toInt();
    return Colors.deepOrange.withGreen(rbg).withRed(255 - rbg);
  }
}

class TopicProgress extends StatelessWidget {
  final Topic topic;

  const TopicProgress({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    Report report = Provider.of<Report>(context);
    return Row(
      children: [
        _progressCount(report, topic),
        Expanded(
          child: AnimatedProgressBar(
            height: 8,
            value: _calculateProgress(topic, report),
          ),
        ),
      ],
    );
  }

  Widget _progressCount(Report report, Topic topic) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        '${report.topics[topic.id]?.length ?? 0} / ${topic.quizzes.length}',
        style: const TextStyle(fontSize: 10, color: Colors.grey),
      ),
    );
  }

  double _calculateProgress(Topic topic, Report report) {
    try {
      int totalQuizzes = topic.quizzes.length;
      int completedQuizzes = report.topics[topic.id].length;
      return completedQuizzes / totalQuizzes;
    } catch (err) {
      return 0.0;
    }
  }
}
