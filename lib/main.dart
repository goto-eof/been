import 'package:been/screen/country_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: const Color.fromARGB(255, 1, 117, 219),
  ),
  textTheme: GoogleFonts.latoTextTheme().copyWith().apply(),
);

final themeDark = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.dark,
    seedColor: const Color.fromARGB(255, 1, 117, 219),
  ),
  textTheme:
      GoogleFonts.latoTextTheme().copyWith().apply(bodyColor: Colors.white),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      theme: theme,
      themeMode: ThemeMode.system,
      darkTheme: themeDark,
      debugShowCheckedModeBanner: false,
      home: const Scaffold(
        body: CountryScreen(),
      ),
    ),
  );
}
