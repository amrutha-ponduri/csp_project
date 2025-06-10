import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_expend/pages/target_page.dart';

import 'package:smart_expend/pages/monthly_report_page.dart';
import 'package:smart_expend/widgets/monthly_chart.dart';
import 'package:smart_expend/pages/month_start_page.dart';

import '../widgets/profile_info_card.dart';

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
      appBar: AppBar(
        title: const Text("Doraemon Monthly Start",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.lightBlue.shade700,
        centerTitle: true,
      ),
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
                  child: _isEditingName
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
                ),
                SizedBox(height: 10),
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
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MonthlyReportPage()));
                        },
                        child: ProfileInfoCard(
                          value: "",
                          title: 'View Monthly report',
                          icon: Icons.line_axis,
                        ),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => YearlyChartPage()));
                        },
                        child: ProfileInfoCard(
                          value: "",
                          title: 'View Yearly Report',
                          icon: Icons.bar_chart,
                        ),
                      ),
                      SizedBox(height: 10),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MonthStartPage()));
                          },
                          child: ProfileInfoCard(
                              title: 'Store Pocket money',
                              value: "",
                              icon: Icons.currency_rupee)
                      ),
                      SizedBox(height: 10),
                      InkWell(
                          onTap: () async{
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.clear();
                            await FirebaseAuth.instance.signOut();
                            Navigator.pop(context);
                          },
                          child: ProfileInfoCard(
                              title: 'Log out',
                              value: "",
                              icon: Icons.logout_outlined)
                      ),
                      InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => TargetPage()));
                          },
                          child: ProfileInfoCard(
                              title: 'See my target',
                              value: "",
                              icon: Icons.arrow_outward)
                      ),

                    ],
                  ),
                ),
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

