import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoadDetailsMethods {
  String? email;
  DocumentReference? userReference;
  LoadDetailsMethods() {
    _fetchInitializationDetails();
  }
  Future<Map<String,dynamic>> fetchMonthlyExpensesDetails({required int month, required int year}) async{
    Map<String,dynamic> monthlyExpenses = <String,dynamic>{};
    final DocumentReference documentReference = userReference!
    .collection('monthlyExpenses')
    .doc('$year-${month}details');
    final DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      monthlyExpenses['expenseValue'] = (await data['expenseValue'] as num).toDouble();
      monthlyExpenses['month'] = await data['month'];
    }
    return monthlyExpenses;
  }

  Future<Map<String, dynamic>> fetchPocketMoneyDetails({required int month, required int year}) async {
    Map<String,dynamic> pocketMoney = <String, dynamic>{};
    final DocumentReference documentReference = userReference!
    .collection('pocketMoney')
    .doc('$year-${month}details');
    final DocumentSnapshot documentSnapshot = await documentReference.get();
    if (documentSnapshot.exists) {
      final data = documentSnapshot.data() as Map<String, dynamic>;
      pocketMoney['pocketMoney'] = (await data['pocketMoney'] as num).toDouble();
      pocketMoney['month'] = await data['month'];
      pocketMoney['targetSavings'] = (await data['targetSavings'] as num).toDouble();
    }
    return pocketMoney;
  }

  Future<Map<String, dynamic>> fetchTargetProductDetails() async{
    final documentReference  = userReference!.collection('targetProduct').doc('productDetails');
    Map<String, dynamic> targetProduct = <String, dynamic>{};
    final docSnapshot  = await documentReference.get();
    if(docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String,dynamic>;
      targetProduct['targetAmount'] = (await data['amount'] as num). toDouble();
      targetProduct['productName'] = await data['product'];
    }
    return targetProduct;
  }

  Future<Map<String, dynamic>> fetchUserDetails() async{
    final documentReference  = userReference!.collection('userDetails').doc('details');
    Map<String, dynamic> userDetails = <String, dynamic>{};
    final docSnapshot  = await documentReference.get();
    if(docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String,dynamic>;
      userDetails['age'] = await  data['age'];
      userDetails['email'] = await  data['emailAddress'];
      userDetails['name'] = await data['name'];
      userDetails['phoneNumber'] = await data['phoneNumber'];
    }
    return userDetails;
  }

  Future<Map<String, dynamic>> fetchStreakDetails() async{
    final documentReference  = userReference!.collection('streakDetails').doc('details');
    Map<String, dynamic> streakDetails = <String, dynamic>{};
    final docSnapshot  = await documentReference.get();
    if(docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String,dynamic>;
      streakDetails['currentStreak'] = await data['currentStreak'];
      streakDetails['lastActiveDate'] = await data['lastActiveDate'];
      streakDetails['maximumStreak'] = await data['maximumStreak'];
      streakDetails['signUpDate'] = await data['signUpDate'];
    }
    return streakDetails;
  }
  
  void _fetchInitializationDetails() {
    final db = FirebaseFirestore.instance;
    email = FirebaseAuth.instance.currentUser!.email;
    userReference = db.collection('users').doc(email);
  }
}