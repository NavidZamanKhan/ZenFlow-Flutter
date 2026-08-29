import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';

class SocialAuthButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isLoading;

  const SocialAuthButton({
    super.key,
    required this.onPressed,
    this.label = 'Continue with Google',
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return SizedBox(
      height: 48,
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: zen.surface,
          foregroundColor: zen.textPrimary,
          elevation: 0,
          side: BorderSide(color: zen.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(zen.textPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _GoogleLogo(),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: AppTextStyles.labelLarge(zen.textPrimary),
                  ),
                ],
              ),
      ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);
    final radius = w / 2;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Google Red
    final redPaint = Paint()..color = const Color(0xFFEA4335);
    canvas.drawArc(rect, -0.785, 1.57, true, redPaint);

    // Google Yellow
    final yellowPaint = Paint()..color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 0.785, 1.57, true, yellowPaint);

    // Google Green
    final greenPaint = Paint()..color = const Color(0xFF34A853);
    canvas.drawArc(rect, 2.356, 1.57, true, greenPaint);

    // Google Blue
    final bluePaint = Paint()..color = const Color(0xFF4285F4);
    canvas.drawArc(rect, 3.927, 1.57, true, bluePaint);

    // Inner cutout
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, innerPaint);

    // Blue horizontal bar
    final barRect = Rect.fromLTRB(w * 0.45, h * 0.35, w, h * 0.65);
    canvas.drawRect(barRect, bluePaint);

    // Cutout right angle
    final trianglePath = Path()
      ..moveTo(center.dx, center.dy)
      ..lineTo(w, h * 0.35)
      ..lineTo(w, 0)
      ..close();
    canvas.drawPath(trianglePath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
