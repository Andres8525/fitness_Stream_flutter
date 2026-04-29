/// Modelo que representa los datos de actividad física en tiempo real
class FitnessData {
  final int pasos;
  final double distanciaKm;
  final int ritmoCardiaco;
  final double caloriasQuemadas;
  final DateTime timestamp;

  FitnessData({
    required this.pasos,
    required this.distanciaKm,
    required this.ritmoCardiaco,
    required this.caloriasQuemadas,
    required this.timestamp,
  });

  /// Crea una copia con valores actualizados
  FitnessData copyWith({
    int? pasos,
    double? distanciaKm,
    int? ritmoCardiaco,
    double? caloriasQuemadas,
    DateTime? timestamp,
  }) {
    return FitnessData(
      pasos: pasos ?? this.pasos,
      distanciaKm: distanciaKm ?? this.distanciaKm,
      ritmoCardiaco: ritmoCardiaco ?? this.ritmoCardiaco,
      caloriasQuemadas: caloriasQuemadas ?? this.caloriasQuemadas,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Datos iniciales (estado de reposo)
  factory FitnessData.initial() {
    return FitnessData(
      pasos: 0,
      distanciaKm: 0.0,
      ritmoCardiaco: 72,
      caloriasQuemadas: 0.0,
      timestamp: DateTime.now(),
    );
  }
}
