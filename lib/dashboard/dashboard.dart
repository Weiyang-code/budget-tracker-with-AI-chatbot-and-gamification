import 'package:flutter/material.dart';
import 'package:budgettracker/shared/bottom_navbar.dart';
import 'package:budgettracker/shared/navigation_drawer.dart';
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/dashboard/card.dart';
import 'package:budgettracker/dashboard/pie_chart.dart';
import 'package:budgettracker/dashboard/bar_chart.dart';
import 'package:currency_picker/currency_picker.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Currency _selectedCurrency = CurrencyService().findByCode('USD')!;

  void _onCurrencyChanged(Currency newCurrency) {
    setState(() {
      _selectedCurrency = newCurrency;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().user;

    return Scaffold(
      appBar: AppBar(),
      drawer: SideDrawer(
        name: user?.displayName ?? 'Guest',
        photoURL: user?.photoURL,
      ),
      bottomNavigationBar: BottomNavBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              WalletCard(
                selectedCurrency: _selectedCurrency,
                onCurrencyChanged: _onCurrencyChanged,
              ),
              const SizedBox(height: 24),
              Text(
                'Spending by category (last 30 days)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              CategoryPieChart(targetCurrency: _selectedCurrency.code),
              const SizedBox(height: 32),
              Text(
                'Expenses in the last 7 days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DailyBarChart(
                type: 'expense',
                targetCurrency: _selectedCurrency.code,
              ),
              const SizedBox(height: 24),
              Text(
                'Income in the last 7 days',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DailyBarChart(
                type: 'income',
                targetCurrency: _selectedCurrency.code,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/chatbot'),
        child: const Icon(Icons.chat),
      ),
    );
  }
}
