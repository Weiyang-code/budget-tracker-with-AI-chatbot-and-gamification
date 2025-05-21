import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:intl/intl.dart';
import 'package:currency_picker/currency_picker.dart';

class WalletCard extends StatelessWidget {
  final Currency selectedCurrency;
  final void Function(Currency) onCurrencyChanged;

  const WalletCard({
    super.key,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: FirestoreService().streamTotalBalance(selectedCurrency.code),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Error loading wallet data',
              style: TextStyle(color: Colors.red),
            ),
          );
        }

        double total = snapshot.data ?? 0.0;
        String formattedBalance = NumberFormat.currency(
          locale: 'en_US',
          symbol: selectedCurrency.symbol,
        ).format(total);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: Card(
              color: Colors.grey[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'My Wallets',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/wallet');
                          },
                          child: Text(
                            'See all',
                            style: TextStyle(
                              color: Colors.green.shade400,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.grey),
                    const SizedBox(height: 12),

                    // Balance display
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Cash',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          formattedBalance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Currency picker
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        InkWell(
                          onTap: () {
                            showCurrencyPicker(
                              context: context,
                              theme: CurrencyPickerThemeData(
                                flagSize: 25,
                                titleTextStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                                subtitleTextStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                bottomSheetHeight: 500,
                                backgroundColor: Colors.grey[870],
                              ),
                              showFlag: true,
                              showCurrencyName: true,
                              showCurrencyCode: true,
                              onSelect: (Currency currency) {
                                onCurrencyChanged(currency); // notify parent
                              },
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.green,
                                  size: 25,
                                ),
                                Text(
                                  selectedCurrency.code,
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
