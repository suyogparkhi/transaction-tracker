import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(BankSMSApp());
}

class BankSMSApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bank SMS Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}
