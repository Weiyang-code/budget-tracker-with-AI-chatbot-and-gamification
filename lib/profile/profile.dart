import 'package:flutter/material.dart';
import 'package:budgettracker/services/auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;

    if (user != null) {
      return Scaffold(
        appBar: AppBar(title: Text("Profile")),
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                margin: const EdgeInsets.only(top: 50),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(
                      user.photoURL ??
                          'https://www.gravatar.com/avatar/placeholder',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 50),
              Text(user.displayName ?? "No name"),
              Text(user.email ?? "No email"),
              SizedBox(height: 100),
              SizedBox(height: 30),
              Text(
                'Quizzes Completed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 150),
              ElevatedButton(
                onPressed: () async {
                  await AuthService().signOut();
                  // ignore: use_build_context_synchronously
                  Navigator.of(
                    context,
                  ).pushNamedAndRemoveUntil('/', (route) => false);
                },
                child: Text("Signout"),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(child: Text("No user found"));
    }
  }
}
