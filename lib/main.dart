import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valentine\'s Effects',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const EffectsPage(),
    );
  }
}

class EffectsPage extends StatefulWidget {
  const EffectsPage({super.key});

  @override
  State<EffectsPage> createState() => _EffectsPageState();
}

class _EffectsPageState extends State<EffectsPage> with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  final List<FloatingObject> _floatingObjects = [];
  late Timer _timer;
  final List<Color> _balloonColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.blueAccent,
    Colors.green,
  ];

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    
    // Create floating objects every second
    _timer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_floatingObjects.length < 30) { // Limit the total number of objects
        setState(() {
          // Add a heart
          if (Random().nextBool()) {
            _floatingObjects.add(FloatingObject(
              x: Random().nextDouble() * 300,
              y: MediaQuery.of(context).size.height,
              isHeart: true,
              color: Colors.red,
            ));
          } 
          // Add a balloon
          else {
            _floatingObjects.add(FloatingObject(
              x: Random().nextDouble() * 300,
              y: MediaQuery.of(context).size.height,
              isHeart: false,
              color: _balloonColors[Random().nextInt(_balloonColors.length)],
            ));
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update floating objects position
    for (var object in _floatingObjects) {
      object.y -= 2; // Move upward
      object.x += sin(object.y / 30) * 2; // Add wavy motion
    }

    // Remove objects that are off screen
    _floatingObjects.removeWhere((object) => object.y < -50);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text('Valentine\'s Effects'),
        backgroundColor: Colors.red[100],
      ),
      body: Stack(
        children: [
          // Floating objects
          ..._floatingObjects.map((object) => Positioned(
                left: object.x,
                top: object.y,
                child: object.isHeart
                    ? Icon(
                        Icons.favorite,
                        color: object.color,
                        size: 30,
                      )
                    : CustomPaint(
                        size: const Size(40, 50),
                        painter: BalloonPainter(color: object.color),
                      ),
              )),
          
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: pi / 2,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              shouldLoop: false,
              colors: const [
                Colors.red,
                Colors.pink,
                Colors.white,
                Colors.purple,
              ],
            ),
          ),

          // Center button
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _confettiController.play();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[400],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Celebrate Love!',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FloatingObject {
  double x;
  double y;
  bool isHeart;
  Color color;
  FloatingObject({
    required this.x, 
    required this.y, 
    required this.isHeart,
    required this.color,
  });
}

class BalloonPainter extends CustomPainter {
  final Color color;

  BalloonPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw balloon
    final balloonPath = Path()
      ..moveTo(size.width / 2, size.height / 4)
      ..addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 4),
        radius: size.width / 2,
      ));

    // Draw string
    final stringPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final stringPath = Path()
      ..moveTo(size.width / 2, size.height / 2)
      ..quadraticBezierTo(
        size.width / 2 - 10,
        size.height * 0.7,
        size.width / 2,
        size.height,
      );

    canvas.drawPath(balloonPath, paint);
    canvas.drawPath(stringPath, stringPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
