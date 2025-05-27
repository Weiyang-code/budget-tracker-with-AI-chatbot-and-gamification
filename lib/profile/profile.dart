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
      body: Center(
        child: FutureBuilder(
          future: Future.wait([
            FirestoreService().getUserData(),
            AvatarService().getAvatarLevel(),
          ]),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              var user = AuthService().user;
              var userData = snapshot.data![0] as Map<String, dynamic>;
              var avatarLevel = snapshot.data![1] as int;

              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user?.photoURL ??
                          'https://www.gravatar.com/avatar/placeholder',
                    ),
                  ),
                  Image.asset(
                    'lib/images/avatars/avatar_level_$avatarLevel.png',
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Level $avatarLevel",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userData['name'] ?? "No name",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData['email'] ?? "No email",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService().signOut();
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    child: const Text("Signout"),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
