import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0), // Increased top margin
      child: BottomNavigationBar(
        iconSize: 25.0, // Set icon size to 25
        items: const [
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.house),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.dollarSign),
            label: 'Transactions',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.circleUser),
            label: 'Profile',
          ),
        ],
        fixedColor: Colors.deepPurple[200],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ), // Make selected label bold
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ), // Make unselected label bold
        onTap: (int idx) {
          switch (idx) {
            case 0:
              Navigator.pushNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushNamed(context, '/transaction');
              break;
            case 2:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }
}
