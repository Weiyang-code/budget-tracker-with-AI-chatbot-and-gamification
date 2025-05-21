import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:budgettracker/services/firestore.dart';

class AddWalletScreen extends StatefulWidget {
  const AddWalletScreen({super.key});

  @override
  State<AddWalletScreen> createState() => _AddWalletScreenState();
}

class _AddWalletScreenState extends State<AddWalletScreen> {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final balanceController = TextEditingController();
  String selectedType = 'General';
  String? selectedCurrencyCode = 'MYR';
  String? selectedCurrencySymbol = 'RM';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Wallet'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.check),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                await FirestoreService().createWallet(
                  name: nameController.text.trim(),
                  balance: double.tryParse(balanceController.text.trim()) ?? 0,
                  type: selectedType,
                  currency: selectedCurrencyCode ?? 'MYR',
                );
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.grey[900],
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Wallet Name
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Wallet name'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter wallet name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Type
                  const Text(
                    'Type',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: const [
                      DropdownMenuItem(
                        value: 'General',
                        child: Text('General'),
                      ),
                      DropdownMenuItem(
                        value: 'Savings',
                        child: Text('Savings'),
                      ),
                      DropdownMenuItem(value: 'Credit', child: Text('Credit')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Initial Value
                  const Text(
                    'Initial value',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: balanceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      isDense: true,
                      border: UnderlineInputBorder(),
                      hintText: 'Enter amount',
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter balance';
                      }
                      if (double.tryParse(value.trim()) == null) {
                        return 'Invalid number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Currency
                  const Text(
                    'Currency',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      showCurrencyPicker(
                        context: context,
                        showFlag: true,
                        showCurrencyName: true,
                        showCurrencyCode: true,
                        onSelect: (Currency currency) {
                          setState(() {
                            selectedCurrencyCode = currency.code;
                            selectedCurrencySymbol = currency.symbol;
                          });
                        },
                      );
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: InputDecoration(
                          isDense: true,
                          border: const UnderlineInputBorder(),
                          hintText:
                              selectedCurrencyCode != null &&
                                      selectedCurrencySymbol != null
                                  ? '$selectedCurrencyCode ($selectedCurrencySymbol)'
                                  : 'Select Currency',
                          hintStyle: const TextStyle(color: Colors.grey),
                        ),
                        validator: (value) {
                          if (selectedCurrencyCode == null ||
                              selectedCurrencySymbol == null) {
                            return 'Select a currency';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
