import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/services/models.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  final Wallet? wallet;

  const HistoryScreen({super.key, this.wallet});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Wallet? selectedWallet;
  String? selectedWalletId;

  @override
  void initState() {
    super.initState();
    // If a wallet was passed, use it
    if (widget.wallet != null) {
      selectedWallet = widget.wallet;
      selectedWalletId = widget.wallet!.id;
    }
  }

  String _getCurrencySymbol(String currencyCode) {
    try {
      return CurrencyService().findByCode(currencyCode)?.symbol ?? currencyCode;
    } catch (_) {
      return currencyCode;
    }
  }

  String _formatDate(firestore.Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: StreamBuilder<List<Wallet>>(
        stream: FirestoreService().streamAllWallets(),
        builder: (context, walletSnapshot) {
          if (walletSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (walletSnapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final wallets = walletSnapshot.data ?? [];

          if (wallets.isEmpty) {
            return const Center(child: Text('No wallets found'));
          }

          // Set default selected wallet ID if not set
          selectedWalletId ??= wallets.first.id;
          selectedWallet ??= wallets.firstWhere(
            (w) => w.id == selectedWalletId,
          );

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedWalletId,
                  items:
                      wallets.map((wallet) {
                        return DropdownMenuItem<String>(
                          value: wallet.id,
                          child: Text(wallet.name),
                        );
                      }).toList(),
                  onChanged: (walletId) {
                    setState(() {
                      selectedWalletId = walletId;
                      selectedWallet = wallets.firstWhere(
                        (w) => w.id == walletId,
                      );
                    });
                  },
                ),
              ),

              // Your existing Expanded widget with transactions list
              Expanded(
                child:
                    selectedWallet == null
                        ? const Center(child: Text('Select a wallet'))
                        : StreamBuilder<List<Transaction>>(
                          stream: FirestoreService().streamTransactions(
                            walletId: selectedWallet!.id,
                          ),
                          builder: (context, txSnapshot) {
                            if (txSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (txSnapshot.hasError) {
                              return const Center(
                                child: Text('Something went wrong'),
                              );
                            }

                            final transactions = txSnapshot.data ?? [];

                            if (transactions.isEmpty) {
                              return const Center(
                                child: Text('No transactions yet'),
                              );
                            }

                            final currencySymbol = _getCurrencySymbol(
                              selectedWallet!.currency,
                            );

                            return ListView.builder(
                              padding: const EdgeInsets.all(8),
                              itemCount: transactions.length,
                              itemBuilder: (context, index) {
                                final transaction = transactions[index];

                                return Card(
                                  color: Colors.grey[900],
                                  elevation: 4,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 6,
                                    horizontal: 4,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 10,
                                    ),
                                    title: Text(
                                      transaction.type == 'income'
                                          ? 'Income'
                                          : 'Expense', // switched to title
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        color:
                                            transaction.type == 'income'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _formatDate(transaction.date),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        if (transaction.category.isNotEmpty)
                                          Text(
                                            transaction
                                                .category, // moved to subtitle
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        if (transaction.note.isNotEmpty)
                                          Text(
                                            'Note: ${transaction.note}', // Show the note with label
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                      ],
                                    ),
                                    trailing: Text(
                                      '${transaction.type == 'expense' ? '-' : '+'}$currencySymbol${transaction.amount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color:
                                            transaction.type == 'income'
                                                ? Colors.green
                                                : Colors.red,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
