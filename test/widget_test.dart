import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:umbrella/detail_menu.dart';

void main() {
  testWidgets('DetailMenu widget test', (WidgetTester tester) async {
    // Mock data or dependencies
    const String mockDescription = 'Mock Weather Description';
    const bool mockDayTime = true;
    const List<double> mockRainfallData = [0.2, 0.5, 0.8];
    const double mockRainProbability = 0.6;
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DetailMenu(
            onWeatherChange: (newDescription, dayTime, newRainfallData, newRainProbability) {
              // Assert that the callback receives the expected mock data
              expect(newDescription, mockDescription);
              expect(dayTime, mockDayTime);
              expect(newRainfallData, mockRainfallData);
              expect(newRainProbability, mockRainProbability);
            }, location: '',
          ),
        ),
      ),
    );

    // Verify if DetailMenu is displayed correctly.
    expect(find.byType(DetailMenu), findsOneWidget);
  });
}
