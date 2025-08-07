import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;

class TShirtPainterStatic extends CustomPainter {
  // Add color properties and constructor
  final Color shirtBaseColor;
  final Color stripeColor;

  // Constructor with default values
  TShirtPainterStatic({
    this.shirtBaseColor = const Color(
        0xFF9E9E9E), // Default to a medium grey if AppColors.grey is not available
    this.stripeColor = const Color(0xFF5C5C5C),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height * 0.85; // Make shirt 15% shorter

    // Define colors - removed the local variables since we're now using properties

    // Create paint objects

    final Paint outlinePaint = Paint()
      ..color = const Color.fromARGB(197, 180, 180, 180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // Create shadow paint for 3D effect
    final Paint shadowPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          shirtBaseColor.withAlpha(200),
          shirtBaseColor.withAlpha(90),
          shirtBaseColor.withAlpha(190),
          // Colors.grey.shade300,
        ],
        stops: const [0.7, 0.8, 0.9],
      ).createShader(Rect.fromLTWH(0, 0, width, height));

    // Draw shirt body
    Path shirtPath = Path();

    // Modified collar design - higher and more pronounced
    // Start from further in and higher up for a higher collar
    shirtPath.moveTo(width * 0.42, 0);

    // Create a deeper V-neck collar with higher sides
    shirtPath.cubicTo(
        width * 0.45,
        height * 0.04, // First control point - raised higher
        width * 0.55,
        height * 0.04, // Second control point - raised higher
        width * 0.58,
        0); // End point - moved in slightly

    // Right shoulder with more rounded curve
    // Modified to create more rounded top of shoulder
    shirtPath.lineTo(width * 0.70, 0); // Moved in from 0.85 to 0.75
    shirtPath.quadraticBezierTo(width * 0.88, height * 0.02, width * 0.9,
        height * 0.075); // Rounded shoulder top

    // Right sleeve - lengthened and more curved
    shirtPath.quadraticBezierTo(width * 0.96, height * 0.20, width * 0.99,
        height * 0.32); // Extended sleeve outward
    shirtPath.quadraticBezierTo(width * 0.97 + 1, height * 0.35, width * 0.85,
        height * 0.38); // More curved sleeve end

    // Right side of shirt - more natural curve
    shirtPath.cubicTo(width * 0.78, height * 0.4, width * 0.81, height * 0.7,
        width * 0.82, height);

    // Bottom of shirt with subtle curve
    shirtPath.quadraticBezierTo(
        width * 0.87, height * 1.03, width * 0.22, height);

    // Left side of shirt - more natural curve
    shirtPath.cubicTo(width * 0.18, height * 0.7, width * 0.25, height * 0.4,
        width * 0.15, height * 0.36);

    //// Left sleeve - properly mirrored from right sleeve for symmetry
    shirtPath.quadraticBezierTo(width * 0.03, height * 0.35, width * 0.01,
        height * 0.32); // Extended sleeve outward to mirror right
    shirtPath.quadraticBezierTo(width * 0.04, height * 0.20, width * 0.1,
        height * 0.08); // More curved sleeve to mirror right

    // Left shoulder with more rounded curve
    shirtPath.quadraticBezierTo(
        width * 0.12, height * 0.02, width * 0.25, 0); // Rounded shoulder top

    // Complete the path
    shirtPath.close();

    // Draw shadow first (behind the shirt)
    drawShirtShadow(canvas, shirtPath, width, height);

    // Draw base shirt with gradient for more realistic look
    canvas.drawPath(shirtPath, shadowPaint);

    // Add inner shadow for enhanced 3D effect
    drawInnerShadow(canvas, shirtPath, width, height);

    // Add subtle fabric texture
    addFabricTexture(canvas, shirtPath, width, height);

    // Draw wrinkles
    drawRealisticWrinkles(canvas, width, height);

    // Add clipping to ensure stripes stay within shirt boundary
    canvas.save();
    canvas.clipPath(shirtPath);

    // Draw stripes with one at the center, showing only 5 stripes total
    final int stripeCount = 5; // Changed from 7 to 5
    final double stripeWidth = width * 0.08;

    // Calculate where stripes should start to have one centered
    final double centerX = width / 2;
    final double centerStripeStart = centerX - (stripeWidth / 2);

    // Define starting positions for the stripes
    List<double> startPositions = [];

    // Add center stripe first
    startPositions.add(centerStripeStart);

    // Add stripes to the left of center (only 2 now)
    for (int i = 1; i <= stripeCount ~/ 2; i++) {
      startPositions.add(centerStripeStart - (i * stripeWidth * 2));
    }

    // Add stripes to the right of center (only 2 now)
    for (int i = 1; i <= stripeCount ~/ 2; i++) {
      startPositions.add(centerStripeStart + (i * stripeWidth * 2));
    }

    // Sort positions for consistent drawing order
    startPositions.sort();

    // Create a random generator for stripe variation
    final random = math.Random(42);

    // Draw each enhanced stripe with more realistic color variations
    for (int i = 0; i < startPositions.length; i++) {
      double startX = startPositions[i];
      Path stripePath = Path();

      // Check if this is the leftmost or rightmost stripe
      bool isLeftmost = (i == 0);
      bool isRightmost = (i == startPositions.length - 1);

      if (isLeftmost || isRightmost) {
        // For outermost stripes, create a tapered path (wider at top, narrower at bottom)
        double topWidth = stripeWidth * 1.3; // 50% wider at top
        double bottomWidth = 0; // 30% narrower at bottom

        if (isLeftmost) {
          // Leftmost stripe tapering
          stripePath.moveTo(startX, 0);
          stripePath.lineTo(startX + 15, height * 1.05);
          stripePath.lineTo(startX + stripeWidth * 1.2, height);
          stripePath.lineTo(startX + topWidth, 0);
        } else {
          // Rightmost stripe tapering
          stripePath.moveTo(startX - 2, 0);
          stripePath.lineTo(startX + 2, height * 1.05);
          stripePath.lineTo(startX + bottomWidth + 3, height);
          stripePath.lineTo((startX) + topWidth, 0);
        }
      } else {
        // Regular straight stripes for middle ones
        stripePath.moveTo(startX, 0);
        stripePath.lineTo(startX, height * 1.2);
        stripePath.lineTo(startX + stripeWidth, height);
        stripePath.lineTo(startX + stripeWidth, 0);
      }
      stripePath.close();

      // Enhanced stripe coloring with more realistic variations
      // Create base colors for the gradient - slightly varied for each stripe
      final Color baseStripeColor = HSLColor.fromColor(stripeColor)
          .withLightness(0.35 + random.nextDouble() * 0.1)
          .toColor();
      final Color lightStripeColor = HSLColor.fromColor(stripeColor)
          .withLightness(0.45 + random.nextDouble() * 0.05)
          .toColor();
      final Color darkStripeColor = HSLColor.fromColor(stripeColor)
          .withLightness(0.25 + random.nextDouble() * 0.05)
          .toColor();

      // Draw the stripe with enhanced gradient
      double actualWidth = isLeftmost || isRightmost
          ? stripeWidth * 1.5
          : stripeWidth; // Use wider shader for tapered stripes

      final Paint enhancedStripePaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lightStripeColor,
            baseStripeColor,
            darkStripeColor,
            baseStripeColor,
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ).createShader(Rect.fromLTWH(
            startX, 0, actualWidth, height * 1.05)); // Extended gradient height

      canvas.drawPath(stripePath, enhancedStripePaint);

      // Add subtle horizontal texture to stripes
      addStripeTexture(
          canvas,
          stripePath,
          startX,
          isLeftmost || isRightmost ? actualWidth : stripeWidth,
          height * 1.05); // Extended texture height
    }

    canvas.restore();

    // Draw outline last for clean edges
    canvas.drawPath(shirtPath, outlinePaint);

    // Add collar details
    drawCollarDetails(canvas, width, height);

    // Add sleeve wrinkles for more realism
    drawSleeveDetails(canvas, width, height);
  }

  // Add a new method to draw the drop shadow
  void drawShirtShadow(
      Canvas canvas, Path shirtPath, double width, double height) {
    // Create a shadow effect using MaskFilter
    final Paint shadowPaint = Paint()
      ..color = Colors.black.withAlpha(76) // changed from withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
      ..style = PaintingStyle.fill;

    // Create a path for the shadow (slightly offset to give 3D effect)
    Path shadowPath = Path.from(shirtPath);
    shadowPath =
        shadowPath.shift(const Offset(4, 6)); // Offset shadow to bottom-right

    // Draw the shadow first (before the shirt)
    canvas.drawPath(shadowPath, shadowPaint);
  }

  // New method for inner shadow effect
  void drawInnerShadow(
      Canvas canvas, Path shirtPath, double width, double height) {
    // Save the canvas state to restore later
    canvas.save();

    // Clip to the shirt path so inner shadow stays within shirt boundaries
    canvas.clipPath(shirtPath);

    // Create inner shadow near the edges of the shirt
    final Paint innerShadowPaint = Paint()
      ..color = Colors.black.withAlpha(18) // changed from withOpacity(0.07)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0;

    // Create a path slightly smaller than the shirt outline
    Path innerPath = Path.from(shirtPath);
    // Inset the path slightly to create inner shadow effect
    try {
      // Try with ui.PathMetrics approach (more accurate)
      ui.PathMetrics metrics = shirtPath.computeMetrics();
      if (metrics.isEmpty) {
        // Fallback if metrics are empty
        canvas.drawPath(shirtPath, innerShadowPaint);
      } else {
        // Draw the slightly offset inner path
        canvas.drawPath(innerPath, innerShadowPaint);
      }
    } catch (e) {
      // Fallback if the above approach fails
      canvas.drawPath(shirtPath, innerShadowPaint);
    }

    // Add highlights to enhance 3D effect
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withAlpha(26) // changed from withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    // Draw highlight on part of the shirt (top-left areas)
    Path highlightPath = Path();

    // Collar highlight
    highlightPath.moveTo(width * 0.42, height * 0.05);
    highlightPath.quadraticBezierTo(
        width * 0.48, height * 0.09, width * 0.50, height * 0.06);

    // Left shoulder highlight
    highlightPath.moveTo(width * 0.25, height * 0.05);
    highlightPath.quadraticBezierTo(
        width * 0.2, height * 0.12, width * 0.15, height * 0.18);

    // Draw the highlights
    canvas.drawPath(highlightPath, highlightPaint);

    canvas.restore();
  }

  void addFabricTexture(
      Canvas canvas, Path shirtPath, double width, double height) {
    // Create subtle noise texture pattern
    final Paint texturePaint = Paint()
      ..color = Colors.grey.withAlpha(13) // changed from withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Add horizontal fabric texture lines
    canvas.save();
    canvas.clipPath(shirtPath);

    final random = math.Random(42); // Fixed seed for consistent pattern
    for (int i = 0; i < 150; i++) {
      final y = random.nextDouble() * height;
      final startX = random.nextDouble() * width * 0.3;
      final lineWidth = width * (0.3 + random.nextDouble() * 0.4);

      canvas.drawLine(
          Offset(startX, y),
          Offset(startX + lineWidth, y + random.nextDouble() * 2 - 1),
          texturePaint);
    }

    canvas.restore();
  }

  void drawRealisticWrinkles(Canvas canvas, double width, double height) {
    final Paint wrinklePaint = Paint()
      ..color = Colors.grey.withAlpha(26) // changed from withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    // Add some wrinkles near the sides
    // Right side wrinkles
    Path rightWrinkle = Path();
    rightWrinkle.moveTo(width * 0.7, height * 0.3);
    rightWrinkle.quadraticBezierTo(
        width * 0.75, height * 0.35, width * 0.7, height * 0.4);
    canvas.drawPath(rightWrinkle, wrinklePaint);

    // Left side wrinkles
    Path leftWrinkle = Path();
    leftWrinkle.moveTo(width * 0.3, height * 0.3);
    leftWrinkle.quadraticBezierTo(
        width * 0.25, height * 0.35, width * 0.3, height * 0.4);
    canvas.drawPath(leftWrinkle, wrinklePaint);

    // Bottom wrinkles
    Path bottomWrinkle = Path();
    bottomWrinkle.moveTo(width * 0.4, height * 0.85);
    bottomWrinkle.quadraticBezierTo(
        width * 0.5, height * 0.50, width * 0.6, height * 0.85);
    canvas.drawPath(bottomWrinkle, wrinklePaint);
  }

  void drawCollarDetails(Canvas canvas, double width, double height) {
    final Paint collarPaint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw enhanced ribbed collar detail - higher and more detailed
    Path collarPath = Path();

    // Outer collar line - deeper and higher
    collarPath.moveTo(width * 0.43, height * 0.01);
    collarPath.quadraticBezierTo(
        width * 0.5,
        height * 0.08, // Increased depth
        width * 0.57,
        height * 0.01);
    canvas.drawPath(collarPath, collarPaint);

    // Inner collar line for more dimension
    Path innerCollarPath = Path();
    innerCollarPath.moveTo(width * 0.44, height * 0.02);
    innerCollarPath.quadraticBezierTo(
        width * 0.5, height * 0.07, width * 0.56, height * 0.02);
    canvas.drawPath(innerCollarPath, collarPaint);

    // Add collar ribs for texture
    final Paint ribPaint = Paint()
      ..color = const Color.fromARGB(153, 189, 189, 189)
          .withAlpha(127) // changed from withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    // Draw some thin ribs along the collar
    for (int i = 1; i <= 3; i++) {
      final double offset = i * 0.005;
      Path ribPath = Path();
      ribPath.moveTo(width * (0.44 - offset), height * (0.02 + offset));
      ribPath.quadraticBezierTo(width * 0.5, height * (0.07 + offset * 0.5),
          width * (0.56 + offset), height * (0.02 + offset));
      canvas.drawPath(ribPath, ribPaint);
    }
  }

  void drawSleeveDetails(Canvas canvas, double width, double height) {
    final Paint sleevePaint = Paint()
      ..color = Colors.grey.withAlpha(26) // changed from withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Right sleeve wrinkles
    Path rightSleeveWrinkle = Path();
    rightSleeveWrinkle.moveTo(width * 0.9, height * 0.18);
    rightSleeveWrinkle.quadraticBezierTo(
        width * 0.95, height * 0.21, width * 0.92, height * 0.24);
    canvas.drawPath(rightSleeveWrinkle, sleevePaint);

    // Left sleeve wrinkles - mirrored from right sleeve
    Path leftSleeveWrinkle = Path();
    leftSleeveWrinkle.moveTo(width * 0.1, height * 0.18);
    leftSleeveWrinkle.quadraticBezierTo(
        width * 0.05, height * 0.21, width * 0.08, height * 0.24);

    // Additional left sleeve wrinkle to match right side
    Path leftSleeveWrinkle2 = Path();
    leftSleeveWrinkle2.moveTo(width * 0.05, height * 0.22);
    leftSleeveWrinkle2.quadraticBezierTo(
        width * 0.02, height * 0.24, width * 0.04, height * 0.26);

    canvas.drawPath(leftSleeveWrinkle, sleevePaint);
    canvas.drawPath(leftSleeveWrinkle2, sleevePaint);
  }

  // New method to add texture to stripes
  void addStripeTexture(Canvas canvas, Path stripePath, double startX,
      double stripeWidth, double height) {
    final Paint texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.3;

    canvas.save();
    canvas.clipPath(stripePath);

    final random =
        math.Random(42 + startX.toInt()); // Different pattern for each stripe

    // Add subtle horizontal line texture
    for (int i = 0; i < 40; i++) {
      final double y = random.nextDouble() * height;
      final double alpha = 0.05 + random.nextDouble() * 0.05;
      final int alphaInt = (alpha * 255).round();

      texturePaint.color = i % 2 == 0
          ? Colors.white.withAlpha(alphaInt) // changed from withOpacity
          : Colors.black.withAlpha(alphaInt); // changed from withOpacity

      canvas.drawLine(
        Offset(startX, y),
        Offset(startX + stripeWidth, y),
        texturePaint,
      );
    }

    // Add some random dots for fabric texture
    texturePaint.strokeWidth = 0.5;
    for (int i = 0; i < 30; i++) {
      final double x = startX + random.nextDouble() * stripeWidth;
      final double y = random.nextDouble() * height;
      final double dotSize = 0.5 + random.nextDouble();

      texturePaint.color = random.nextBool()
          ? Colors.white.withAlpha(13) // changed from withOpacity(0.05)
          : Colors.black.withAlpha(13); // changed from withOpacity(0.05)

      canvas.drawCircle(Offset(x, y), dotSize, texturePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
