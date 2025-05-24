import 'package:flutter/material.dart';

class DoraemonTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Color(0xFF87CEEB), // Doraemon blue
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(Icons.tag_faces, color: Colors.red), // Doraemon face-like
      ),
      title: Text(
        'Doraemon',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        'I’m from the future!',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
