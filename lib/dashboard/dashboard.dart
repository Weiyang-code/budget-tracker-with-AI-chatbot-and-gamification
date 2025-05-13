import 'package:budgettracker/components/text_field.dart';
import 'package:flutter/material.dart';
import 'package:budgettracker/shared/bottom_navbar.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/shared/navigation_drawer.dart';
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/dashboard/card.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var user = AuthService().user;
    return Scaffold(
      appBar: AppBar(),
      drawer: SideDrawer(
        name: user?.displayName ?? 'Guest',
        photoURL: user?.photoURL,
      ),
      bottomNavigationBar: BottomNavBar(),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              // WalletCard placed at the top
              WalletCard(),
            ],
          ),
        ),
      ),
    );
  }
}
