import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expend/loading_data/load_details_methods.dart';

class SetDetailsMethods {
  String? email;
  DocumentReference? userReference;
  SetDetailsMethods() {
    initializeData();
  }

  Future<void> setNewTarget({required Map<String,dynamic> newTarget}) async{
      DocumentReference documentReference = userReference!
          .collection('targetProduct')
          .doc('productDetails');
      await documentReference.set(newTarget);
  }

  Future<void> updateCurrentSavings({required Map<String, dynamic> updatedCurrentSavings}) async{
    DocumentReference documentReference = userReference!.collection('savingsDetails').doc('currentSavings');
    await documentReference.set(updatedCurrentSavings);
  }

  Future<void> updatePreviousSavings({required double addedSavings}) async {
    LoadDetailsMethods loadDetailsMethods = LoadDetailsMethods();
    DocumentReference documentReference = userReference!.collection('savingsDetails').doc('previousSavings');
    double previousSavings = await loadDetailsMethods.getPreviousSavings() ?? 0;
    await documentReference.set(<String, double> {
      'savings' : previousSavings + (addedSavings as num).toDouble(),
    });
  }

  Future<void> setPreviousSavings({required double remainingSavings}) async{
    DocumentReference documentReference = userReference!.collection('savingsDetails').doc('previousSavings');
    await documentReference.set(<String, double> {
      'savings' : remainingSavings,
    });
  }

  Future<void> addToCurrentSavings({double? previousExpense, required currentSavings, required expenseValue}) async{
    final docRef = userReference!
        .collection('savingsDetails')
        .doc('currentSavings');
    LoadDetailsMethods loadDetailsMethods = LoadDetailsMethods();
    
    Map<String, dynamic>? initCurrentSavingsDetails = await loadDetailsMethods.getCurrentSavings();
    if (initCurrentSavingsDetails == null) {
      return;
    }
    double initCurrentSavings = initCurrentSavingsDetails['savings'];
    if (previousExpense != null) {
      initCurrentSavings = initCurrentSavings + previousExpense;
    }
   else {
      currentSavings = currentSavings! - expenseValue;
    }

    final docSnapshot = await docRef.get();
    if (docSnapshot.exists) {
      await docRef.update(<String, dynamic>{'currentSavings': currentSavings});
    } else {
      await docRef.set(<String, dynamic>{
        'currentSavings': currentSavings,
      });
    }
  }
  void initializeData() {
    final db = FirebaseFirestore.instance;
    email = FirebaseAuth.instance.currentUser!.email;
    userReference = db.collection('users').doc(email);
  }

  Future<void> updateOnlySavingsOfCurrentSavings({required double removedExpense}) async{
    LoadDetailsMethods loadDetailsMethods = LoadDetailsMethods();
    Map<String, dynamic>? currentSavings = await loadDetailsMethods.getCurrentSavings();
    if (currentSavings == null) {
      return;
    }
    double initSavings = (currentSavings['savings'] as num).toDouble();
    DocumentReference documentReference = userReference!.collection('savingsDetails').doc('currentSavings');
    await documentReference.update(<String, dynamic>{
      'savings' : initSavings + removedExpense
    });
  }
}