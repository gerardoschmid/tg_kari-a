import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:karina_app/providers/deck_provider.dart';
import 'package:karina_app/views/decklist.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (context) => DeckProvider(),
        child: const MaterialApp(home: DeckList()),
      ),
    );

    // Verify that we are on the DeckList page
    expect(find.text('Kariña Learning'), findsOneWidget);
  });
}
