import 'package:carro_batman/ui/views/carro_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'di/configure_providers.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {

    await Firebase.initializeApp();
  } catch (e) {
    print("Aviso: Erro ao inicializar Firebase (esperado em ambiente sem config): $e");
  }

  runApp(const BatCarApp());
}

class BatCarApp extends StatelessWidget {
  const BatCarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: MaterialApp(
        title: 'BatMovel',
        debugShowCheckedModeBanner: false,


        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: const Color(0xFFFFD700),
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFFD700),
            secondary: Color(0xFF2C2C2C),
          ),

          textTheme: GoogleFonts.robotoTextTheme(ThemeData.dark().textTheme).copyWith(

          headlineMedium: GoogleFonts.roboto(fontWeight: FontWeight.bold, letterSpacing: 1.0),
          titleLarge: GoogleFonts.roboto(fontWeight: FontWeight.bold, letterSpacing: 0.5),
          bodyMedium: GoogleFonts.roboto(fontSize: 14, height: 1.5),
        ),
          iconTheme: const IconThemeData(color: Colors.white70),
        ),

        home: const BatScreen(),
      ),
    );
  }
}