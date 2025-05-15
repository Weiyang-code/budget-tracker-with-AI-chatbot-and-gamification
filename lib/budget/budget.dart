import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:budgettracker/services/models.dart';
import 'package:intl/intl.dart';

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

            // Split budgets into active and past
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
                _buildBudgetList(activeBudgets),
                _buildBudgetList(pastBudgets),
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

  Widget _buildBudgetList(List<Budget> budgets) {
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
              budget.category,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Amount: ',
                        style: TextStyle(color: Colors.white),
                      ),
                      TextSpan(
                        text: '\$${_formatAmount(budget.amount)}',
                        style: const TextStyle(color: Colors.orange),
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
              ],
            ),
            onTap: () {
              // Optional: Navigate to budget details screen
            },
          ),
        );
      },
    );
  }
}
