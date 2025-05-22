// ignore_for_file: unused_import

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:smart_expend/pages/dailychart.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String _name = "Enter your name";
  String _email = "Enter your email";
  String _phone = "Phone number please";
  int _age = 0;
  bool _isEditingName = false;
  final _nameController = TextEditingController();
  late Future<Map<String, dynamic>?> getData;
  // File? _imageFile;
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    getData = getUserData();
  }

  // Future<void> _pickImage() async {
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     setState(() {
  //       _imageFile = File(pickedFile.path);
  //     });
  //   }
  // }

  void _saveName() {
    if (_nameController.text.isNotEmpty) {
      final db = FirebaseFirestore.instance;
      final DocumentReference documentReference = db
          .collection('users')
          .doc(_email)
          .collection('userDetails')
          .doc('details');
      documentReference.set(<String, dynamic>{
        'name': _nameController.text.toString(),
        'emailAddress': _email,
        'phoneNumber': _phone,
        'age': _age,
      });
      getData = getUserData();
      setState(() {
        _name = _nameController.text;
        _isEditingName = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic>? userDetails;
    return Scaffold(
      body: FutureBuilder(
          future: getData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              userDetails = snapshot.data;
            }

            if (userDetails == null) {
              _name = 'Not specified';
              _email = 'Not specified';
              _phone = 'Not specified';
            } else {
              _name = userDetails!['name'];
              _email = userDetails!['emailAddress'];
              _phone = userDetails!['phoneNumber'];
              _age = userDetails!['age'];
            }
            return ListView(
              children: [
                // Header with Gradient
                Container(
                  padding: EdgeInsets.only(top: 60, bottom: 30),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.vertical(
                      bottom: Radius.circular(30),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                _isEditingName
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  labelText: 'Full Name',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.check, color: Colors.white),
                              onPressed: _saveName,
                            ),
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _name,
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () {
                              _nameController.text = _name;
                              setState(() {
                                _isEditingName = true;
                              });
                            },
                          ),
                        ],
                      ),
                // Profile Details Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      ProfileInfoCard(
                        title: 'Email',
                        value: _email,
                        icon: Icons.email,
                      ),
                      SizedBox(height: 10),
                      ProfileInfoCard(
                        title: 'Phone Number',
                        value: _phone,
                        icon: Icons.phone,
                      ),
                    ],
                  ),
                ),
                DailyExpenseChart(),
              ],
            );
          }),
    );
  }
}

Future<Map<String, dynamic>?> getUserData() async {
  Map<String, dynamic>? userDetails;
  final db = FirebaseFirestore.instance;
  DocumentReference documentReference = db
      .collection('users')
      .doc(FirebaseAuth.instance.currentUser!.email)
      .collection('userDetails')
      .doc('details');
  await documentReference.get().then((DocumentSnapshot doc) {
    userDetails = doc.data() as Map<String, dynamic>;
  });
  return userDetails;
}

// Custom Widget for Profile Information
class ProfileInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProfileInfoCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
