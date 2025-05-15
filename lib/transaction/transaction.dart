import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/services/models.dart' as models;
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  final noteController = TextEditingController(); // <-- Added
  String? selectedCategory;
  String selectedType = 'expense';
  DateTime? selectedDate;
  String? selectedWalletId;

  final List<String> categories = [
    'Food',
    'Transport',
    'Utilities',
    'Entertainment',
    'Healthcare',
    'Shopping',
    'Education',
    'Others',
  ];

  String _formatDate(DateTime? date) {
    if (date == null) return 'Select a date';
    return DateFormat('MMM d, yyyy').format(date);
  }

  Future<void> _pickDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.check),
            onPressed: () async {
              if (formKey.currentState!.validate() &&
                  selectedDate != null &&
                  selectedWalletId != null &&
                  (selectedType == 'income' || selectedCategory != null)) {
                final txn = models.Transaction(
                  category: selectedCategory ?? '',
                  amount: double.tryParse(amountController.text.trim()) ?? 0.0,
                  date: Timestamp.fromDate(selectedDate!),
                  type: selectedType,
                );

                await FirestoreService().addTransaction(
                  walletId: selectedWalletId!,
                  transaction: txn,
                  note: noteController.text.trim(), // <-- Pass note
                );

                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<models.Wallet>>(
        stream: FirestoreService().streamAllWallets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No wallets found.'));
          }

          final wallets = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: Colors.grey[900],
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wallet Dropdown
                      DropdownButtonFormField<String>(
                        value: selectedWalletId,
                        decoration: const InputDecoration(
                          labelText: 'Select Wallet',
                          labelStyle: TextStyle(color: Colors.white),
                        ),
                        dropdownColor: Colors.grey[850],
                        style: const TextStyle(color: Colors.grey),
                        items:
                            wallets.map((wallet) {
                              return DropdownMenuItem(
                                value: wallet.id,
                                child: Text(
                                  '${wallet.name} (${wallet.currency})',
                                ),
                              );
                            }).toList(),
                        onChanged: (id) {
                          setState(() {
                            selectedWalletId = id;
                          });
                        },
                        validator:
                            (value) =>
                                value == null ? 'Please select a wallet' : null,
                      ),
                      const SizedBox(height: 16),

                      // Transaction Type Toggle
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Type',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          ToggleButtons(
                            isSelected: [
                              selectedType == 'expense',
                              selectedType == 'income',
                            ],
                            onPressed: (index) {
                              setState(() {
                                selectedType =
                                    index == 0 ? 'expense' : 'income';
                                if (selectedType == 'income') {
                                  selectedCategory = null;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            selectedColor: Colors.white,
                            fillColor: Colors.redAccent,
                            color: Colors.grey,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Expense'),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: Text('Income'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Show Category only for expenses
                      if (selectedType == 'expense') ...[
                        DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                            ),
                          ),
                          style: const TextStyle(color: Colors.grey),
                          items:
                              categories.map((cat) {
                                return DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat),
                                );
                              }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                          validator: (value) {
                            if (selectedType == 'expense' && value == null) {
                              return 'Select a category';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Amount
                      const Text(
                        'Amount',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: UnderlineInputBorder(),
                          hintText: 'Enter amount',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Enter amount';
                          }
                          if (double.tryParse(value.trim()) == null) {
                            return 'Invalid number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Note field
                      const Text(
                        'Note',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      TextFormField(
                        controller: noteController,
                        decoration: const InputDecoration(
                          isDense: true,
                          border: UnderlineInputBorder(),
                          hintText: 'Optional note or description',
                          hintStyle: TextStyle(color: Colors.grey),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),

                      // Date Picker
                      const Text(
                        'Date',
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      ListTile(
                        title: Text(
                          _formatDate(selectedDate),
                          style: const TextStyle(color: Colors.grey),
                        ),
                        trailing: const Icon(FontAwesomeIcons.calendar),
                        onTap: () => _pickDate(context),
                      ),
                      const Divider(
                        color: Colors.grey,
                        thickness: 1,
                        height: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
