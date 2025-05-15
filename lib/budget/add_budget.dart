import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_picker_plus/date_picker_plus.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  String? selectedCategory;
  DateTimeRange? selectedRange;

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

  String _formatRange(DateTimeRange? range) {
    if (range == null) return 'Select date range';
    return '${range.start.day}/${range.start.month}/${range.start.year} - '
        '${range.end.day}/${range.end.month}/${range.end.year}';
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final pickedRange = await showRangePickerDialog(
      context: context,
      initialDate: DateTime.now(),
      minDate: DateTime(2020, 1, 1),
      maxDate: DateTime(2100, 12, 31),
      selectedRange:
          selectedRange ??
          DateTimeRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
      width: 300,
      height: 300,
      initialPickerType: PickerType.days,
      highlightColor: Colors.redAccent,
      centerLeadingDate: true,
    );

    if (pickedRange != null) {
      setState(() {
        selectedRange = pickedRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Budget'),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.check),
            onPressed: () async {
              if (formKey.currentState!.validate() && selectedRange != null) {
                await FirestoreService().createBudget(
                  category: selectedCategory!,
                  amount: double.tryParse(amountController.text.trim()) ?? 0.0,
                  startTime: selectedRange!.start,
                  endTime: selectedRange!.end,
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
                  // Category Dropdown
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      labelStyle: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    dropdownColor: Colors.grey[850],
                    style: const TextStyle(color: Colors.grey),
                    items:
                        categories
                            .map(
                              (cat) => DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat),
                              ),
                            )
                            .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    validator:
                        (value) => value == null ? 'Select a category' : null,
                  ),
                  const SizedBox(height: 16),

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
                  const SizedBox(height: 24),

                  // Date Range Picker
                  const Text(
                    'Budget Period',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  ListTile(
                    title: Text(
                      _formatRange(selectedRange),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    trailing: const Icon(FontAwesomeIcons.calendar),
                    onTap: () => _pickDateRange(context),
                  ),
                  const Divider(color: Colors.grey, thickness: 1, height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
