import 'dart:async';
import 'dart:math';
import '../models/fitness_data.dart';

/// Servicio que utiliza StreamControllers para emitir datos de actividad física
/// en tiempo real, simulando sensores del dispositivo.
///
/// Implementa 4 StreamControllers individuales:
/// - _pasosController: Stream de conteo de pasos
/// - _ritmoCardiacoController: Stream de ritmo cardíaco (BPM)
/// - _distanciaController: Stream de distancia recorrida (km)
/// - _caloriasController: Stream de calorías quemadas
///
/// Además, un StreamController combinado que emite FitnessData completo.
class FitnessStreamService {
  // ============================================================
  // StreamControllers individuales para cada métrica
  // ============================================================

  /// StreamController para el conteo de pasos
  /// Se usa broadcast para permitir múltiples listeners
  final StreamController<int> _pasosController =
      StreamController<int>.broadcast();

  /// StreamController para el ritmo cardíaco (BPM)
  final StreamController<int> _ritmoCardiacoController =
      StreamController<int>.broadcast();

  /// StreamController para la distancia recorrida (km)
  final StreamController<double> _distanciaController =
      StreamController<double>.broadcast();

  /// StreamController para las calorías quemadas
  final StreamController<double> _caloriasController =
      StreamController<double>.broadcast();

  /// StreamController combinado con todos los datos fitness
  final StreamController<FitnessData> _fitnessDataController =
      StreamController<FitnessData>.broadcast();

  /// StreamController para el historial de ritmo cardíaco (gráfica)
  final StreamController<List<int>> _historialRitmoController =
      StreamController<List<int>>.broadcast();

  // ============================================================
  // Streams públicos (solo lectura) - Getters
  // ============================================================

  /// Stream de pasos en tiempo real
  Stream<int> get pasosStream => _pasosController.stream;

  /// Stream de ritmo cardíaco en tiempo real
  Stream<int> get ritmoCardiacoStream => _ritmoCardiacoController.stream;

  /// Stream de distancia en tiempo real
  Stream<double> get distanciaStream => _distanciaController.stream;

  /// Stream de calorías en tiempo real
  Stream<double> get caloriasStream => _caloriasController.stream;

  /// Stream combinado de todos los datos fitness
  Stream<FitnessData> get fitnessDataStream => _fitnessDataController.stream;

  /// Stream del historial de ritmo cardíaco
  Stream<List<int>> get historialRitmoStream =>
      _historialRitmoController.stream;

  // ============================================================
  // Estado interno
  // ============================================================

  final Random _random = Random();
  Timer? _simulationTimer;
  bool _isActive = false;
  bool _isRunning = false; // Modo correr (más intenso)

  int _pasos = 0;
  double _distancia = 0.0;
  int _ritmoCardiaco = 72;
  double _calorias = 0.0;
  final List<int> _historialRitmo = [];

  // Getters de estado
  bool get isActive => _isActive;
  bool get isRunning => _isRunning;
  int get pasosActuales => _pasos;
  double get distanciaActual => _distancia;
  int get ritmoActual => _ritmoCardiaco;
  double get caloriasActuales => _calorias;

  // ============================================================
  // Métodos de control
  // ============================================================

  /// Inicia la simulación de datos del sensor fitness
  /// Emite datos cada segundo a través de los StreamControllers
  void iniciarSeguimiento() {
    if (_isActive) return;
    _isActive = true;

    // Emitir estado inicial
    _emitirDatos();

    // Timer periódico que simula la lectura de sensores cada segundo
    _simulationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _generarDatosSimulados(),
    );
  }

  /// Detiene la simulación de datos
  void detenerSeguimiento() {
    _isActive = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  /// Alterna entre modo caminar y modo correr
  void toggleModoCorrer() {
    _isRunning = !_isRunning;
  }

  /// Reinicia todos los contadores a cero
  void reiniciar() {
    _pasos = 0;
    _distancia = 0.0;
    _ritmoCardiaco = 72;
    _calorias = 0.0;
    _historialRitmo.clear();
    _emitirDatos();
  }

  // ============================================================
  // Lógica de simulación de datos
  // ============================================================

  /// Genera datos simulados que imitan sensores reales del dispositivo
  void _generarDatosSimulados() {
    if (!_isActive) return;

    // --- Simular pasos ---
    // Caminar: 1-3 pasos/seg, Correr: 3-6 pasos/seg
    final nuevosPasos = _isRunning
        ? _random.nextInt(4) + 3 // 3-6 pasos
        : _random.nextInt(3) + 1; // 1-3 pasos
    _pasos += nuevosPasos;

    // --- Simular distancia ---
    // Longitud promedio de zancada: caminar ~0.7m, correr ~1.2m
    final zancada = _isRunning ? 1.2 : 0.7;
    _distancia += (nuevosPasos * zancada) / 1000; // Convertir a km

    // --- Simular ritmo cardíaco ---
    // Reposo: 60-80 BPM, Caminando: 90-120 BPM, Corriendo: 130-170 BPM
    int ritmoObjetivo;
    if (_isRunning) {
      ritmoObjetivo = 140 + _random.nextInt(31); // 140-170
    } else {
      ritmoObjetivo = 90 + _random.nextInt(31); // 90-120
    }
    // Transición suave hacia el ritmo objetivo
    _ritmoCardiaco =
        _ritmoCardiaco + (((ritmoObjetivo - _ritmoCardiaco) * 0.3).round());
    _ritmoCardiaco += _random.nextInt(5) - 2; // Variación natural ±2

    // Guardar en historial (últimos 30 valores para la gráfica)
    _historialRitmo.add(_ritmoCardiaco);
    if (_historialRitmo.length > 30) {
      _historialRitmo.removeAt(0);
    }

    // --- Simular calorías ---
    // ~0.04 cal/paso caminando, ~0.08 cal/paso corriendo
    final calPorPaso = _isRunning ? 0.08 : 0.04;
    _calorias += nuevosPasos * calPorPaso;

    // Emitir todos los datos actualizados a los Streams
    _emitirDatos();
  }

  /// Emite los datos actuales a todos los StreamControllers
  void _emitirDatos() {
    // Emitir a streams individuales usando sink.add()
    _pasosController.sink.add(_pasos);
    _ritmoCardiacoController.sink.add(_ritmoCardiaco);
    _distanciaController.sink.add(_distancia);
    _caloriasController.sink.add(_calorias);
    _historialRitmoController.sink.add(List.from(_historialRitmo));

    // Emitir datos combinados al stream principal
    _fitnessDataController.sink.add(
      FitnessData(
        pasos: _pasos,
        distanciaKm: _distancia,
        ritmoCardiaco: _ritmoCardiaco,
        caloriasQuemadas: _calorias,
        timestamp: DateTime.now(),
      ),
    );
  }

  // ============================================================
  // Limpieza de recursos
  // ============================================================

  /// Cierra todos los StreamControllers para evitar memory leaks
  /// IMPORTANTE: Siempre cerrar los controllers cuando ya no se necesiten
  void dispose() {
    _simulationTimer?.cancel();
    _pasosController.close();
    _ritmoCardiacoController.close();
    _distanciaController.close();
    _caloriasController.close();
    _fitnessDataController.close();
    _historialRitmoController.close();
  }
}
