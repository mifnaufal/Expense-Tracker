import 'package:expense_tracker/main.dart';
import 'package:expense_tracker/services/backend_client.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() {
    BackendClient.disableDefaultClientForTesting();
  });

  testWidgets('App should build without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());

    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}
