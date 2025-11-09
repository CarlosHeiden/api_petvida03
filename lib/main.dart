import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:api_petvida03/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inicializa o Firebase antes de rodar o app
  runApp(const PetVidaApp());
}

class PetVidaApp extends StatelessWidget {
  const PetVidaApp({super.key});

  static const Color _petVidaGreen = Color.fromARGB(255, 3, 187, 133);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetVida',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: _petVidaGreen,
        colorScheme: ColorScheme.fromSeed(seedColor: _petVidaGreen),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _petVidaGreen,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _petVidaGreen,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _petVidaGreen,
            side: BorderSide(color: _petVidaGreen, width: 2),
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: _petVidaGreen, width: 2.0),
          ),
          labelStyle: TextStyle(color: _petVidaGreen),
          prefixIconColor: _petVidaGreen,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: _petVidaGreen,
          centerTitle: true,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
