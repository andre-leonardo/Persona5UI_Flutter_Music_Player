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
  Path getClip(Size size) => path;
  @override
  bool shouldReclip(ShapeClipper oldClipper) => oldClipper.path != path;
}

// ─── Shared Path Builder for Persona 5 Aesthetics ───
Path _getPersona5Path(Size size) {
  final dx = size.height * 0.15; // Consistent horizontal slant
  final dy = size.height * 0.05; // Consistent vertical slant
  
  final path = Path();
  path.moveTo(dx, dy); 
  path.lineTo(0, size.height); 
  path.lineTo(size.width - dx, size.height - dy); 
  path.lineTo(size.width, 0); 
  path.close();
  return path;
}

Path _getPersona5InnerPath(Size size, {double inset = 4.0}) {
  final dx = size.height * 0.15;
  final dy = size.height * 0.05;
  
  final path = Path();
  path.moveTo(dx + inset, dy + inset); 
  path.lineTo(inset, size.height - inset); 
  path.lineTo(size.width - dx - inset, size.height - dy - inset); 
  path.lineTo(size.width - inset, inset); 
  path.close();
  return path;
}

// ─── Slanted Artwork ───
class Persona5SlantedArtwork extends StatelessWidget {
  final int songId;
  final double size; 
  final String? fallbackImagePath;

  const Persona5SlantedArtwork({
    super.key,
    required this.songId,
    required this.size,
    this.fallbackImagePath,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _SlantedArtworkBorderPainter(
          borderColor: Colors.white,
          accentColor: const Color(0xffff0505),
        ),
        child: ClipPath(
          clipper: ShapeClipper(path: _getPersona5Path(Size.square(size))),
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
  final Color borderColor;
  final Color accentColor;

  _SlantedArtworkBorderPainter({
    required this.borderColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final slantedPath = _getPersona5Path(size);
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(slantedPath, borderPaint);

    final innerPath = _getPersona5InnerPath(size, inset: 4.0);
    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(innerPath, accentPaint);
  }

  @override
  bool shouldRepaint(_SlantedArtworkBorderPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
           oldDelegate.accentColor != accentColor;
  }
}

// ─── Background Painter for List Tiles ───
class BackgroundPainter extends CustomPainter {
  final Color strokeColor;
  BackgroundPainter({this.strokeColor = Colors.white, required BuildContext context});

  @override
  void paint(Canvas canvas, Size size) {
    final path = _getPersona5Path(size);
    
    final fillPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final borderPaint1 = Paint()
      ..color = strokeColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint1);

    final innerBorderPath = _getPersona5InnerPath(size, inset: 3.0);
    final borderPaint2 = Paint()
      ..color = const Color(0xffff0505)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(innerBorderPath, borderPaint2);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}