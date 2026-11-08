import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/main.dart';

void main() {
  testWidgets('Toggle tema mengganti light <-> dark', (tester) async {
    await tester.pumpWidget(const QuizApp());

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.light);

    await tester.tap(find.byIcon(Icons.dark_mode_rounded));
    await tester.pump();

    expect(app().themeMode, ThemeMode.dark);
  });
}
