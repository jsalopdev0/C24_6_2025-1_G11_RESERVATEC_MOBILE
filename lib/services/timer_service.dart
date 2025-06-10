import 'dart:async';

class TimerService {
  static const int _duracionSoft = 180; // Solo visual (3 minutos en Seleccionar Horario)
  static int segundosRestantes = _duracionSoft;
  static Timer? _timer;

  static final _controller = StreamController<int>.broadcast();
  static Stream<int> get stream => _controller.stream;

  /// Inicia el contador con duración fija (soft) o real (desde Redis)
  static void iniciar({int? desdeRedis}) {
    final duracion = desdeRedis ?? _duracionSoft;
    segundosRestantes = duracion;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      segundosRestantes--;
      if (segundosRestantes <= 0) {
        _controller.add(0);
        detener();
      } else {
        _controller.add(segundosRestantes);
      }
    });
  }

  static void detener() {
    _timer?.cancel();
    segundosRestantes = 0;
    _controller.add(0);
  }

  static void reiniciar() => iniciar();
}
