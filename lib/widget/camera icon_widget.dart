import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final double size;
  final VoidCallback onCameraTap;

  const ProfilePictureWidget({
    Key? key,
    this.size = 120.0,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: size / 2,
          backgroundColor: const Color.fromARGB(255, 141, 169, 192),
          child: CircleAvatar(
            radius: (size / 2) - 4,
            backgroundImage:
                AssetImage('assets/doraemon.png'), // Your image asset
          ),
        ),
        Positioned(
          bottom: 0,
          right: size * 0.15,
          child: GestureDetector(
            onTap: onCameraTap,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue.shade800,
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: size * 0.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
