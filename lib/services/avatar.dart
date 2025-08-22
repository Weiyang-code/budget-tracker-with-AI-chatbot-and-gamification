import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/services/firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvatarService {
  final _firestore = FirestoreService();
  final _userRef = FirebaseFirestore.instance.collection('users');

  Future<void> updateAvatarProgress() async {
    await _firestore.checkAndUpdateChallengeCompletion();

    final user = AuthService().user;
    if (user == null) return;

    final challenges =
        await _userRef
            .doc(user.uid)
            .collection('challenges')
            .where('completed', isEqualTo: true)
            .get();

    final completedCount = challenges.docs.length;
    final newLevel = (completedCount ~/ 3) + 1;

    await _userRef.doc(user.uid).update({
      'completedChallenges': completedCount,
      'avatarLevel': newLevel,
    });
  }

  Stream<Map<String, int>> streamAvatarData() {
    final user = AuthService().user;
    if (user == null) return const Stream.empty();

    return _userRef.doc(user.uid).snapshots().map((snapshot) {
      final data = snapshot.data();
      final level = data?['avatarLevel'] ?? 1;
      final completed = data?['completedChallenges'] ?? 0;
      return {'avatarLevel': level, 'completedChallenges': completed};
    });
  }

  Stream<int> streamAvatarLevel() {
    final user = AuthService().user;
    if (user == null) return const Stream.empty();

    return _userRef.doc(user.uid).snapshots().map((snapshot) {
      return snapshot.data()?['avatarLevel'] ?? 1;
    });
  }
}
