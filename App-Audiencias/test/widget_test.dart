import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app_audiencias/widgets/ui_components.dart';

void main() {
  testWidgets('muestra el boton personalizado', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomButton(label: 'Guardar Audiencia', onPressed: _noop),
        ),
      ),
    );

    expect(find.text('Guardar Audiencia'), findsOneWidget);
    expect(find.byType(CustomButton), findsOneWidget);
  });
}

void _noop() {}
