import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const CornholeApp());
}

class CornholeApp extends StatelessWidget {
  const CornholeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cornhole Scorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}