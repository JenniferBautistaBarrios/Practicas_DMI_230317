import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Importación necesaria para el sonido del sistema
import 'package:google_fonts/google_fonts.dart';

class CounterFunctionsScreen extends StatefulWidget {
  const CounterFunctionsScreen({super.key});

  @override
  State<CounterFunctionsScreen> createState() => _CounterFunctionsScreenState();
}

class _CounterFunctionsScreenState extends State<CounterFunctionsScreen> {
  int clickCounter = 0;

  @override
  Widget build(BuildContext context) {
    // Evaluamos el color según el valor actual del contador
    Color counterColor = Colors.pink.shade300;
    if (clickCounter > 0) counterColor = Colors.pink.shade800;
    if (clickCounter < 0) counterColor = Colors.pinkAccent;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              // Sonido al presionar
              SystemSound.play(SystemSoundType.click);
              setState(() {
                clickCounter = 0;
              });
            }, 
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$clickCounter',
              style: GoogleFonts.pacifico(
                fontSize: 160, 
                fontWeight: FontWeight.w100,
                color: counterColor,
              ),
            ),
            Text(
              'Click${clickCounter == 1 ? '' : 's'}', 
              style: GoogleFonts.pacifico(fontSize: 30),
            )
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            shape: const StadiumBorder(),
            enableFeedback: true, // Asegura que el feedback nativo esté activo
            onPressed: () {
              // Emite sonido de click del sistema
              SystemSound.play(SystemSoundType.click);
              clickCounter++;
              setState(() {});
            },
            child: const Icon(Icons.plus_one),
          ),
          
          const SizedBox(height: 15),

          FloatingActionButton(
            shape: const StadiumBorder(),
            enableFeedback: true,
            onPressed: () {
              // Emite sonido de click del sistema
              SystemSound.play(SystemSoundType.click);
              clickCounter--;
              setState(() {});
            },
            child: const Icon(Icons.exposure_minus_1_outlined),
          ),
          
          const SizedBox(height: 15),

          FloatingActionButton(
            shape: const StadiumBorder(),
            enableFeedback: true,
            onPressed: () {
              // Emite sonido de click del sistema
              SystemSound.play(SystemSoundType.click);
              clickCounter = 0;
              setState(() {});
            },
            child: const Icon(Icons.refresh_outlined),
          ),
        ],
      ),
    );
  }
}