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
      // We use `onGenerateRoute` instead of `routes` to pass arguments (like username)
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const HomeScreen());
          case '/scan':
            final deviceName = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => DeviceScanScreen(deviceName: deviceName),
            );
          case '/saved':
            return MaterialPageRoute(builder: (context) => const SavedChatsScreen());
          default:
            return MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}