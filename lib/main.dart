import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/device_scan_screen.dart';
import 'screens/saved_chats_screen.dart';

void main() {
  runApp(const BluBubbApp());
}

class BluBubbApp extends StatelessWidget {
  const BluBubbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BluBubb',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/scan': (context) => DeviceScanScreen(),
        '/saved': (context) => const SavedChatsScreen(),
      },
    );
  }
}