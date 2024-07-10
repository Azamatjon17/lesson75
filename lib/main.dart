import 'package:flutter/material.dart';
import 'package:lesson75/services/location_servcice.dart';
import 'package:lesson75/views/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocationServcice.determinePosition();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
