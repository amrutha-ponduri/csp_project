import 'package:flutter/material.dart';
import 'package:flutter_arc_text/flutter_arc_text.dart';

class EnterExpenseButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Color doraemonBlue = Color(0xFF2196F3);
  EnterExpenseButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      width: 80,
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: doraemonBlue,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/images/anyway_door.png'),
            ),
            Positioned(
              top: 0,
              child: ArcText(
                radius: 80,
                text: "Enter your expense!",
                textStyle: TextStyle(
                  fontFamily: 'Baloo2',
                  fontSize: 14,
                  color: Colors.white,
                ),
                startAngle: -3.14 / 1.5,
                placement: Placement.outside,
                direction: Direction.clockwise,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
