import 'package:flutter/material.dart';

void main() => runApp(
  Directionality(
    textDirection: TextDirection.ltr,
    child: Container(
      color: const Color(0xFF79CAE7), // Blue color
      child: const DetailMenu(),
    ),
  ),
);

class DetailMenu extends StatelessWidget {
  const DetailMenu({super.key});

  @override
  Widget build(BuildContext context) {
    // List of image names
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
      width: 340, // Adjust as needed
      height: 740, // Adjust as needed
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 20, right: 20), // Added padding
            child: Align(
              alignment: Alignment.topRight,
              child: Row(
                mainAxisSize: MainAxisSize.min, // Shrinks the Row to fit its children
                children: [
                  Image.asset(
                    'images/registration.png', // First image asset path
                    width: 40, // Adjust as needed
                    height: 40, // Adjust as needed
                    fit: BoxFit.cover, // Ensures the image covers the entire space allocated by its parent
                  ),
                  const SizedBox(width: 8), // Adds space between the images
                  Image.asset(
                    'images/Change.png', // Second image asset path
                    width: 40, // Adjust as needed
                    height: 40, // Adjust as needed
                    fit: BoxFit.cover, // Ensures the image covers the entire space allocated by its parent
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 80), // Padding from the top
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Aligns children in the center horizontally
              children: [
                const Text(
                  '梅田', // Your text
                  style: TextStyle(
                    fontSize: 24, // Adjust as needed
                    color: Colors.white, // Adjust as needed
                  ),
                ),
                const SizedBox(height: 10), // Space between the text and the image
                Image.asset(
                  'images/heavy_rain.png', // Image asset path for the image under the text
                  width: 100, // Adjust as needed
                  height: 100, // Adjust as needed
                  fit: BoxFit.cover, // Ensures the image covers the entire space allocated by its parent
                ),
                const SizedBox(height: 5), // Space between the image and the text
                const Text(
                  '45°C', // Text under the image
                  style: TextStyle(
                    fontSize: 24, // Adjust as needed
                    color: Colors.white, // Adjust as needed
                  ),
                ),
                const SizedBox(height: 70), // Space before the new images

                CustomPaint(
                  size: const Size(double.infinity, 3), // Adjust height as needed
                  painter: StraightLinePainter(),
                ),
                const SizedBox(height: 10), // Space between the line and the images
                Align(
                  alignment: Alignment.centerLeft,
                  child: SizedBox(
                    height: 120, // Adjust height as needed
                    // Adjust width as needed
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageNames.length, // Total number of images
                      controller: PageController(initialPage: 2, viewportFraction: 0.2), // Show 5 images at a time without spacing
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            Text(
                              'Text ${index + 1}', // Sample text before the image
                              style: const TextStyle(
                                fontSize: 12, // Adjust as needed
                                color: Colors.white, // Adjust as needed
                              ),
                            ),
                            const SizedBox(height: 4), // Space between the text and the image
                            Image.asset(
                              'images/${imageNames[index]}', // Image asset path
                              width: 80, // Ensuring each image has a fixed width
                              height: 80, // Ensuring each image has a fixed height
                              fit: BoxFit.cover, // Ensures the image covers the entire space allocated by its parent
                            ),
                            const SizedBox(height: 4), // Space between the image and the text
                            Text(
                              'Text ${index + 1}', // Sample text under the image
                              style: const TextStyle(
                                fontSize: 12, // Adjust as needed
                                color: Colors.white, // Adjust as needed
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 1), // Space between the images and the line
                CustomPaint(
                  size: const Size(double.infinity, 3), // Adjust height as needed
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
