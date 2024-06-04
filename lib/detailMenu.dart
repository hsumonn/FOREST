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
      'light_rain.png',
      'heavy_rain.png',
      'sunny.png',
      'thunder.png',
      'light_rain.png',
      'heavy_rain.png',
      'heavy_rain.png',
      'heavy_rain.png',
      'heavy_rain.png',
      'sunny.png'
    ];

    return Center(
      child: SizedBox(
        width: 340, // Adjust as needed
        height: 740, // Adjust as needed
        child: Stack(
          children: [
            Align(
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
            Padding(
              padding: const EdgeInsets.only(top: 80), // Padding from the top
              child: Column(
                mainAxisSize: MainAxisSize.min, // Shrinks the Column to fit its children
                children: [
                  const Center(
                    child: Text(
                      '梅田', // Your text
                      style: TextStyle(
                        fontSize: 24, // Adjust as needed
                        color: Colors.white, // Adjust as needed
                      ),
                    ),
                  ),
                  const SizedBox(height: 10), // Space between the text and the image
                  Center(
                    child: Image.asset(
                      'images/heavy_rain.png', // Image asset path for the image under the text
                      width: 100, // Adjust as needed
                      height: 100, // Adjust as needed
                      fit: BoxFit.cover, // Ensures the image covers the entire space allocated by its parent
                    ),
                  ),
                  const SizedBox(height: 5), // Space between the image and the text
                  const Center(
                    child: Text(
                      '45°C', // Text under the image
                      style: TextStyle(
                        fontSize: 24, // Adjust as needed
                        color: Colors.white, // Adjust as needed
                      ),
                    ),
                  ),
                  const SizedBox(height: 70), // Space before the new images

                  CustomPaint(
                    size: const Size(double.infinity, 2), // Adjust height as needed
                    painter: StraightLinePainter(),
                  ),
                  const SizedBox(height: 10), // Space between the line and the images
                  SizedBox(
                    height: 80,

                    child: PageView.builder(

                      scrollDirection: Axis.horizontal,
                      itemCount: imageNames.length, // Total number of images
                      controller: PageController(viewportFraction: 1/4 ), // Show 4 images at a time without spacing
                      itemBuilder: (context, index) {
                        return Container(
                          //width: MediaQuery.of(context).size.width / 4, // Ensuring 4 images are shown
                          //margin: EdgeInsets.zero, // No margin between images
                          child: Image.asset(

                            'images/${imageNames[index]}', // Image asset path
                            //fit: BoxFit.cover, // Ensures the image covers the entire space allocated by its parent
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 10), // Space between the images and the line
                  CustomPaint(
                    size: const Size(double.infinity, 2), // Adjust height as needed
                    painter: StraightLinePainter(),
                  ),
                ],
              ),
            ),
          ],
        ),
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
