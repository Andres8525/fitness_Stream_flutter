import 'dart:async';
import 'package:flutter/material.dart';
import '../services/fitness_stream_service.dart';
import '../widgets/metric_card.dart';
import '../widgets/heart_rate_chart.dart';
import '../widgets/activity_status_widget.dart';

/// Pantalla principal del dashboard de fitness
/// Utiliza StreamBuilder para escuchar y reaccionar a los datos
/// emitidos por los StreamControllers en FitnessStreamService
class FitnessDashboardScreen extends StatefulWidget {
  const FitnessDashboardScreen({super.key});

  @override
  State<FitnessDashboardScreen> createState() => _FitnessDashboardScreenState();
}

class _FitnessDashboardScreenState extends State<FitnessDashboardScreen> {
  // Instancia del servicio que contiene los StreamControllers
  late final FitnessStreamService _fitnessService;

  // Metas diarias
  static const int _metaPasos = 10000;
  static const double _metaDistancia = 5.0; // km
  static const double _metaCalorias = 500.0;

  @override
  void initState() {
    super.initState();
    // Crear instancia del servicio de streams
    _fitnessService = FitnessStreamService();
  }

  @override
  void dispose() {
    // IMPORTANTE: Cerrar todos los StreamControllers para evitar memory leaks
    _fitnessService.dispose();
    super.dispose();
  }

  void _toggleActivity() {
    setState(() {
      if (_fitnessService.isActive) {
        _fitnessService.detenerSeguimiento();
      } else {
        _fitnessService.iniciarSeguimiento();
      }
    });
  }

  void _toggleMode() {
    setState(() {
      _fitnessService.toggleModoCorrer();
    });
  }

  void _resetData() {
    setState(() {
      _fitnessService.reiniciar();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== HEADER =====
              _buildHeader(),
              const SizedBox(height: 24),

              // ===== ESTADO DE ACTIVIDAD =====
              ActivityStatusWidget(
                isActive: _fitnessService.isActive,
                isRunning: _fitnessService.isRunning,
                onToggleActivity: _toggleActivity,
                onToggleMode: _toggleMode,
                onReset: _resetData,
              ),
              const SizedBox(height: 24),

              // ===== MÉTRICAS CON STREAMBUILDER =====
              // Cada StreamBuilder escucha un Stream diferente del servicio
              _buildMetricsGrid(),
              const SizedBox(height: 20),

              // ===== GRÁFICA DE RITMO CARDÍACO EN VIVO =====
              _buildHeartRateSection(),
              const SizedBox(height: 20),

              // ===== DATOS COMBINADOS (StreamBuilder con FitnessData) =====
              _buildCombinedDataSection(),
              const SizedBox(height: 20),

              // ===== INFO EDUCATIVA =====
              _buildInfoSection(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Encabezado de la app
  Widget _buildHeader() {
    return Row(
      children: [
        // Logo
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF00E676), Color(0xFF00BCD4)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.fitness_center, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FitStream',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Seguimiento en tiempo real con Streams',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        // Badge de estado
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _fitnessService.isActive
                ? const Color(0xFF00E676).withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _fitnessService.isActive
                  ? const Color(0xFF00E676).withValues(alpha: 0.4)
                  : Colors.white12,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _fitnessService.isActive
                      ? const Color(0xFF00E676)
                      : Colors.white38,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                _fitnessService.isActive ? 'LIVE' : 'OFF',
                style: TextStyle(
                  color: _fitnessService.isActive
                      ? const Color(0xFF00E676)
                      : Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Grid de métricas usando StreamBuilder individual para cada dato
  Widget _buildMetricsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de sección
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '📊 Métricas en Vivo (StreamBuilder)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Grid 2x2
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.95,
          children: [
            // ========================================
            // StreamBuilder #1: Stream de PASOS
            // Escucha: _fitnessService.pasosStream
            // ========================================
            StreamBuilder<int>(
              stream: _fitnessService.pasosStream,
              initialData: 0,
              builder: (context, snapshot) {
                final pasos = snapshot.data ?? 0;
                return MetricCard(
                  titulo: 'PASOS',
                  valor: _formatNumber(pasos),
                  unidad: 'pasos',
                  icono: Icons.directions_walk,
                  color: const Color(0xFF00E676),
                  progreso: pasos / _metaPasos,
                );
              },
            ),

            // ========================================
            // StreamBuilder #2: Stream de RITMO CARDÍACO
            // Escucha: _fitnessService.ritmoCardiacoStream
            // ========================================
            StreamBuilder<int>(
              stream: _fitnessService.ritmoCardiacoStream,
              initialData: 72,
              builder: (context, snapshot) {
                final bpm = snapshot.data ?? 72;
                return MetricCard(
                  titulo: 'RITMO CARDÍACO',
                  valor: '$bpm',
                  unidad: 'BPM',
                  icono: Icons.favorite,
                  color: const Color(0xFFFF5252),
                );
              },
            ),

            // ========================================
            // StreamBuilder #3: Stream de DISTANCIA
            // Escucha: _fitnessService.distanciaStream
            // ========================================
            StreamBuilder<double>(
              stream: _fitnessService.distanciaStream,
              initialData: 0.0,
              builder: (context, snapshot) {
                final distancia = snapshot.data ?? 0.0;
                return MetricCard(
                  titulo: 'DISTANCIA',
                  valor: distancia.toStringAsFixed(2),
                  unidad: 'km',
                  icono: Icons.place,
                  color: const Color(0xFF448AFF),
                  progreso: distancia / _metaDistancia,
                );
              },
            ),

            // ========================================
            // StreamBuilder #4: Stream de CALORÍAS
            // Escucha: _fitnessService.caloriasStream
            // ========================================
            StreamBuilder<double>(
              stream: _fitnessService.caloriasStream,
              initialData: 0.0,
              builder: (context, snapshot) {
                final calorias = snapshot.data ?? 0.0;
                return MetricCard(
                  titulo: 'CALORÍAS',
                  valor: calorias.toStringAsFixed(1),
                  unidad: 'kcal',
                  icono: Icons.local_fire_department,
                  color: const Color(0xFFFF9800),
                  progreso: calorias / _metaCalorias,
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Sección de gráfica de ritmo cardíaco usando StreamBuilder
  Widget _buildHeartRateSection() {
    // ========================================
    // StreamBuilder #5: Stream de HISTORIAL DE RITMO
    // Escucha: _fitnessService.historialRitmoStream
    // ========================================
    return StreamBuilder<List<int>>(
      stream: _fitnessService.historialRitmoStream,
      initialData: const [],
      builder: (context, snapshot) {
        final historial = snapshot.data ?? [];
        return HeartRateChart(historial: historial);
      },
    );
  }

  /// Sección que muestra los datos combinados usando un solo StreamBuilder
  Widget _buildCombinedDataSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            '🔄 Stream Combinado (FitnessData)',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // ========================================
        // StreamBuilder #6: Stream COMBINADO (FitnessData)
        // Escucha: _fitnessService.fitnessDataStream
        // Un solo stream que contiene todos los datos
        // ========================================
        StreamBuilder<dynamic>(
          stream: _fitnessService.fitnessDataStream,
          builder: (context, snapshot) {
            // Manejo de estados del snapshot
            if (snapshot.hasError) {
              return _buildErrorCard(snapshot.error.toString());
            }

            if (!snapshot.hasData) {
              return _buildWaitingCard();
            }

            final data = snapshot.data;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E3A).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF7C4DFF).withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C4DFF).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.stream,
                          color: Color(0xFF7C4DFF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Stream Combinado',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Todos los datos en un solo StreamBuilder',
                              style: TextStyle(
                                color: Colors.white38,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // ConnectionState badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getConnectionColor(snapshot.connectionState)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          snapshot.connectionState.name.toUpperCase(),
                          style: TextStyle(
                            color:
                                _getConnectionColor(snapshot.connectionState),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Datos del snapshot
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDataRow('Pasos', '${data.pasos}', Icons.directions_walk),
                        const SizedBox(height: 8),
                        _buildDataRow(
                          'Distancia',
                          '${data.distanciaKm.toStringAsFixed(3)} km',
                          Icons.place,
                        ),
                        const SizedBox(height: 8),
                        _buildDataRow(
                          'Ritmo',
                          '${data.ritmoCardiaco} BPM',
                          Icons.favorite,
                        ),
                        const SizedBox(height: 8),
                        _buildDataRow(
                          'Calorías',
                          '${data.caloriasQuemadas.toStringAsFixed(2)} kcal',
                          Icons.local_fire_department,
                        ),
                        const SizedBox(height: 8),
                        _buildDataRow(
                          'Timestamp',
                          _formatTime(data.timestamp),
                          Icons.access_time,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  /// Fila de dato individual en el stream combinado
  Widget _buildDataRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white38),
        const SizedBox(width: 10),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// Sección informativa sobre el uso de Streams
  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF00BCD4), size: 20),
              SizedBox(width: 10),
              Text(
                '¿Cómo funcionan los Streams aquí?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoItem(
            '1. StreamController',
            'Cada métrica (pasos, ritmo, distancia, calorías) tiene su propio StreamController<T>.broadcast() que permite múltiples listeners.',
          ),
          _buildInfoItem(
            '2. sink.add()',
            'El servicio usa sink.add(valor) para emitir nuevos datos cada segundo, simulando un sensor real del dispositivo.',
          ),
          _buildInfoItem(
            '3. StreamBuilder',
            'Cada widget usa StreamBuilder<T> para escuchar su stream correspondiente y reconstruirse automáticamente con los nuevos datos.',
          ),
          _buildInfoItem(
            '4. dispose()',
            'Al cerrar la pantalla, se llama dispose() para cerrar todos los StreamControllers y evitar memory leaks.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00E676),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12.5,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tarjeta de estado de espera
  Widget _buildWaitingCard() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E3A).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1.5,
        ),
      ),
      child: const Center(
        child: Column(
          children: [
            CircularProgressIndicator(
              color: Color(0xFF7C4DFF),
              strokeWidth: 2.5,
            ),
            SizedBox(height: 16),
            Text(
              'Esperando datos del Stream...\nPresiona "Iniciar" para comenzar',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white38,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tarjeta de error
  Widget _buildErrorCard(String error) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF5252).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFFF5252).withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF5252)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: $error',
              style: const TextStyle(color: Color(0xFFFF5252), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color según el estado de conexión del Stream
  Color _getConnectionColor(ConnectionState state) {
    switch (state) {
      case ConnectionState.none:
        return Colors.grey;
      case ConnectionState.waiting:
        return const Color(0xFFFF9800);
      case ConnectionState.active:
        return const Color(0xFF00E676);
      case ConnectionState.done:
        return const Color(0xFFFF5252);
    }
  }

  /// Formatea un número con separador de miles
  String _formatNumber(int number) {
    if (number < 1000) return '$number';
    return '${(number / 1000).toStringAsFixed(1)}k';
  }

  /// Formatea un timestamp a hora legible
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}:'
        '${time.second.toString().padLeft(2, '0')}';
  }
}
