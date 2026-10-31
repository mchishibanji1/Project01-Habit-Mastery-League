import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:habit_mastery_league/main.dart';

void main() {
  // 1. Initialize the database factory for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  // 2. Write the actual test
  testWidgets('App builds and shows Dashboard', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(const HabitMasteryApp());

    // Wait for the async database call in DashboardScreen to finish
    await tester.pumpAndSettle();

    // Verify the Dashboard loaded
    expect(find.text('My Habits'), findsOneWidget);
  });
}
