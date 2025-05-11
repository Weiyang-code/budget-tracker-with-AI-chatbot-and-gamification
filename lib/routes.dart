import 'package:budgettracker/transaction/transaction.dart';
import 'package:budgettracker/profile/profile.dart';
import 'package:budgettracker/login/login.dart';
import 'package:budgettracker/dashboard/dashboard.dart';
import 'package:budgettracker/home/home.dart';
import 'package:budgettracker/register/register.dart';
import 'package:budgettracker/challenges/challenges.dart';
import 'package:budgettracker/chatbot/chatbot.dart';
import 'package:budgettracker/transaction/history.dart';

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
};
