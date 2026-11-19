import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_assets.dart';
import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/constants/app_text_styles.dart';

/// Halaman onboarding HATCH-CARE.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // Ilustrasi farmer
                          SizedBox(
                            height: constraints.maxHeight * 0.48,
                            width: double.infinity,
                            child: Image.asset(
                              AppAssets.farmer,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

                          // Judul
                          Text(
                            'HATCH - CARE',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.brandTitle.copyWith(
                              fontSize: 22,
                              color: AppColors.primary,
                              letterSpacing: 0.5,
                            ),
                          ),

                          const SizedBox(height: AppSpacing.sm),

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
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      Column(
                        children: [
                          // Tombol Mulai Monitoring
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                context.go('/register');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.tertiary,
                                foregroundColor: AppColors.primary,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
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

                          const SizedBox(height: AppSpacing.sm),

                          // Tombol Kembali
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                if (context.canPop()) {
                                  context.pop();
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.borderLight,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: AppSpacing.md,
                                ),
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

                          const SizedBox(height: AppSpacing.sm),
                        ],
                      ),
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
