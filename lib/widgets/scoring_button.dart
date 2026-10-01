import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ScoringButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;
  final bool isLarge;

  const ScoringButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = color ?? AppColors.cardElevated;
    Color fg = textColor ?? Colors.white;

    // Distinct cricket styling
    switch (label) {
      case '0':
        bg = const Color(0xFF334155);
        fg = Colors.white70;
        break;
      case '1':
      case '2':
      case '3':
        bg = const Color(0xFF0284C7);
        fg = Colors.white;
        break;
      case '4':
        bg = AppColors.boundaryAmber;
        fg = Colors.black;
        break;
      case '6':
        bg = AppColors.sixPurple;
        fg = Colors.white;
        break;
      case 'W':
        bg = AppColors.liveRed;
        fg = Colors.white;
        break;
      case 'WD':
        bg = const Color(0xFFEA580C);
        fg = Colors.white;
        break;
      case 'NB':
        bg = const Color(0xFFD97706);
        fg = Colors.white;
        break;
      case 'B':
      case 'LB':
        bg = const Color(0xFF0D9488);
        fg = Colors.white;
        break;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: isLarge ? 64 : 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: bg.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: isLarge ? 22 : 18,
              fontWeight: FontWeight.w900,
              color: fg,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
