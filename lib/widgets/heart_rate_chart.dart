import 'package:flutter/material.dart';

/// Widget que dibuja una gráfica simple del historial de ritmo cardíaco
/// usando CustomPainter para renderizado eficiente
class HeartRateChart extends StatelessWidget {
  final List<int> historial;
  final Color color;

  const HeartRateChart({
    super.key,
    required this.historial,
    this.color = const Color(0xFFFF5252),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.show_chart, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                'Ritmo Cardíaco en Vivo',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Indicador de pulso animado
              _PulseIndicator(color: color),
            ],
          ),
          const SizedBox(height: 20),
          // Gráfica
          SizedBox(
            height: 120,
            child: historial.isEmpty
                ? Center(
                    child: Text(
                      'Esperando datos...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.4),
                        fontSize: 14,
                      ),
                    ),
                  )
                : CustomPaint(
                    size: const Size(double.infinity, 120),
                    painter: _HeartRateChartPainter(
                      data: historial,
                      color: color,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Indicador de pulso animado (punto que parpadea)
class _PulseIndicator extends StatefulWidget {
  final Color color;
  const _PulseIndicator({required this.color});

  @override
  State<_PulseIndicator> createState() => _PulseIndicatorState();
}

class _PulseIndicatorState extends State<_PulseIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.4 + _controller.value * 0.6),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: _controller.value * 0.5),
                blurRadius: 8 + _controller.value * 8,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// CustomPainter para dibujar la gráfica de líneas del ritmo cardíaco
class _HeartRateChartPainter extends CustomPainter {
  final List<int> data;
  final Color color;

  _HeartRateChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    // Calcular min y max para escalar
    final minVal = data.reduce((a, b) => a < b ? a : b).toDouble() - 5;
    final maxVal = data.reduce((a, b) => a > b ? a : b).toDouble() + 5;
    final range = maxVal - minVal;

    final path = Path();
    final fillPath = Path();

    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1).clamp(1, double.infinity)) * size.width;
      final y = size.height - ((data[i] - minVal) / range) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        // Curvas suaves usando cuadrática
        final prevX = ((i - 1) / (data.length - 1).clamp(1, double.infinity)) *
            size.width;
        final prevY =
            size.height - ((data[i - 1] - minVal) / range) * size.height;
        final midX = (prevX + x) / 2;

        path.cubicTo(midX, prevY, midX, y, x, y);
        fillPath.cubicTo(midX, prevY, midX, y, x, y);
      }
    }

    // Cerrar el área de relleno
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Dibujar relleno y línea
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);

    // Dibujar punto en el último valor
    if (data.isNotEmpty) {
      final lastX = size.width;
      final lastY = size.height -
          ((data.last - minVal) / range) * size.height;

      // Halo exterior
      canvas.drawCircle(
        Offset(lastX, lastY),
        8,
        Paint()..color = color.withValues(alpha: 0.2),
      );
      // Punto
      canvas.drawCircle(
        Offset(lastX, lastY),
        4,
        Paint()..color = color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HeartRateChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
