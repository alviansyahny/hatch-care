import 'package:flutter/material.dart';
import 'register_screen.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const Color navy = Color(0xFF023266);
  static const Color yellow = Color(0xFFFBDF65);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      // Ilustrasi farmer
                      SizedBox(
                        height: constraints.maxHeight * 0.53,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/farmer.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Judul
                      const Text(
                        'HATCH - CARE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'KronaOne',
                          fontSize: 23,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Deskripsi
                      const Text(
                        'Monitoring penetasan telur pintar dalam satu '
                        'genggaman. Pantau suhu, kelembapan, dan '
                        'perkembangan telur secara real-time untuk hasil '
                        'tetas yang optimal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.65,
                          color: Color(0xFF999999),
                        ),
                      ),

                      const SizedBox(height: 38),

                      // Tombol Mulai Monitoring
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: yellow,
                            foregroundColor: navy,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Mulai Monitoring',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Tombol Kembali
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: navy,
                            side: const BorderSide(color: Color(0xFFE0E0E0)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Kembali',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
