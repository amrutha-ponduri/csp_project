import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  const AddButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: Text('Hello'),
      onPressed: () {},
    );
  }
}
