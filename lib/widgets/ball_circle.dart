import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BallCircle extends StatelessWidget {
  final String outcome;
  final double size;

  const BallCircle({
    super.key,
    required this.outcome,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor = Colors.white;
    Color borderColor;

    switch (outcome.toUpperCase()) {
      case 'W':
        bgColor = AppColors.liveRed;
        borderColor = AppColors.liveRed;
        break;
      case '4':
        bgColor = AppColors.boundaryAmber;
        textColor = Colors.black;
        borderColor = Colors.amber;
        break;
      case '6':
        bgColor = AppColors.sixPurple;
        borderColor = const Color(0xFFC77DFF);
        break;
      case '1':
      case '2':
      case '3':
        bgColor = AppColors.singleBlue.withValues(alpha: 0.2);
        borderColor = AppColors.singleBlue;
        textColor = AppColors.singleBlue;
        break;
      case '0':
        bgColor = AppColors.dotBallGrey.withValues(alpha: 0.3);
        borderColor = AppColors.border;
        textColor = AppColors.textSecondary;
        break;
      case 'WD':
      case 'NB':
        bgColor = Colors.deepOrange.withValues(alpha: 0.2);
        borderColor = Colors.deepOrange;
        textColor = Colors.deepOrangeAccent;
        break;
      default:
        bgColor = AppColors.cardElevated;
        borderColor = AppColors.border;
        textColor = AppColors.textPrimary;
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: outcome == 'W' || outcome == '6' || outcome == '4'
            ? [
                BoxShadow(
                  color: bgColor.withValues(alpha: 0.35),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Text(
        outcome,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}
