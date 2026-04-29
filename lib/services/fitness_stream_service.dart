import 'dart:async';
import 'dart:math';
import '../models/fitness_data.dart';

class FitnessStreamService {

  final StreamController<int> _pasosController =
      StreamController<int>.broadcast();

  
  final StreamController<int> _ritmoCardiacoController =
      StreamController<int>.broadcast();

 
  final StreamController<double> _distanciaController =
      StreamController<double>.broadcast();

  
  final StreamController<double> _caloriasController =
      StreamController<double>.broadcast();

  
  final StreamController<FitnessData> _fitnessDataController =
      StreamController<FitnessData>.broadcast();

 
  final StreamController<List<int>> _historialRitmoController =
      StreamController<List<int>>.broadcast();

 
  Stream<int> get pasosStream => _pasosController.stream;

  
  Stream<int> get ritmoCardiacoStream => _ritmoCardiacoController.stream;

  
  Stream<double> get distanciaStream => _distanciaController.stream;

  
  Stream<double> get caloriasStream => _caloriasController.stream;

  
  Stream<FitnessData> get fitnessDataStream => _fitnessDataController.stream;

 
  Stream<List<int>> get historialRitmoStream =>
      _historialRitmoController.stream;



  final Random _random = Random();
  Timer? _simulationTimer;
  bool _isActive = false;
  bool _isRunning = false; 

  int _pasos = 0;
  double _distancia = 0.0;
  int _ritmoCardiaco = 72;
  double _calorias = 0.0;
  final List<int> _historialRitmo = [];


  bool get isActive => _isActive;
  bool get isRunning => _isRunning;
  int get pasosActuales => _pasos;
  double get distanciaActual => _distancia;
  int get ritmoActual => _ritmoCardiaco;
  double get caloriasActuales => _calorias;

  
  void iniciarSeguimiento() {
    if (_isActive) return;
    _isActive = true;

    
    _emitirDatos();

    
    _simulationTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _generarDatosSimulados(),
    );
  }

 
  void detenerSeguimiento() {
    _isActive = false;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

 
  void toggleModoCorrer() {
    _isRunning = !_isRunning;
  }

  
  void reiniciar() {
    _pasos = 0;
    _distancia = 0.0;
    _ritmoCardiaco = 72;
    _calorias = 0.0;
    _historialRitmo.clear();
    _emitirDatos();
  }

  
  void _generarDatosSimulados() {
    if (!_isActive) return;

  
    final nuevosPasos = _isRunning
        ? _random.nextInt(4) + 3 
        : _random.nextInt(3) + 1; 
    _pasos += nuevosPasos;

  
    final zancada = _isRunning ? 1.2 : 0.7;
    _distancia += (nuevosPasos * zancada) / 1000; 

   
    int ritmoObjetivo;
    if (_isRunning) {
      ritmoObjetivo = 140 + _random.nextInt(31); 
    } else {
      ritmoObjetivo = 90 + _random.nextInt(31); 
    }
    
    _ritmoCardiaco =
        _ritmoCardiaco + (((ritmoObjetivo - _ritmoCardiaco) * 0.3).round());
    _ritmoCardiaco += _random.nextInt(5) - 2; 


    _historialRitmo.add(_ritmoCardiaco);
    if (_historialRitmo.length > 30) {
      _historialRitmo.removeAt(0);
    }

  
    final calPorPaso = _isRunning ? 0.08 : 0.04;
    _calorias += nuevosPasos * calPorPaso;

    
    _emitirDatos();
  }

  
  void _emitirDatos() {
    
    _pasosController.sink.add(_pasos);
    _ritmoCardiacoController.sink.add(_ritmoCardiaco);
    _distanciaController.sink.add(_distancia);
    _caloriasController.sink.add(_calorias);
    _historialRitmoController.sink.add(List.from(_historialRitmo));

    
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
