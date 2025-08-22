import 'package:flutter/material.dart';
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/services/avatar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: FutureBuilder(
        future: FirestoreService().getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            var user = AuthService().user;
            var userData = snapshot.data as Map<String, dynamic>;

            return StreamBuilder<Map<String, int>>(
              stream: AvatarService().streamAvatarData(),
              builder: (context, avatarSnapshot) {
                if (!avatarSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                var avatarLevel = avatarSnapshot.data!['avatarLevel']!;
                var completed = avatarSnapshot.data!['completedChallenges']!;

                int challengesThisLevel;
                double progress;
                bool isMaxLevel = avatarLevel >= 10;

                if (isMaxLevel) {
                  challengesThisLevel = 3;
                  progress = 1.0;
                } else {
                  challengesThisLevel = completed % 3;
                  progress = challengesThisLevel / 3.0;
                }

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 30),

                      // Profile Header
                      Container(
                        width: double.infinity,
                        color: const Color(0xFF1A1A1A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: NetworkImage(
                                user?.photoURL ??
                                    'https://www.gravatar.com/avatar/placeholder',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userData['name'] ?? "No name",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userData['email'] ?? "No email",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      // Divider and Title
                      Divider(
                        color: Colors.grey[700],
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      const Text(
                        "Virtual Avatar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      // Avatar Section
                      Container(
                        width: double.infinity,
                        color: const Color(0xFF1A1A1A),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 24,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'lib/images/avatars/avatar_level_$avatarLevel.png',
                              height: 100,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Level $avatarLevel",
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              isMaxLevel
                                  ? "Max level reached"
                                  : "$challengesThisLevel/3 challenges to next level",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.center,
                              child: SizedBox(
                                width:
                                    300, // Set the desired horizontal width here
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 8,
                                  backgroundColor: Colors.grey[800],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    isMaxLevel
                                        ? Colors.amber
                                        : Colors.greenAccent,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Divider(
                        color: Colors.grey[700],
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      const SizedBox(height: 40),

                      // Sign Out
                      Center(
                        child: ElevatedButton(
                          onPressed: () async {
                            await AuthService().signOut();
                            Navigator.of(
                              context,
                            ).pushNamedAndRemoveUntil('/', (route) => false);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Sign Out"),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
