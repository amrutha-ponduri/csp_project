import 'package:flutter/material.dart';

class ProfilePictureWidget extends StatelessWidget {
  final double size;

  const ProfilePictureWidget({
    super.key,
    this.size = 120.0,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: const Color.fromARGB(255, 141, 169, 192),
      child: CircleAvatar(
        radius: (size / 2) - 4,
        backgroundImage: const AssetImage('assets/images/dora_cake.png'),
      ),
    );
  }
}
