import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/providers/deck_provider.dart';
import 'package:karina_app/providers/game_provider.dart';
import 'package:karina_app/views/dashboard_screen.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => DeckProvider()),
          ChangeNotifierProvider(create: (context) => GameProvider()),
        ],
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    // Verify that we are on the DashboardScreen page
    expect(find.text('Kariña Learning'), findsOneWidget);
  });
}
