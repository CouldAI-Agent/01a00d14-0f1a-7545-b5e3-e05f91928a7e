import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const AurbApp());
}

class AurbApp extends StatelessWidget {
  const AurbApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aurb - هوش مصنوعی صوتی',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(
          primary: Colors.deepPurple,
          secondary: Colors.cyanAccent,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  double _currentVolume = 0.5; // Mock volume for wave amplitude

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    // Simulate AI initiating conversation and volume changes
    _simulateConversation();
  }

  void _simulateConversation() async {
    // In a real app, this would tie to microphone input and AI audio output streams.
    while (mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        // Randomly fluctuate volume to simulate talking/listening
        _currentVolume = 0.3 + Random().nextDouble() * 0.7;
      });
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_waveController, _pulseController]),
          builder: (context, child) {
            return CustomPaint(
              size: const Size(300, 300),
              painter: AurbSpherePainter(
                wavePhase: _waveController.value * 2 * pi,
                pulse: _pulseController.value,
                volume: _currentVolume,
              ),
            );
          },
        ),
      ),
    );
  }
}

class AurbSpherePainter extends CustomPainter {
  final double wavePhase;
  final double pulse;
  final double volume;

  AurbSpherePainter({
    required this.wavePhase,
    required this.pulse,
    required this.volume,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw background glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.deepPurple.withOpacity(0.5 + (pulse * 0.2)),
          Colors.black.withOpacity(0.0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius * 1.5));
    canvas.drawCircle(center, radius * 1.5, glowPaint);

    // Draw inner waves (cinematic 3D effect)
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final offset = (i * pi / 4);
      final amplitude = radius * 0.3 * volume * (1 + (i * 0.2));
      
      wavePaint.shader = LinearGradient(
        colors: [
          Colors.cyanAccent.withOpacity(0.8),
          Colors.purpleAccent.withOpacity(0.8),
          Colors.pinkAccent.withOpacity(0.8),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      path.moveTo(0, center.dy);
      for (double x = 0; x <= size.width; x++) {
        final normalizedX = x / size.width;
        final y = center.dy + sin(normalizedX * 2 * pi + wavePhase + offset) * amplitude * sin(normalizedX * pi);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }
    canvas.restore();

    // Draw 3D glass sphere reflection and shading
    final glassPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.3),
        radius: 0.8,
        colors: [
          Colors.white.withOpacity(0.6),
          Colors.white.withOpacity(0.1),
          Colors.black.withOpacity(0.5),
          Colors.black.withOpacity(0.8),
        ],
        stops: const [0.0, 0.4, 0.8, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    
    canvas.drawCircle(center, radius, glassPaint);

    // Highlight reflection
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(size.width * 0.15, size.height * 0.05, size.width * 0.5, size.height * 0.3));
    
    canvas.drawOval(
      Rect.fromLTWH(size.width * 0.15, size.height * 0.05, size.width * 0.5, size.height * 0.3),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant AurbSpherePainter oldDelegate) {
    return oldDelegate.wavePhase != wavePhase ||
           oldDelegate.pulse != pulse ||
           oldDelegate.volume != volume;
  }
}
