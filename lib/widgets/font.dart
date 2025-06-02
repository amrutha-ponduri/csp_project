import 'package:flutter/material.dart';

class FontPreviewApp extends StatelessWidget {
  const FontPreviewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFCAF0F8),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              'Headline: Comic Sans Bold',
              style: TextStyle(
                fontFamily: 'ComicSans',
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: Color(0xFF03045E),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Sideline: Comic Sans',
              style: TextStyle(
                fontFamily: 'ComicSans',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Color(0xFF023E8A),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Description: This is a paragraph using Nunito Bold for emphasis and readability in body text.',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212222),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
