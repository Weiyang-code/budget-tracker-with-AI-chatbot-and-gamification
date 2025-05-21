import 'package:budgettracker/budget/budget_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/services/models.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return DateFormat('MMM d, yyyy').format(date);
  }

  String _formatAmount(double amount) {
    return NumberFormat.currency(symbol: '', decimalDigits: 2).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Budgets'),
          bottom: const TabBar(
            labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            tabs: [Tab(text: 'Active'), Tab(text: 'Past')],
          ),
        ),
        body: StreamBuilder<List<Budget>>(
          stream: FirestoreService().streamAllBudgets(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            final allBudgets = snapshot.data ?? [];

            final activeBudgets =
                allBudgets
                    .where((b) => b.endTime.toDate().isAfter(now))
                    .toList();

            final pastBudgets =
                allBudgets
                    .where((b) => b.endTime.toDate().isBefore(now))
                    .toList();

            return TabBarView(
              children: [
                _buildBudgetList(context, activeBudgets),
                _buildBudgetList(context, pastBudgets),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, '/add_budget'),
          child: const Icon(Icons.add, size: 30),
        ),
      ),
    );
  }

  Widget _buildBudgetList(BuildContext context, List<Budget> budgets) {
    if (budgets.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No budgets found'),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: budgets.length,
      itemBuilder: (context, index) {
        final budget = budgets[index];
        final percent = (budget.spending / budget.amount).clamp(0.0, 1.0);

        Color progressColor;
        if (percent < 0.5) {
          progressColor = Colors.green;
        } else if (percent < 0.8) {
          progressColor = Colors.orange;
        } else {
          progressColor = Colors.red;
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BudgetDetailsScreen(budget: budget),
              ),
            );
          },
          child: Card(
            color: Colors.grey[900],
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header row with category and delete button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        budget.category,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                          color: Colors.white,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Delete Budget'),
                                  content: const Text(
                                    'Are you sure you want to delete this budget?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () =>
                                              Navigator.of(context).pop(false),
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
                            await FirestoreService().deleteBudget(budget.id);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Limit: ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: '\$${_formatAmount(budget.amount)}',
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(
                          text: 'Spent: ',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: '\$${_formatAmount(budget.spending)}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Start: ${_formatDate(budget.startTime)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'End: ${_formatDate(budget.endTime)}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: LinearPercentIndicator(
                          lineHeight: 8.0,
                          percent: percent,
                          backgroundColor: Colors.black,
                          progressColor: progressColor,
                          barRadius: const Radius.circular(10),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${(percent * 100).toStringAsFixed(1)}%',
                        style: TextStyle(color: progressColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
