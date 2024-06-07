import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[Colors.grey,Colors.lightBlueAccent]
            )
        ),
        child: const DetailMenu(),
      ),
    );
  }
}


class DetailMenu extends StatelessWidget {
  const DetailMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> imageNames = [
      'light_rain_noon.png',
      'heavy_rain.png',
      'sunny.png',
      'sunny.png',
      'light_rain_noon.png',
      'heavy_rain.png',
      'heavy_rain.png',
      'heavy_rain.png',
      'heavy_rain.png',
      'sunny.png',
      'sunny.png',
      'sunny.png'
    ];

    return SizedBox(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 30, right: 15),
            child: Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'images/registration.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 8),
                  Image.asset(
                    'images/Change.png',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  '梅田',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Image.asset(
                  'images/heavy_rain.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 5),
                const Text(
                  '45°C',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 70),
                CustomPaint(
                  size: const Size(double.infinity, 3),
                  painter: StraightLinePainter(),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 120,
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageNames.length,
                      controller: PageController(initialPage: 2, viewportFraction: 0.2),
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Text(
                              ' ${index + 1} pm',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Image.asset(
                              'images/${imageNames[index]}',
                              width: 75,
                              height: 75,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${index + 1} °C',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 1),
                CustomPaint(
                  size: const Size(double.infinity, 3),
                  painter: StraightLinePainter(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StraightLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
