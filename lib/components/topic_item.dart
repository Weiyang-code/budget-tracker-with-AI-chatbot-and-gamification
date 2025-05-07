import 'package:flutter/material.dart';
import 'package:budgettracker/components/drawer.dart';
import 'package:budgettracker/services/models.dart';
import 'package:budgettracker/shared/progress_bar.dart';

class TopicItem extends StatelessWidget {
  final Topic topic;
  const TopicItem({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: topic.img,
      child: Card(
        color: Colors.grey[850],
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) => TopicScreen(topic: topic),
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                flex: 3,
                child: SizedBox(
                  child: Image.asset(
                    'assets/covers/${topic.img}',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10, right: 10),
                  child: Text(
                    topic.title,
                    style: const TextStyle(
                      height: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.fade,
                    softWrap: false,
                  ),
                ),
              ),
              Flexible(child: TopicProgress(topic: topic)),
            ],
          ),
        ),
      ),
    );
  }
}

class TopicScreen extends StatelessWidget {
  final Topic topic;
  const TopicScreen({super.key, required this.topic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        children: [
          Hero(
            tag: topic.img,
            child: Image.asset(
              'assets/covers/${topic.img}',
              width: MediaQuery.of(context).size.width,
            ),
          ),
          Text(
            topic.title,
            style: const TextStyle(
              height: 2,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          QuizList(topic: topic),
        ],
      ),
    );
  }
}
