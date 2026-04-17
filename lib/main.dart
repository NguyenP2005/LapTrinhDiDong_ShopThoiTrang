import 'package:clothing_app/views/main.screen.dart';
import 'package:flutter/material.dart';
import 'views/home_screen.dart ';
import 'views/main.screen.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MainScreen());
  }
}
