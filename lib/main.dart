import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'messages/chat_message.dart';
import 'screens/home_screen.dart';
import 'screens/device_scan_screen.dart';
import 'screens/user_history_screen.dart';
import 'screens/chat_history_screen.dart';
import 'screens/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);

  // Register adapter
  Hive.registerAdapter(ChatMessageAdapter());

  // Safely open the box if it's not already open (helps during hot reloads)
  if (!Hive.isBoxOpen('chatBox')) {
    await Hive.openBox<List>('chatBox');
  }

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
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const HomeScreen());

          case '/scan':
            final deviceName = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => DeviceScanScreen(deviceName: deviceName),
            );

          case '/userHistory':
            return MaterialPageRoute(builder: (context) => const UserHistoryScreen());

          case '/chat':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (context) => ChatScreen(
                device: args['device'],
                nearbyService: args['service'],
                deviceName: args['deviceName'],
              ),
            );

          case '/chatHistory':
            final username = settings.arguments as String;
            return MaterialPageRoute(
              builder: (context) => ChatHistoryScreen(username: username),
            );

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