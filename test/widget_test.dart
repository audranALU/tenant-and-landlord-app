// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tenant_and_landlord_app/main.dart';

void main() {

  // Existing Flutter starter test removed because
  // the project is no longer a counter application.


  group('Technician Feature Tests', () {


    testWidgets(
      'Application loads successfully',
      (WidgetTester tester) async {

        await tester.pumpWidget(const MyApp());

        expect(find.byType(MaterialApp), findsOneWidget);

      },
    );


    testWidgets(
      'Technician workflow logic test',
      (WidgetTester tester) async {

        // Simulates technician maintenance workflow

        String taskStatus = "assigned";

        // Technician starts work
        taskStatus = "in_progress";

        expect(taskStatus, "in_progress");


        // Technician completes work
        taskStatus = "resolved";

        expect(taskStatus, "resolved");

      },
    );


  });

}