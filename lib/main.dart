import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart'; // Import untuk lokalisasi tanggal
import 'screens/home_screen.dart';

void main() async {
  // Pastikan inisialisasi binding
  WidgetsFlutterBinding.ensureInitialized(); 
  // Inisialisasi lokalisasi (agar format tanggal 'd MMMM yyyy' jadi bahasa Indonesia)
  await initializeDateFormatting('id_ID', null); 
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.indigo,
        ).copyWith(
          secondary: Colors.amber, // Dulu accentColor
        ),
      ),
      home: HomeScreen(),
      // Set default locale ke Indonesia
      locale: Locale('id', 'ID'), 
    );
  }
}