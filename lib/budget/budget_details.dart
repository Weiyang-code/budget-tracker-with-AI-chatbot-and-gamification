import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/services/models.dart';
import 'package:intl/intl.dart';
import 'package:budgettracker/budget/budget_gauge_chart.dart';

class BudgetDetailsScreen extends StatefulWidget {
  final Budget? budget;

  const BudgetDetailsScreen({super.key, this.budget});

  @override
  State<BudgetDetailsScreen> createState() => _BudgetDetailsScreenState();
}

class _BudgetDetailsScreenState extends State<BudgetDetailsScreen> {
  Budget? selectedBudget;
  String? selectedBudgetId;

  @override
  void initState() {
    super.initState();
    if (widget.budget != null) {
      selectedBudget = widget.budget;
      selectedBudgetId = widget.budget!.id;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM'); // Example: 1 May

    return Scaffold(
      appBar: AppBar(title: const Text('Budget Details')),
      body: StreamBuilder<List<Budget>>(
        stream: FirestoreService().streamAllBudgets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final budgets = snapshot.data ?? [];
          if (budgets.isEmpty) {
            return const Center(child: Text('No budgets found'));
          }

          selectedBudgetId ??= budgets.first.id;
          selectedBudget ??= budgets.firstWhere(
            (b) => b.id == selectedBudgetId,
          );

          final totalSpent = selectedBudget!.spending;
          final limit = selectedBudget!.amount;
          final startDate = selectedBudget!.startTime.toDate();
          final endDate = selectedBudget!.endTime.toDate();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                // Dropdown menu OUTSIDE the card
                DropdownButton<String>(
                  isExpanded: true,
                  value: selectedBudgetId,
                  items:
                      budgets
                          .map(
                            (budget) => DropdownMenuItem<String>(
                              value: budget.id,
                              child: Text(budget.category),
                            ),
                          )
                          .toList(),
                  onChanged: (budgetId) {
                    setState(() {
                      selectedBudgetId = budgetId;
                      selectedBudget = budgets.firstWhere(
                        (b) => b.id == budgetId,
                      );
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Budget details inside a Card
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 3,
                    vertical: 6,
                  ),
                  child: Card(
                    color: Colors.grey[900],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 16,
                      ),

                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (selectedBudget != null)
                            BudgetGaugeChart(
                              spent: selectedBudget!.spending,
                              limit: selectedBudget!.amount,
                            ),
                          const SizedBox(height: 24),

                          // Budget info
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                NumberFormat.compactCurrency(
                                  symbol: '\$',
                                  decimalDigits: 0,
                                ).format(totalSpent),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total Spent',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                NumberFormat.compactCurrency(
                                  symbol: '\$',
                                  decimalDigits: 0,
                                ).format(limit),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Limit',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Budget Period',
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
