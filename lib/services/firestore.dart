import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/services/models.dart';
import 'package:flutter/material.dart';
import 'package:live_currency_rate/live_currency_rate.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirestoreService {
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  Future<double> convertToUSD(double amount, String fromCurrency) async {
    if (fromCurrency == 'USD') return amount;

    try {
      CurrencyRate rate = await LiveCurrencyRate.convertCurrency(
        fromCurrency, // e.g., "EUR"
        'USD', // target currency
        amount, // amount to convert
      );

      return rate.result;
    } catch (e) {
      return amount; // fallback to original amount
    }
  }

  Future<void> createWallet({
    required String name,
    required double balance,
    required String type,
    required String currency,
  }) async {
    var user = AuthService().user!; // Get the current authenticated user

    try {
      // Reference to the user document in Firestore
      var userRef = _db.collection('users').doc(user.uid);

      // Check if the user document exists
      var userDoc = await userRef.get();

      // If the user document doesn't exist, create it
      if (!userDoc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': firestore.FieldValue.serverTimestamp(),
        });
      }

      // Generate new wallet document reference
      var newWalletDoc =
          _db.collection('users').doc(user.uid).collection('wallets').doc();

      // Create a new Wallet object
      Wallet wallet = Wallet(
        id: newWalletDoc.id,
        name: name,
        balance: balance,
        type: type,
        currency: currency,
        uid: user.uid,
      );

      // Set the wallet data to Firestore with createdAt
      await newWalletDoc.set({
        ...wallet.toJson(),
        'createdAt': firestore.FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(
        msg: "Wallet created successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.green[300],
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to create wallet: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Future<void> createBudget({
    required String category,
    required double amount,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    try {
      var user = AuthService().user!;

      var userRef = _db.collection('users').doc(user.uid);
      var userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'createdAt': firestore.FieldValue.serverTimestamp(),
        });
      }

      var budgetId =
          _db.collection('users').doc(user.uid).collection('budgets').doc().id;

      Budget budget = Budget(
        id: budgetId,
        uid: user.uid,
        category: category,
        amount: amount,
        startTime: firestore.Timestamp.fromDate(startTime),
        endTime: firestore.Timestamp.fromDate(endTime),
        spending: 0,
        createdAt: null, // Will be set by Firestore server timestamp
      );

      var budgetRef = _db
          .collection('users')
          .doc(user.uid)
          .collection('budgets')
          .doc(budgetId);

      await budgetRef.set({
        ...budget.toJson(),
        'createdAt': firestore.FieldValue.serverTimestamp(),
      });

      Fluttertoast.showToast(
        msg: "Budget created successfully",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.green[300],
        fontSize: 16.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Failed to create budget: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.red[700],
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  Stream<List<Budget>> streamAllBudgets() {
    var user = AuthService().user!;
    var collectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets');

    return collectionRef.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Budget.fromJson(doc.data());
      }).toList();
    });
  }

  Stream<List<Budget>> streamActiveBudgets() {
    var user = AuthService().user!;
    var collectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets');

    final now = firestore.Timestamp.fromDate(DateTime.now());

    return collectionRef.where('endTime', isGreaterThan: now).snapshots().map((
      querySnapshot,
    ) {
      return querySnapshot.docs.map((doc) {
        return Budget.fromJson(doc.data());
      }).toList();
    });
  }

  Stream<List<Transaction>> streamTransactions({required String walletId}) {
    var user = AuthService().user!;
    var ref = _db
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .doc(walletId)
        .collection('transactions')
        .orderBy('date', descending: true);

    return ref.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Transaction.fromJson(doc.data()))
          .toList();
    });
  }

  Stream<Wallet?> streamWallet({required String walletId}) {
    var user = AuthService().user!;
    var docRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .doc(walletId);

    return docRef.snapshots().map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        return Wallet.fromJson(snapshot.data()!);
      } else {
        return null;
      }
    });
  }

  Stream<List<Wallet>> streamAllWallets() {
    var user = AuthService().user!;
    var collectionRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wallets');

    return collectionRef.snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return Wallet.fromJson(doc.data());
      }).toList();
    });
  }

  Stream<double> streamTotalBalance(String targetCurrency) {
    var user = AuthService().user!;

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .snapshots()
        .asyncMap((querySnapshot) async {
          double total = 0.0;

          for (var doc in querySnapshot.docs) {
            final data = doc.data();

            if (data.containsKey('balance') && data.containsKey('currency')) {
              final balance = data['balance'];
              final walletCurrency = data['currency'];

              if (walletCurrency == targetCurrency) {
                total += balance;
              } else {
                try {
                  CurrencyRate rate = await LiveCurrencyRate.convertCurrency(
                    walletCurrency,
                    targetCurrency,
                    balance,
                  );
                  total += rate.result;
                } catch (e) {}
              }
            }
          }

          return total;
        });
  }

  Future<void> addTransaction({
    required String walletId,
    required Transaction transaction,
    required String note,
  }) async {
    var user = AuthService().user!;
    var walletRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .doc(walletId);

    var walletTransactionRef = walletRef.collection('transactions').doc();

    double signedAmount =
        transaction.type == 'income' ? transaction.amount : -transaction.amount;

    var data = {'balance': firestore.FieldValue.increment(signedAmount)};

    await _db.runTransaction((txn) async {
      final transactionData = {
        ...transaction.toJson(),
        'id': walletTransactionRef.id,
        'uid': user.uid,
        'note': note,
        'walletId': walletId,
        'date': transaction.date,
      };

      // Add transaction to wallet's subcollection
      txn.set(walletTransactionRef, transactionData);

      // Update wallet balance
      txn.set(walletRef, data, firestore.SetOptions(merge: true));

      // Handle expense and update budgets
      if (transaction.type == 'expense') {
        var budgetsRef = _db
            .collection('users')
            .doc(user.uid)
            .collection('budgets');

        var now = firestore.Timestamp.now();

        // Get wallet currency
        var walletSnapshot = await walletRef.get();
        var walletData = walletSnapshot.data();
        String walletCurrency = walletData?['currency'] ?? 'USD';

        // Convert amount to USD
        double usdAmount = await convertToUSD(
          transaction.amount,
          walletCurrency,
        );

        // Query budgets with matching category and endTime not passed
        var matchingBudgets =
            await budgetsRef
                .where('category', isEqualTo: transaction.category)
                .where('endTime', isGreaterThanOrEqualTo: now)
                .get();

        for (var doc in matchingBudgets.docs) {
          txn.update(doc.reference, {
            'spending': firestore.FieldValue.increment(usdAmount),
          });
        }
      }
    });

    // Show toast after transaction completes successfully
    Fluttertoast.showToast(
      msg: "Transaction added successfully",
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.SNACKBAR,
      backgroundColor: Colors.black54,
      textColor: Colors.green[300],
      fontSize: 16.0,
    );
  }
}
