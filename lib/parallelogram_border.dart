//THAT'S IT, ITS A TOTAL BRUH MOMENT, YES, A BRUH MOMENT, CAN YOU HEAR IT????? BRUUUUUUUUUUH
// YEAH MY 34 IQ BRAIN CAN'T FIGURE OUT HOW TO MAKE CRAZY SHAPES IN FLUTTER SO I USEAD AN IMAGE, THANK YOU AND GOOD NIGHT




import 'package:flutter/material.dart';

class ParallelogramBorder extends ShapeBorder {
  final double widthFactor;

  ParallelogramBorder({required this.widthFactor});

  @override
  EdgeInsetsGeometry get dimensions {
    return EdgeInsets.only();
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection textDirection}) {
    return null;
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection textDirection}) {
    return Path()
      ..moveTo(rect.left, rect.top)
      ..lineTo(rect.right + widthFactor, rect.top)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left - widthFactor, rect.bottom)
      ..close();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection textDirection}) {
    final paint = Paint();
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2.0;

    final path = Path();
    path.moveTo(rect.left, rect.top);
    path.lineTo(rect.right + widthFactor, rect.top);
    path.lineTo(rect.right, rect.bottom);
    path.lineTo(rect.left - widthFactor, rect.bottom);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  ShapeBorder scale(double t) {
    return ParallelogramBorder(widthFactor: widthFactor * t);
  }
}
