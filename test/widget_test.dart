import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shoppro/main.dart';

void main() {
  testWidgets('Test de démarrage ShopPro', (WidgetTester tester) async {
    // Construire l'application
    await tester.pumpWidget(const ShopProApp());

    // Vérifier que le Splash Screen s'affiche
    expect(find.text('ShopPro'), findsOneWidget);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}