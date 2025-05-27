import 'package:flutter/material.dart';
import 'package:budgettracker/services/models.dart';
import 'package:budgettracker/services/firestore.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Challenges'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
              Tab(text: 'Failed'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChallengeList(type: 'active'),
            ChallengeList(type: 'completed'),
            ChallengeList(type: 'failed'),
          ],
        ),
      ),
    );
  }
}

class ChallengeList extends StatelessWidget {
  final String type;
  const ChallengeList({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    Stream<List<Challenge>> challengeStream;

    switch (type) {
      case 'completed':
        challengeStream = FirestoreService().streamCompletedChallenges();
        break;
      case 'failed':
        challengeStream = FirestoreService().streamFailedChallenges();
        break;
      case 'active':
      default:
        challengeStream = FirestoreService().streamActiveChallenges();
        break;
    }

    String getEmptyMessage() {
      switch (type) {
        case 'completed':
          return 'No completed challenges.';
        case 'failed':
          return 'No failed challenges.';
        case 'active':
        default:
          return 'No active challenges.';
      }
    }

    return StreamBuilder<List<Challenge>>(
      stream: challengeStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getEmptyMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (type == 'active') ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Create a budget to access challenges.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, '/add_budget');
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Create Budget'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        backgroundColor: Colors.deepPurple,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }

        final challenges = snapshot.data!;

        return ListView.builder(
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            final daysLeft =
                challenge.endTime.difference(DateTime.now()).inDays;

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.flag, color: Colors.deepPurple),
                title: Text(challenge.title),
                subtitle: Text(
                  'Category: ${challenge.category}\n'
                  'Target: ${challenge.targetSpending.toStringAsFixed(2)}\n'
                  '${type == 'active' ? "Ends in: $daysLeft days" : "Ended"}',
                ),
                trailing:
                    type == 'failed'
                        ? const Icon(Icons.close, color: Colors.red)
                        : challenge.completed
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : const Icon(Icons.hourglass_top, color: Colors.orange),
              ),
            );
          },
        );
      },
    );
  }
}
