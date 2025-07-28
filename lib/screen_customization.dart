import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';

// Utility functions for Persona 5 specific shapes/borders
double imperfectRectangleAspectRatio = 600; // These values seem arbitrary.
double imageAspectRatio = 500;             // Re-evaluate their purpose.

// This scale factor might be better calculated dynamically based on
// the actual image size and target container size if you want to
// fit images into specific distorted shapes.
double calculateScaleFactor(double rectAspectRatio, double imageAspectRatio) {
  if (rectAspectRatio > imageAspectRatio) {
    return 1.0;
  } else {
    return rectAspectRatio / imageAspectRatio;
  }
}

double scaleFactor = calculateScaleFactor(imperfectRectangleAspectRatio, imageAspectRatio);

class ShapeClipper extends CustomClipper<Path> {
  final Path path;

  ShapeClipper({required this.path});

  @override
  Path getClip(Size size) {
    return path; // The path is provided directly
  }

  @override
  bool shouldReclip(ShapeClipper oldClipper) => oldClipper.path != path;
}

// Your new Persona5SlantedArtwork widget:
class Persona5SlantedArtwork extends StatelessWidget {
  final int songId;
  final double size; // The desired square size for the artwork container
  final String? fallbackImagePath;

  const Persona5SlantedArtwork({
    super.key,
    required this.songId,
    required this.size,
    this.fallbackImagePath,
  });

  Path _getSlantedPath(Size actualSize) {
  Path path = Path();
  // These points define the outer edge of the *clipped image*.
  // Start with values that almost fill the square (0 to 1.0)
  // then introduce small offsets for the slant.
  path.moveTo(actualSize.width * 0.05, actualSize.height * 0.0);    // Top-left (shifted right)
  path.lineTo(actualSize.width * 0.0, actualSize.height * 1.0);     // Bottom-left (shifted left)
  path.lineTo(actualSize.width * 1.0, actualSize.height * 1.0);     // Bottom-right (full width, full height)
  path.lineTo(actualSize.width * 0.95, actualSize.height * 0.0);    // Top-right (shifted left)
  path.close();
  return path;
}

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SlantedArtworkBorderPainter(
          pathBuilder: _getSlantedPath,
          borderColor: Colors.white,
          accentColor: const Color(0xffff0505),
        ),
        child: ClipPath(
          clipper: ShapeClipper(path: _getSlantedPath(Size.square(size))), // Correct usage here
          child: QueryArtworkWidget(
            id: songId,
            type: ArtworkType.AUDIO,
            artworkFit: BoxFit.cover,
            artworkBorder: BorderRadius.zero,
            nullArtworkWidget: fallbackImagePath != null
                ? Image.asset(fallbackImagePath!, fit: BoxFit.cover)
                : Container(color: Colors.grey[900]),
          ),
        ),
      ),
    );
  }
}

class _SlantedArtworkBorderPainter extends CustomPainter {
  final Path Function(Size) pathBuilder; // Function to get the slanted path
  final Color borderColor;
  final Color accentColor;

  _SlantedArtworkBorderPainter({
    required this.pathBuilder,
    required this.borderColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
  final Path slantedPath = pathBuilder(size); // This is the path from _getSlantedPath

  // Paint for the main border (white)
  final Paint borderPaint = Paint()
    ..color = borderColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3.0; // Adjust for visibility

  canvas.drawPath(slantedPath, borderPaint); // Draw the main border on the image's clipped edge

  // Paint for the accent border (red)
  final Paint accentPaint = Paint()
    ..color = accentColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  // Use the same path, but scale it slightly for the inner border.
  // The scale factor (e.g., 0.98) controls how far *in* the inner border is.
  final Matrix4 scaleMatrix = Matrix4.identity()..scale(0.98, 0.98);
  final Path innerPath = slantedPath.transform(scaleMatrix.storage);
  // Optional: If you need to shift the inner border very slightly to a specific corner
  // final Matrix4 translateMatrix = Matrix4.translationValues(size.width * 0.005, size.height * 0.005, 0);
  // final Path innerPath = innerPath.transform(translateMatrix.storage);

  canvas.drawPath(innerPath, accentPaint);
}

  @override
  bool shouldRepaint(_SlantedArtworkBorderPainter oldDelegate) {
    return oldDelegate.pathBuilder != pathBuilder ||
           oldDelegate.borderColor != borderColor ||
           oldDelegate.accentColor != accentColor;
  }
}
class ArtBorderPainter extends CustomPainter {
  final Color strokeColor;
  ArtBorderPainter({this.strokeColor = Colors.white}); // Context is usually not needed here

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 50; // This strokeWidth is very large for an artwork border. Adjust.


    var path = Path();
    // These coordinates should be relative to `size` (the canvas size for this painter),
    // not hardcoded percentages of the screen or some external value.
    // Example: path.moveTo(size.width * 0.05, size.height * 0.06);
    path.moveTo(size.width * 0.05, size.height * 0.06);
    path.lineTo(size.width * 0.06, size.height * 0.94);
    path.lineTo(size.width * 0.98, size.height * 0.95);
    path.lineTo(size.width * 1.01, size.height * 0.015);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}


class ImperfectRectangleBorder extends CustomPainter {
  final Color strokeColor;
  ImperfectRectangleBorder({this.strokeColor = Colors.white, required BuildContext context}); // Context not needed if drawing relative to size

  @override
  void paint(Canvas canvas, Size size) {
    // Correct way: use the 'size' parameter provided to the paint method.
    // This 'size' is the actual size of the widget that this painter is applied to.
    var paint = Paint()
      ..color = strokeColor
      ..strokeWidth = 9.5
      ..style = PaintingStyle.stroke;

    var path = Path();

    // Black imperfect rectangle (outer border)
    paint.color = Colors.black;
    paint.strokeWidth = 9.5; // Apply stroke width for black border
    path.moveTo(size.width * -0.021, size.height * -0.008);
    path.lineTo(size.width * -0.1, size.height * 0.07);
    path.lineTo(size.width * 1.0, size.height * 0.07);
    path.lineTo(size.width * 1.0, size.height * -0.005);
    path.close();
    canvas.drawPath(path, paint);

    // White imperfect rectangle (inner border)
    paint.color = Colors.white;
    paint.strokeWidth = 5; // Apply stroke width for white border
    path = Path(); // Reset path for the new shape
    path.moveTo(0, size.height * -0.002);
    path.lineTo(size.width * -0.05, size.height * 0.067);
    path.lineTo(size.width * 0.96, size.height * 0.065);
    path.lineTo(size.width * 0.96, size.height * -1 / 10000); // Small value instead of -1/screenHeight
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class BackgroundPainter extends CustomPainter {
  final Color strokeColor;
  BackgroundPainter({this.strokeColor = Colors.white, required BuildContext context});


  @override
  void paint(Canvas canvas, Size size) {
    Paint fillPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    Path path = Path();
    // Re-define these points for a clear parallelogram that covers the ListTile area.
    // Tune these to get the exact slant you want.
    // (top-left, bottom-left, bottom-right, top-right)
    path.moveTo(size.width * 0.0,  size.height * 0.1); // Top-left corner (shifted down slightly)
    path.lineTo(size.width * 0.05, size.height * 1.0); // Bottom-left corner (shifted right, full height)
    path.lineTo(size.width * 1.0,  size.height * 0.9); // Bottom-right corner (full width, shifted up slightly)
    path.lineTo(size.width * 0.95, size.height * 0.0); // Top-right corner (shifted left, full height)
    path.close();

    canvas.drawPath(path, fillPaint);

    Paint borderPaint1 = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0 // Adjust border thickness
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint1);

    Paint borderPaint2 = Paint()
      ..color = const Color(0xffff0505)
      ..strokeWidth = 1.0 // Adjust thickness
      ..style = PaintingStyle.stroke;

    // Inner Red Border Path
    Path innerBorderPath = Path();
    // This path should be slightly inset from the 'path' defined above.
    // Adjust these multipliers carefully.
    innerBorderPath.moveTo(size.width * 0.005, size.height * 0.11);
    innerBorderPath.lineTo(size.width * 0.055, size.height * 0.99);
    innerBorderPath.lineTo(size.width * 0.995, size.height * 0.89);
    innerBorderPath.lineTo(size.width * 0.945, size.height * 0.01);
    innerBorderPath.close();

    canvas.drawPath(innerBorderPath, borderPaint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}