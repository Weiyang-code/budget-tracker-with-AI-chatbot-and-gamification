import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/services/models.dart';

class FirestoreService {
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  Future<void> createWallet({
    required String name,
    required double balance,
  }) async {
    var user = AuthService().user!; // Get the current authenticated user

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

    // Create a new Wallet object
    Wallet wallet = Wallet(
      id:
          _db
              .collection('users')
              .doc(user.uid)
              .collection('wallets')
              .doc()
              .id, // Generate a unique ID
      name: name,
      balance: balance, // Set the initial balance from the parameter
      uid: user.uid, // Set the user's UID
    );

    // Reference to the user's wallets collection
    var walletRef = _db
        .collection('users')
        .doc(user.uid) // User ID from Firebase Authentication
        .collection('wallets') // Sub-collection under the user document
        .doc(wallet.id); // New wallet document ID

    // Set the wallet data to Firestore
    await walletRef.set(wallet.toJson());
  }

  Future<void> createBudget({
    required String category,
    required double amount,
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    var user = AuthService().user!; // Get the current authenticated user

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

    // Create a Budget object with generated ID
    Budget budget = Budget(
      id: _db.collection('users').doc(user.uid).collection('budgets').doc().id,
      uid: user.uid,
      category: category,
      amount: amount,
      startTime: firestore.Timestamp.fromDate(startTime),
      endTime: firestore.Timestamp.fromDate(endTime),
      createdAt:
          firestore
              .Timestamp.now(), // Or handle server timestamp in Firestore if needed
    );

    // Reference to the user's budgets collection
    var budgetRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(budget.id);

    // Save the budget to Firestore
    await budgetRef.set(budget.toJson());
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

  Stream<double> streamTotalBalance() {
    var user = AuthService().user!;

    // Listen to changes in the wallets collection for the current user
    return _db
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .snapshots()
        .map((querySnapshot) {
          double total = 0.0;

          // Sum the balances for all wallets
          for (var doc in querySnapshot.docs) {
            final data = doc.data();
            if (data.containsKey('balance')) {
              final balance = data['balance'];
              total += balance;
            }
          }

          return total;
        });
  }

  Future<void> addTransaction({
    required String walletId,
    required Transaction transaction,
  }) async {
    var user = AuthService().user!;
    var walletRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('wallets')
        .doc(walletId);

    var transactionRef = walletRef.collection('transactions').doc();

    double signedAmount =
        transaction.type == 'income' ? transaction.amount : -transaction.amount;

    var data = {
      'balance': firestore.FieldValue.increment(
        signedAmount,
      ), // subtract amount
    };

    return _db.runTransaction((txn) async {
      // Add the transaction
      txn.set(transactionRef, {
        ...transaction.toJson(),
        'id': transactionRef.id,
        'date': transaction.date,
      });

      // Update the wallet balance
      txn.set(walletRef, data, firestore.SetOptions(merge: true));
    });
  }
}
