import 'package:flutter/material.dart';
import 'package:sinapse/theme.dart';
import 'package:sinapse/screens/user_type_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sinapse',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.light,
      home: const UserTypeSelectionScreen(),
    );
  }
}
