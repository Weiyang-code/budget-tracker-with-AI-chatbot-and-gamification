import 'package:flutter/material.dart';
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/services/firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Center(
        child: FutureBuilder(
          future: FirestoreService().getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else if (!snapshot.hasData || snapshot.data == null) {
              return const Text("No user found");
            } else {
              var user = AuthService().user;
              var userData = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user?.photoURL ??
                          'https://www.gravatar.com/avatar/placeholder',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userData?['name'] ?? "No name",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    userData?['email'] ?? "No email",
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService().signOut();
                      // ignore: use_build_context_synchronously
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
