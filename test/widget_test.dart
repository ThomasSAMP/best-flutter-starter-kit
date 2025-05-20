import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_template/shared/widgets/app_button.dart';
import 'package:flutter_template/shared/widgets/app_text_field.dart';

void main() {
  group('AppButton', () {
    testWidgets('renders correctly with text', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppButton(text: 'Test Button', onPressed: null)),
        ),
      );

      // Verify that the button renders with the correct text.
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool buttonPressed = false;

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              text: 'Test Button',
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      // Tap the button and trigger a frame.
      await tester.tap(find.text('Test Button'));
      await tester.pump();

      // Verify that the button's onPressed callback was called.
      expect(buttonPressed, true);
    });
  });

  group('AppTextField', () {
    testWidgets('renders correctly with label', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              controller: TextEditingController(),
              label: 'Test Label',
            ),
          ),
        ),
      );

      // Verify that the text field renders with the correct label.
      expect(find.text('Test Label'), findsOneWidget);
    });

    testWidgets('validates input correctly', (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(
                controller: TextEditingController(),
                label: 'Test Label',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field cannot be empty';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Validate the form with empty input.
      formKey.currentState!.validate();
      await tester.pump();

      // Verify that the validation error message is displayed.
      expect(find.text('Field cannot be empty'), findsOneWidget);
    });
  });
}
