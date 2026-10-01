import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class WormChart extends StatelessWidget {
  final List<double> team1Runs;
  final List<double> team2Runs;
  final String team1Code;
  final String team2Code;
  final Color team1Color;
  final Color team2Color;

  const WormChart({
    super.key,
    required this.team1Runs,
    required this.team2Runs,
    required this.team1Code,
    required this.team2Code,
    this.team1Color = AppColors.boundaryAmber,
    this.team2Color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RUN PROGRESSION (WORM)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  _buildLegendDot(team1Code, team1Color),
                  const SizedBox(width: 12),
                  _buildLegendDot(team2Code, team2Color),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Custom Paint Graph
          SizedBox(
            height: 180,
            width: double.infinity,
            child: CustomPaint(
              painter: _WormChartPainter(
                team1Runs: team1Runs,
                team2Runs: team2Runs,
                team1Color: team1Color,
                team2Color: team2Color,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // X-Axis labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('0 ov', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('5 ov', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('10 ov', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('15 ov', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
              Text('20 ov', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _WormChartPainter extends CustomPainter {
  final List<double> team1Runs;
  final List<double> team2Runs;
  final Color team1Color;
  final Color team2Color;

  _WormChartPainter({
    required this.team1Runs,
    required this.team2Runs,
    required this.team1Color,
    required this.team2Color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const maxOvers = 20;
    const maxRuns = 220.0;

    final gridPaint = Paint()
      ..color = AppColors.border.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    // Draw horizontal grid lines (every 50 runs)
    for (int r = 50; r <= 200; r += 50) {
      final y = size.height - (r / maxRuns * size.height);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw vertical grid lines (every 5 overs)
    for (int o = 5; o <= 20; o += 5) {
      final x = (o / maxOvers) * size.width;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // Helper to get point
    Offset getPoint(int overIndex, double runs) {
      final x = ((overIndex + 1) / maxOvers) * size.width;
      final y = size.height - ((runs / maxRuns) * size.height).clamp(0.0, size.height);
      return Offset(x, y);
    }

    // Draw Team 1 Line
    _drawLine(canvas, size, team1Runs, team1Color, getPoint);

    // Draw Team 2 Line
    _drawLine(canvas, size, team2Runs, team2Color, getPoint);
  }

  void _drawLine(
    Canvas canvas,
    Size size,
    List<double> runsList,
    Color color,
    Offset Function(int overIndex, double runs) getPoint,
  ) {
    if (runsList.isEmpty) return;

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height);

    for (int i = 0; i < runsList.length; i++) {
      final pt = getPoint(i, runsList[i]);
      path.lineTo(pt.dx, pt.dy);
    }

    canvas.drawPath(path, linePaint);

    // Draw dots at points
    for (int i = 0; i < runsList.length; i++) {
      final pt = getPoint(i, runsList[i]);
      canvas.drawCircle(pt, 2.5, dotPaint);
    }

    // Draw glowing circle on latest point
    if (runsList.isNotEmpty) {
      final lastPt = getPoint(runsList.length - 1, runsList.last);
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(lastPt, 6.0, glowPaint);
      canvas.drawCircle(lastPt, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WormChartPainter oldDelegate) {
    return oldDelegate.team1Runs.length != team1Runs.length ||
        oldDelegate.team2Runs.length != team2Runs.length ||
        (team2Runs.isNotEmpty && oldDelegate.team2Runs.isNotEmpty && oldDelegate.team2Runs.last != team2Runs.last);
  }
}
