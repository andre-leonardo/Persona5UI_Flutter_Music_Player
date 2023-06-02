import 'package:flutter/material.dart';



class ArtBorderPainter extends CustomPainter {
  final Color strokeColor;
  final BuildContext context;
  ArtBorderPainter({this.strokeColor = Colors.white, required this.context});
  @override
  void paint(Canvas canvas, Size size,) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50;


    var path = Path();
    paint.color = Colors.black;
    path.moveTo(size.width * 0.05, 0.06 * size.height);
    path.lineTo(size.width * (0.06), 0.94 * size.height);
    path.lineTo(size.width * (0.98), 0.95 * size.height);
    path.lineTo(size.width * (1.01), 0.015 * size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}





class ImperfectRectangleBorder extends CustomPainter {
  final Color strokeColor;
  final BuildContext context;
  ImperfectRectangleBorder({this.strokeColor = Colors.white, required this.context});

  @override
  void paint(Canvas canvas, Size size) {
    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeigth = MediaQuery.of(context).size.height;
    var paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 9.5
      ..style = PaintingStyle.stroke;

    var path = Path();
    // black imperfect rectangle
    paint.color = Colors.black;
    var borderPath = Path();
    borderPath.moveTo(screenWidth * -0.021, -0.008 * screenHeigth);
    borderPath.lineTo(size.width * (-0.1), 0.07 * screenHeigth);
    borderPath.lineTo(size.width * (1), 0.07 * screenHeigth);
    borderPath.lineTo(size.width * (1.0), -0.005 * screenHeigth);
    borderPath.close();
    canvas.drawPath(borderPath, paint);
    // white imperfect rectangle
    paint.color = Colors.white;
    paint.strokeWidth = 5;
    path.moveTo(0, -0.002 * screenHeigth);
    path.lineTo(size.width * (-0.05), 0.067 * screenHeigth);
    path.lineTo(size.width * (0.96), 0.065 * screenHeigth);
    path.lineTo(size.width * (0.96), -1 / screenHeigth);
    path.close();
    canvas.drawPath(path, paint);
    
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BackgroundPainter extends CustomPainter {

  final Color strokeColor;
  final BuildContext context;
  BackgroundPainter({this.strokeColor = Colors.white, required this.context});
  @override
  void paint(Canvas canvas, Size size) {
    Paint fillPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(size.width / 4.6, size.height / 4);
    path.lineTo(size.width / 5, size.height /4);
    path.lineTo(size.width / 1.12, size.height * 0.19);
    path.lineTo(size.width / 1.2, size.height / 1.2);
    path.lineTo(size.width * 0.185, size.height / 1.3 );
    path.close();

    canvas.drawPath(path, fillPaint);

    Paint borderPaint1 = Paint()
      ..color = Colors.white
      ..strokeWidth = 10.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(path, borderPaint1);

    Paint borderPaint2 = Paint()
      ..color = Color(0xffff0505)
      ..strokeWidth = 8.0
      ..style = PaintingStyle.stroke;

      Path invisibleBorder = Path();
      invisibleBorder.moveTo(size.width / 5, size.height / 4.5);
      invisibleBorder.lineTo(size.width / 5, size.height /4.7);
      invisibleBorder.lineTo(size.width / 1.08, size.height * 0.16);
      invisibleBorder.lineTo(size.width / 1.19, size.height / 1.18);
      invisibleBorder.lineTo(size.width * 0.175, size.height / 1.25 );
      invisibleBorder.close();

    canvas.drawPath(invisibleBorder, borderPaint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


double imperfectRectangleAspectRatio = 600;
double imageAspectRatio = 500;

double scaleFactor = calculateScaleFactor(imperfectRectangleAspectRatio, imageAspectRatio);
  double calculateScaleFactor(double rectAspectRatio, double imageAspectRatio) {
    if (rectAspectRatio > imageAspectRatio) {
      return 1.0;
    } else {
      return rectAspectRatio / imageAspectRatio;
    }
  }