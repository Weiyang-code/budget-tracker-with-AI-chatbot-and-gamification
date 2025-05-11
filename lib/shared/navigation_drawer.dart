import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:budgettracker/services/auth.dart';

class SideDrawer extends StatelessWidget {
  final String name;
  final String? photoURL;
  const SideDrawer({super.key, required this.name, this.photoURL});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.deepPurple[200]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    photoURL ?? 'https://www.gravatar.com/avatar/placeholder',
                  ),
                ),
                const SizedBox(height: 10),
                Text(name, style: TextStyle(color: Colors.white, fontSize: 24)),
              ],
            ),
          ),

          ListTile(
            leading: const Icon(FontAwesomeIcons.house),
            title: const Text('Home'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.history),
            title: const Text('History'),
            onTap: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.trophy),
            title: const Text('Challenges'),
            onTap: () {
              Navigator.pushNamed(context, '/challenges');
            },
          ),
          ListTile(
            leading: const Icon(FontAwesomeIcons.commentDots),
            title: const Text('ChatBot'),
            onTap: () {
              Navigator.pushNamed(context, '/chatbot');
            },
          ),

          ListTile(
            leading: Icon(FontAwesomeIcons.rightFromBracket),
            title: const Text('Log Out'),
            onTap: () async {
              await AuthService().signOut();
              // ignore: use_build_context_synchronously
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
