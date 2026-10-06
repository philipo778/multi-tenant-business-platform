import 'package:flutter/material.dart';

import 'core/di/injection.dart';

void main() {
  setupDependencies();

  runApp(
    const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Multi-Tenant Business Platform'),
        ),
        body: const Center(
          child: Text('Flutter project ready'),
        ),
      ),
    );
  }
}