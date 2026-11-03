import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/tactical_theme.dart';
import 'state/simar_controller.dart';
import 'ui/screens/simar_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuración de barra de estado y navegación translúcida táctica
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF090D16),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const SimarApp());
}

class SimarApp extends StatefulWidget {
  const SimarApp({super.key});

  @override
  State<SimarApp> createState() => _SimarAppState();
}

class _SimarAppState extends State<SimarApp> {
  late final SimarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SimarController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMAR - Santa Cruz',
      debugShowCheckedModeBanner: false,
      theme: TacticalTheme.themeData,
      home: SimarHomeScreen(controller: _controller),
    );
  }
}
