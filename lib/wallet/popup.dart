import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/components/text_field.dart'; // Adjust path as needed

class Popup extends StatelessWidget {
  const Popup({super.key});

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 12,
      ), // Reduced padding
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Text(
            "Create Wallet",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // Row for the Wallet Name with label
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align vertically
            children: [
              const Text(
                "Name: ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                width: 15,
              ), // Add space between label and text field
              Expanded(
                child: MyTextField(
                  controller: nameController,
                  hintText: "Enter Wallet Name",
                  obscureText: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8), // Reduced space here
          // Row for the Initial Balance with label
          Row(
            crossAxisAlignment: CrossAxisAlignment.center, // Align vertically
            children: [
              const Text(
                "Balance: ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ), // Add space between label and text field
              Expanded(
                child: MyTextField(
                  controller: balanceController,
                  hintText: "Enter Initial Balance",
                  obscureText: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16), // Reduced space here

          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final balance = double.tryParse(balanceController.text) ?? 0;

              if (name.isNotEmpty) {
                FirestoreService().createWallet(name: name, balance: balance);
                Navigator.pop(context); // Close the dialog after creation
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
