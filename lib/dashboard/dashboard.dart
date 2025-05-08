import 'package:budgettracker/components/text_field.dart';
import 'package:flutter/material.dart';
import 'package:budgettracker/shared/bottom_navbar.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/shared/shared.dart';

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final TextEditingController nameController = TextEditingController();
  final TextEditingController balanceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text(
                "Create Wallet",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: nameController,
                hintText: "Wallet Name",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: balanceController,
                hintText: "Initial Balance",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  FirestoreService().createWallet(
                    name: nameController.text,
                    balance: int.parse(balanceController.text),
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BottomNavBar()),
                  );
                },
                child: const Text("Create Wallet"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
