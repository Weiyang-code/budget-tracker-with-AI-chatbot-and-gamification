import 'package:flutter/material.dart';
import 'package:budgettracker/services/firestore.dart';

class UserInfoScreen extends StatelessWidget {
  UserInfoScreen({super.key});

  final nameController = TextEditingController();
  final ageController = TextEditingController();

  final TextEditingController customGoalController = TextEditingController();
  final TextEditingController customEmploymentController =
      TextEditingController();
  final TextEditingController customIncomeController = TextEditingController();

  final ValueNotifier<String?> employmentStatus = ValueNotifier<String?>(null);
  final ValueNotifier<String?> financialGoal = ValueNotifier<String?>(null);
  final ValueNotifier<String?> monthlyIncome = ValueNotifier<String?>(null);

  final List<String> employmentOptions = [
    'Employed',
    'Unemployed',
    'Student',
    'Self-employed',
    'Retired',
    'Other',
  ];

  final List<String> financialGoalOptions = [
    'Tracking income and expenses',
    'Manage debts and loans',
    'Reduce spending',
    'Invest for retirement',
    'Save for a big purchase',
    'Other',
  ];

  final List<String> incomeOptions = [
    'Less than \$1,000',
    '\$1,000 - \$3,000',
    '\$3,000 - \$5,000',
    '\$5,000 - \$10,000',
    'More than \$10,000',
    'Other',
  ];

  void _handleContinue(BuildContext context) async {
    final name = nameController.text;
    final age = ageController.text;
    final status =
        employmentStatus.value == 'Other'
            ? customEmploymentController.text
            : employmentStatus.value;
    final goal =
        financialGoal.value == 'Other'
            ? customGoalController.text
            : financialGoal.value;
    final income =
        monthlyIncome.value == 'Other'
            ? customIncomeController.text
            : monthlyIncome.value;

    if (name.isEmpty ||
        age.isEmpty ||
        status == null ||
        status.isEmpty ||
        goal == null ||
        goal.isEmpty ||
        income == null ||
        income.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    if (int.tryParse(age) == null || int.parse(age) <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a valid age')));
      return;
    }

    await FirestoreService().saveUserInfo(
      name: name,
      age: age,
      employmentStatus: status,
      financialGoal: goal,
      monthlyIncome: income,
      context: context,
    );
  }

  Widget _buildDropdown({
    required String label,
    required ValueNotifier<String?> notifier,
    required List<String> options,
    Widget? customChild,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 8),
        ValueListenableBuilder<String?>(
          valueListenable: notifier,
          builder: (context, value, _) {
            return DropdownButtonFormField<String>(
              value: value,
              items:
                  options
                      .map(
                        (option) => DropdownMenuItem(
                          value: option,
                          child: Text(option),
                        ),
                      )
                      .toList(),
              onChanged: (newValue) => notifier.value = newValue,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
            );
          },
        ),
        if (customChild != null) ...[const SizedBox(height: 8), customChild],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tell us more about yourself"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Age"),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: "What is your employment status?",
                notifier: employmentStatus,
                options: employmentOptions,
                customChild: ValueListenableBuilder<String?>(
                  valueListenable: employmentStatus,
                  builder: (context, value, _) {
                    if (value == 'Other') {
                      return TextField(
                        controller: customEmploymentController,
                        decoration: const InputDecoration(
                          labelText: 'Please specify your employment status',
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: "What is your financial goal?",
                notifier: financialGoal,
                options: financialGoalOptions,
                customChild: ValueListenableBuilder<String?>(
                  valueListenable: financialGoal,
                  builder: (context, value, _) {
                    if (value == 'Other') {
                      return TextField(
                        controller: customGoalController,
                        decoration: const InputDecoration(
                          labelText: 'Please specify your goal',
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                label: "What is your average monthly income?",
                notifier: monthlyIncome,
                options: incomeOptions,
                customChild: ValueListenableBuilder<String?>(
                  valueListenable: monthlyIncome,
                  builder: (context, value, _) {
                    if (value == 'Other') {
                      return TextField(
                        controller: customIncomeController,
                        decoration: const InputDecoration(
                          labelText: 'Please specify your monthly income',
                          labelStyle: TextStyle(color: Colors.grey),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: () => _handleContinue(context),
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
