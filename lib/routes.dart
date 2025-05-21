import 'package:budgettracker/transaction/transaction.dart';
import 'package:budgettracker/profile/profile.dart';
import 'package:budgettracker/login/login.dart';
import 'package:budgettracker/dashboard/dashboard.dart';
import 'package:budgettracker/home/home.dart';
import 'package:budgettracker/register/register.dart';
import 'package:budgettracker/challenges/challenges.dart';
import 'package:budgettracker/chatbot/chatbot.dart';
import 'package:budgettracker/transaction/history.dart';
import 'package:budgettracker/budget/budget.dart';
import 'package:budgettracker/wallet/wallet.dart';
import 'package:budgettracker/wallet/add_wallet.dart';
import 'package:budgettracker/budget/add_budget.dart';
import 'package:budgettracker/budget/budget_details.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => LoginScreen(),
  '/dashboard': (context) => DashboardScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/transaction': (context) => const TransactionScreen(),
  '/register': (context) => RegisterScreen(),
  '/challenges': (context) => const ChallengesScreen(),
  '/chatbot': (context) => const ChatbotScreen(),
  '/history': (context) => const HistoryScreen(),
  '/budget': (context) => const BudgetScreen(),
  '/wallet': (context) => const WalletScreen(),
  '/add_wallet': (context) => const AddWalletScreen(),
  '/add_budget': (context) => const AddBudgetScreen(),
  '/budget_details': (context) => const BudgetDetailsScreen(),
};
