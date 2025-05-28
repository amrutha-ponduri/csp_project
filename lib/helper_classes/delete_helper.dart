import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
  Future<void> batchDeleteYears() async {
  final db = FirebaseFirestore.instance;
  final String? userEmail = FirebaseAuth.instance.currentUser?.email;

  if (userEmail == null) {
    debugPrint("User not logged in.");
    return;
  }

  final collectionRef = db
      .collection('users')
      .doc(userEmail)
      .collection('monthlyExpenses');

  final currentYear = DateTime.now().year;

  const int batchSize = 500;
  bool deletionDone = false;

  while (!deletionDone) {
    // Fetch a batch of documents with years less than currentYear
    final querySnapshot = await collectionRef
        .where(FieldPath.documentId, isLessThan: "$currentYear-")
        .limit(batchSize)
        .get();

    final docs = querySnapshot.docs;

    if (docs.isEmpty) {
      deletionDone = true;
      break;
    }

    final WriteBatch batch = db.batch();

    for (final doc in docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

}
