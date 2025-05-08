import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:rxdart/rxdart.dart';
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/services/models.dart';

class FirestoreService {
  final firestore.FirebaseFirestore _db = firestore.FirebaseFirestore.instance;

  Future<void> createWallet({
    required String name,
    required int balance,
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

    int signedAmount =
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
