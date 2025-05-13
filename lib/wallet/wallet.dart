import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/services/models.dart';
import 'package:budgettracker/wallet/popup.dart'; // Import the new popup

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  void _showCreateWalletPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Popup(), // Your custom popup widget
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
      body: StreamBuilder<List<Wallet>>(
        stream: FirestoreService().streamAllWallets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final wallets = snapshot.data ?? [];

          if (wallets.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No wallets found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showCreateWalletPopup(context),
                    child: const Text('Create Wallet'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              return Card(
                color: Colors.grey[900],
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  title: Text(
                    wallet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Balance: \$${wallet.balance.toStringAsFixed(2)}',
                  ),
                  onTap: () {
                    // TODO: Navigate to wallet details if needed
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => _showCreateWalletPopup(context), // Open popup on button press
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
