import 'package:flutter/material.dart';
import 'package:budgettracker/shared/bottom_navbar.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/shared/shared.dart';
import 'package:budgettracker/components/topic_item.dart';
import 'package:budgettracker/components/drawer.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: FirestoreService().getTopics(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingScreen();
        } else if (snapshot.hasError) {
          return Center(
            child: ErrorMessage(message: snapshot.error.toString()),
          );
        } else if (snapshot.hasData) {
          var topics = snapshot.data!;

          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.deepPurple,
              title: const Text('Topics'),
            ),
            drawer: TopicDrawer(topics: topics),
            body: GridView.count(
              primary: false,
              padding: const EdgeInsets.all(20),
              crossAxisSpacing: 10,
              crossAxisCount: 2,
              children: topics.map((topic) => TopicItem(topic: topic)).toList(),
            ),
            bottomNavigationBar: BottomNavBar(),
          );
        } else {
          return const Text('No topics found in Firestore. Check database.');
        }
      },
    );
  }
}
