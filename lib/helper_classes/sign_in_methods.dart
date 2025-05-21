import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignInHelper {
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<void> signInWithFacebook() async {
    final LoginResult loginResult = await FacebookAuth.instance.login();
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
    await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
  }

  void signUpWithEmailPassword(
      {required emailAddress,
      required password,
      required context,
      required name,
      required age,
      required phoneNumber}) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress!,
        password: password!,
      );
      final db = FirebaseFirestore.instance;
      DocumentReference docReference =
          db.collection("users").doc(emailAddress);
      docReference.collection("userDetails").doc('details').set(<String, dynamic>{
        'name': name,
        'age': age,
        'emailAddress': emailAddress,
        'phoneNumber': phoneNumber,
      });
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      } else {
        message = 'Authentication failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      const message = "An unexpected error ocurred";
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text(message)));
    }
  }

  void signInWithEmailAndPassword(
      {required emailAddress, required password, required context}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailAddress!, password: password!);
    } on FirebaseException catch (e) {
      String message = "";
      if (e.code == 'user_not_found') {
        message = 'Check your email address!';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password!';
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
