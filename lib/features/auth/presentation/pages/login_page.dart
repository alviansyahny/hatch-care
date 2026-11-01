import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_assets.dart';
import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';

/// Halaman login akun HATCH-CARE.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoSize = (screenWidth * 0.25).clamp(80.0, 90.0);

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
                    children: [
                      const SizedBox(height: AppSpacing.xxl),

                      // Logo HATCH-CARE
                      Container(
                        width: logoSize,
                        height: logoSize,
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.neutral,
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: AppColors.secondary,
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          AppAssets.logoHatchcare,
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.sm),

                      // Judul
                      const Text(
                        'Halo, Selamat Datang!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textBody,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xs),

                      // Deskripsi
                      const Text(
                        'Masuk untuk memantau proses penetasan telur '
                        'dan perkembangan inkubator anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          color: AppColors.iconAccent,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Form Login Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.neutral,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username atau Email
                              const Text(
                                'Username atau Email',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              TextFormField(
                                controller: usernameController,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'contoh@email.com atau username',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textHint,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.mail_outline,
                                    color: AppColors.iconAccent,
                                    size: 18,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.fieldFill,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: const BorderSide(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Username atau email wajib diisi';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Kata Sandi
                              const Text(
                                'Kata Sandi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              TextFormField(
                                controller: passwordController,
                                obscureText: obscurePassword,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.primary,
                                ),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Masukkan kata sandi',
                                  hintStyle: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textHint,
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: AppColors.iconAccent,
                                    size: 18,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        obscurePassword = !obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: AppColors.iconAccent,
                                      size: 18,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: AppColors.fieldFill,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                    vertical: AppSpacing.md,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(11),
                                    borderSide: const BorderSide(
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Kata sandi wajib diisi';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: AppSpacing.sm),

                              // Lupa Kata Sandi
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Halaman pemulihan kata sandi '
                                          'akan dibuat berikutnya.',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Lupa Kata Sandi?',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Tombol Masuk
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Form login berhasil divalidasi.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.tertiary,
                                    foregroundColor: AppColors.primary,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppSpacing.md,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Masuk',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: AppSpacing.sm),
                                      Icon(Icons.arrow_forward, size: 17),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Link Daftar
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSubtle,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/register');
                            },
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.xl),
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
