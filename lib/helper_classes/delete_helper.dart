import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BatchDelete {
  batchDelete() async {
    int batchSize = 500;
    bool deletionDone = false;
    final db = FirebaseFirestore.instance;
    final docReference = db
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .collection('dailyExpenses')
        .where('timeStamp',
            isLessThanOrEqualTo: DateTime(
                DateTime.now().year, DateTime.now().month, 0, 23, 59, 59, 999));
    final querySnapshots = await docReference.limit(batchSize).get();
    while (!deletionDone) {
      if (querySnapshots.docs.isEmpty) {
        deletionDone = true;
        break;
      }
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var doc in querySnapshots.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
