import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/device_scan_screen.dart';
import 'screens/saved_chats_screen.dart';

void main() {
  // Entry point of the Flutter app
  runApp(const BluBubbApp());
}

class BluBubbApp extends StatelessWidget {
  const BluBubbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BluBubb', // App title
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, // Use Material 3 styling
      ),
      // Set up initial and named routes for navigation
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/scan': (context) => const DeviceScanScreen(),
        '/saved': (context) => const SavedChatsScreen(),
      },
    );
  }
}