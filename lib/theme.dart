import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

var appTheme = ThemeData(
  fontFamily: GoogleFonts.nunito().fontFamily,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF1E1E1E),
  bottomAppBarTheme: BottomAppBarTheme(color: Colors.black.withOpacity(0.7)),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(fontSize: 18),
    bodyMedium: TextStyle(fontSize: 16),
    labelLarge: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold),
    displayLarge: TextStyle(fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Colors.grey),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.deepPurple,
      textStyle: const TextStyle(
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  buttonTheme: const ButtonThemeData(),
  appBarTheme: AppBarTheme(
    color:
        Colors
            .grey[900], // Background color of the AppBar // Shadow under the AppBar
  ),
);
