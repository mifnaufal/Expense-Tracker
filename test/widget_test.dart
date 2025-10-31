import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/main.dart';

void main() {
  testWidgets('App should build without crashing', (WidgetTester tester) async {
    // Jalankan aplikasi utama
    await tester.pumpWidget(const ExpenseTrackerApp());

    // Pastikan ada widget utama yang tampil (misalnya teks "Expense Tracker")
    expect(find.text('Expense Tracker'), findsOneWidget);
  });
}
