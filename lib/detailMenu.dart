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
                  const SizedBox(height: 5), // Space between the text and the image
                  Center(
                    child: Image.asset(
                      'images/registration.png', // Image asset path for the image under the text
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
