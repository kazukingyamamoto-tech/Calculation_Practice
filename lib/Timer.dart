import 'dart:async';

class CalculationTimer {
  final _stopwatch = Stopwatch();
  Timer? _timer;

  void Function(String)? onTick;

  void start() {
    _stopwatch.reset();
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (onTick != null) {
        onTick!(_formatTime);
      }
    });
  }

  void stop() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  String get _formatTime {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(_stopwatch.elapsed.inMinutes.remainder(60));
    String seconds = twoDigits(_stopwatch.elapsed.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  Duration get elapsed => _stopwatch.elapsed;
}
