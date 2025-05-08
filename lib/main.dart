import 'package:flutter/material.dart';

void main() {
  runApp(const BluBubbApp());
}

/// The root widget for the BluBubb app.
class BluBubbApp extends StatelessWidget {
  const BluBubbApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BluBubb',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

/// The initial home screen of the app.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BluBubb'),
      ),
      body: const Center(
        child: Text(
          'Welcome to BluBubb!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}