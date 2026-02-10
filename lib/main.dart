import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soil_detector/screens/welcome_screen.dart';
import 'package:soil_detector/navigation/main_navigation.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Soil Detector',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        // This ensures the BottomNav uses your brand blue
        primaryColor: const Color(0xFF0D47A1),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF0D47A1),
          unselectedItemColor: Colors.grey,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}