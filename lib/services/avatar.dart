import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarService {
  final _firestore = FirestoreService();
  final _user = AuthService().user!;
  final _userRef = FirebaseFirestore.instance.collection('users');

  Future<void> updateAvatarProgress() async {
    await _firestore.checkAndUpdateChallengeCompletion();

    final challenges =
        await _userRef
            .doc(_user.uid)
            .collection('challenges')
            .where('completed', isEqualTo: true)
            .get();

    final completedCount = challenges.docs.length;
    final newLevel = (completedCount ~/ 3) + 1;

    await _userRef.doc(_user.uid).update({
      'completedChallenges': completedCount,
      'avatarLevel': newLevel,
    });
  }

  Future<int> getAvatarLevel() async {
    final userDoc = await _userRef.doc(_user.uid).get();
    return userDoc.data()?['avatarLevel'] ?? 1;
  }
}
