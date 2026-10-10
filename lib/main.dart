import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/reels_screen.dart';

void main() {
  runApp(const ProviderScope(child: BwReelsApp()));
}

class BwReelsApp extends StatelessWidget {
  const BwReelsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BWHS Reels',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07070A),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFECE8E0),
          secondary: Color(0xFF3B82F6),
          surface: Color(0xFF121216),
        ),
        textTheme: GoogleFonts.manropeTextTheme(ThemeData.dark().textTheme).copyWith(
          displayLarge: GoogleFonts.instrumentSerif(fontSize: 32, fontWeight: FontWeight.w400),
          headlineMedium: GoogleFonts.instrumentSerif(fontSize: 24),
        ),
        useMaterial3: true,
      ),
      home: const ReelsScreen(),
    );
  }
}
