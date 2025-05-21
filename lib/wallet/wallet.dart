import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/services/models.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';
import 'package:budgettracker/transaction/history.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  String _getCurrencySymbol(String currencyCode) {
    try {
      return CurrencyService().findByCode(currencyCode)?.symbol ?? currencyCode;
    } catch (_) {
      return currencyCode;
    }
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
                    onPressed:
                        () => Navigator.pushNamed(context, '/add_wallet'),
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
              final currencySymbol = _getCurrencySymbol(wallet.currency);

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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 26,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Type: ${wallet.type.toLowerCase()}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                          children: [
                            const TextSpan(text: 'Balance: '),
                            TextSpan(
                              text: currencySymbol,
                              style: const TextStyle(color: Colors.green),
                            ),
                            TextSpan(
                              text: NumberFormat.currency(
                                symbol: '',
                                decimalDigits: 2,
                              ).format(wallet.balance),
                              style: const TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Currency: ${wallet.currency} ($currencySymbol)',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryScreen(wallet: wallet),
                      ),
                    );
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Delete Wallet'),
                              content: const Text(
                                'Are you sure you want to delete this wallet?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed:
                                      () => Navigator.of(context).pop(true),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        await FirestoreService().deleteWallet(wallet.id);
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/add_wallet'),
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }
}
