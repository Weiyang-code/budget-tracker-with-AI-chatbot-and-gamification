import 'package:budgettracker/transaction/transaction.dart';
import 'package:budgettracker/profile/profile.dart';
import 'package:budgettracker/login/login.dart';
import 'package:budgettracker/dashboard/dashboard.dart';
import 'package:budgettracker/home/home.dart';
import 'package:budgettracker/register/register.dart';

var appRoutes = {
  '/': (context) => const HomeScreen(),
  '/login': (context) => LoginScreen(),
  '/dashboard': (context) => DashboardScreen(),
  '/profile': (context) => const ProfileScreen(),
  '/transaction': (context) => const TransactionScreen(),
  '/register': (context) => RegisterScreen(),
};
