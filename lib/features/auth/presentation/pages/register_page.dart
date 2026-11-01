import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_assets.dart';
import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';

/// Halaman pendaftaran akun HATCH-CARE.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool agreeTerms = false;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Widget buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isObscure = isPassword || isConfirmPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          obscureText: isPassword
              ? obscurePassword
              : isConfirmPassword
              ? obscureConfirmPassword
              : false,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 12, color: AppColors.primary),
          decoration: InputDecoration(
            isDense: true,
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: AppColors.textHint),
            prefixIcon: Icon(icon, color: AppColors.iconAccent, size: 18),
            suffixIcon: isObscure
                ? IconButton(
                    onPressed: () {
                      setState(() {
                        if (isPassword) {
                          obscurePassword = !obscurePassword;
                        } else {
                          obscureConfirmPassword = !obscureConfirmPassword;
                        }
                      });
                    },
                    icon: Icon(
                      (isPassword ? obscurePassword : obscureConfirmPassword)
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.iconAccent,
                      size: 18,
                    ),
                  )
                : null,
            filled: true,
            fillColor: AppColors.fieldFill,
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md,
              horizontal: AppSpacing.md,
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
                width: 1,
              ),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '$label tidak boleh kosong';
            }

            if (isPassword && value.length < 8) {
              return 'Kata sandi minimal 8 karakter';
            }

            if (isConfirmPassword && value != passwordController.text) {
              return 'Konfirmasi kata sandi tidak sesuai';
            }

            if (keyboardType == TextInputType.emailAddress &&
                !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
              return 'Masukkan alamat email yang valid';
            }

            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final logoSize = (screenWidth * 0.25).clamp(80.0, 100.0);

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
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.neutral,
                          borderRadius: BorderRadius.circular(18),
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

                      const SizedBox(height: AppSpacing.lg),

                      // Deskripsi
                      const Text(
                        'Daftar untuk mulai memantau proses '
                        'penetasan telur dengan lebih cerdas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: AppColors.textBody,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xxl),

                      // Form Register
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            buildInputField(
                              label: 'Username',
                              hint: 'Masukkan username anda',
                              icon: Icons.person_outline,
                              controller: usernameController,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            buildInputField(
                              label: 'Alamat Email',
                              hint: 'nama@email.com',
                              icon: Icons.mail_outline,
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            buildInputField(
                              label: 'Kata Sandi',
                              hint: 'Minimal 8 karakter',
                              icon: Icons.lock_outline,
                              controller: passwordController,
                              isPassword: true,
                            ),

                            const SizedBox(height: AppSpacing.md),

                            buildInputField(
                              label: 'Konfirmasi Kata Sandi',
                              hint: 'Ulangi kata sandi',
                              icon: Icons.verified_user_outlined,
                              controller: confirmPasswordController,
                              isConfirmPassword: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Checkbox Syarat & Ketentuan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: agreeTerms,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                agreeTerms = value ?? false;
                              });
                            },
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Saya menyetujui ',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textBody,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    context.push('/syarat-ketentuan');
                                  },
                                  child: const Text(
                                    'Syarat dan Ketentuan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const Text(
                                  ' HATCH-CARE',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Tombol Daftar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (!agreeTerms) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Silakan setujui Syarat dan Ketentuan.',
                                    ),
                                  ),
                                );
                                return;
                              }

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Form pendaftaran berhasil divalidasi.',
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
                              borderRadius: BorderRadius.circular(9),
                            ),
                          ),
                          child: const Text(
                            'Daftar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      // Link Masuk
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textSubtle,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              context.go('/login');
                            },
                            child: const Text(
                              'Masuk',
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
