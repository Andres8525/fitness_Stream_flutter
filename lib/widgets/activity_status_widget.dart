import 'package:flutter/material.dart';

/// Widget que muestra el estado actual del ejercicio (Caminando/Corriendo)
/// con un indicador animado
class ActivityStatusWidget extends StatelessWidget {
  final bool isActive;
  final bool isRunning;
  final VoidCallback onToggleActivity;
  final VoidCallback onToggleMode;
  final VoidCallback onReset;

  const ActivityStatusWidget({
    super.key,
    required this.isActive,
    required this.isRunning,
    required this.onToggleActivity,
    required this.onToggleMode,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isActive
              ? [
                  const Color(0xFF00E676).withValues(alpha: 0.2),
                  const Color(0xFF00BCD4).withValues(alpha: 0.2),
                ]
              : [
                  const Color(0xFF1E1E3A).withValues(alpha: 0.7),
                  const Color(0xFF1E1E3A).withValues(alpha: 0.7),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isActive
              ? const Color(0xFF00E676).withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Estado
          Row(
            children: [
              // Icono animado
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isActive
                      ? (isRunning
                          ? const Color(0xFFFF9800).withValues(alpha: 0.2)
                          : const Color(0xFF00E676).withValues(alpha: 0.2))
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isActive
                      ? (isRunning
                          ? Icons.directions_run
                          : Icons.directions_walk)
                      : Icons.pause_circle_outline,
                  color: isActive
                      ? (isRunning
                          ? const Color(0xFFFF9800)
                          : const Color(0xFF00E676))
                      : Colors.white54,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              // Texto de estado
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isActive
                          ? (isRunning ? '🏃 Corriendo' : '🚶 Caminando')
                          : '⏸️ En Pausa',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive
                          ? 'Datos actualizándose en tiempo real vía Stream'
                          : 'Presiona iniciar para comenzar el seguimiento',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Botones de control
          Row(
            children: [
              // Botón Iniciar/Detener
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onToggleActivity,
                  icon: Icon(
                    isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                    size: 22,
                  ),
                  label: Text(
                    isActive ? 'Detener' : 'Iniciar',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isActive
                        ? const Color(0xFFFF5252)
                        : const Color(0xFF00E676),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón Modo Caminar/Correr
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: isActive ? onToggleMode : null,
                  icon: Icon(
                    isRunning ? Icons.directions_walk : Icons.directions_run,
                    size: 22,
                  ),
                  label: Text(
                    isRunning ? 'Caminar' : 'Correr',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isRunning
                        ? const Color(0xFF00BCD4).withValues(alpha: 0.3)
                        : const Color(0xFFFF9800).withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.white.withValues(alpha: 0.05),
                    disabledForegroundColor: Colors.white24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Botón Reset
              IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded),
                color: Colors.white54,
                tooltip: 'Reiniciar',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.05),
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
