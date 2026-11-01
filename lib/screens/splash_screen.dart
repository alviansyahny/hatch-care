
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'unboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController splashController;
  late AnimationController liftController;
  late AnimationController floatController;
  late AnimationController titleController;

  @override
  void initState() {
    super.initState();

    splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    liftController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    titleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    splashController.forward();

    Future.delayed(const Duration(milliseconds: 2300), () {
      if (!mounted) return;

      liftController.forward();
      titleController.forward();
      floatController.repeat(reverse: true);
    });

    Future.delayed(const Duration(seconds: 6), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  void dispose() {
    splashController.dispose();
    liftController.dispose();
    floatController.dispose();
    titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBDF65),
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([
            splashController,
            liftController,
            floatController,
            titleController,
          ]),
          builder: (context, child) {
            final lift = liftController.value * 25;
            final floating =
                math.sin(floatController.value * math.pi) * 7;

            final scale = Curves.elasticOut.transform(
              splashController.value,
            );

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 230,
                  height: 230,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Efek splash lingkaran
                      Transform.scale(
                        scale: 0.5 + splashController.value,
                        child: Opacity(
                          opacity: (1 - splashController.value)
                              .clamp(0.0, 1.0),
                          child: Container(
                            width: 190,
                            height: 190,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF023266),
                                width: 3,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Logo telur
                      Transform.translate(
                        offset: Offset(0, -lift + floating),
                        child: Transform.scale(
                          scale: scale,
                          child: Image.asset(
                            'assets/Logo HatchCare.png',
                            width: 175,
                            height: 175,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 5),

                // Tulisan HATCH-CARE
                Opacity(
                  opacity: titleController.value,
                  child: Transform.translate(
                    offset: Offset(
                      0,
                      15 * (1 - titleController.value),
                    ),
                    child: const Text(
                      'HATCH-CARE',
                      style: TextStyle(
                        fontFamily: 'KronaOne',
                        fontSize: 25,
                        color: Color(0xFF023266),
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
