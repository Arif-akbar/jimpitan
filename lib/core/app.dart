import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'router/app_router.dart';

class JimpitanApp extends StatelessWidget {
  const JimpitanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jimpitan Digital',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E6F5C),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
