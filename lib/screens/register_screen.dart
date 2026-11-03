import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'sk_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const Color navy = Color(0xFF023266);
  static const Color yellow = Color(0xFFFBDF65);
  static const Color fieldColor = Color(0xFFF2F2F2);

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

  // Widget input form
  Widget buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isConfirmPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    bool isObscure = isPassword || isConfirmPassword;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: navy,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 7),

        SizedBox(
          height: 43,
          child: TextFormField(
            controller: controller,
            obscureText: isPassword
                ? obscurePassword
                : isConfirmPassword
                ? obscureConfirmPassword
                : false,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 12, color: navy),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
              ),
              prefixIcon: Icon(icon, color: const Color(0xFF496A9A), size: 17),
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
                        color: const Color(0xFF496A9A),
                        size: 18,
                      ),
                    )
                  : null,
              filled: true,
              fillColor: fieldColor,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 12,
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
                  color: Color(0xFF8AA5D0),
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
        ),
      ],
    );
  }

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
                      const SizedBox(height: 38),

                      // LOGO HATCH-CARE
                      Container(
                        width: 100,
                        height: 100,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFF8AA5D0),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/Logo HatchCare.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      const SizedBox(height: 17),

                      // DESKRIPSI
                      const Text(
                        'Daftar untuk mulai memantau proses '
                        'penetasan telur dengan lebih cerdas.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.4,
                          color: Color(0xFF424242),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // FORM REGISTER
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

                            const SizedBox(height: 13),

                            buildInputField(
                              label: 'Alamat Email',
                              hint: 'nama@email.com',
                              icon: Icons.mail_outline,
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),

                            const SizedBox(height: 13),

                            buildInputField(
                              label: 'Kata Sandi',
                              hint: 'Minimal 8 karakter',
                              icon: Icons.lock_outline,
                              controller: passwordController,
                              isPassword: true,
                            ),

                            const SizedBox(height: 13),

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

                      const SizedBox(height: 14),

                      // CHECKBOX SYARAT DAN KETENTUAN
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 25,
                            height: 24,
                            child: Checkbox(
                              value: agreeTerms,
                              activeColor: navy,
                              onChanged: (value) {
                                setState(() {
                                  agreeTerms = value ?? false;
                                });
                              },
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),

                          const SizedBox(width: 7),

                          Expanded(
                            child: Wrap(
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text(
                                  'Saya menyetujui ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SkScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Syarat dan Ketentuan',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: navy,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const Text(
                                  ' HATCH-CARE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Color(0xFF424242),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // TOMBOL DAFTAR
                      SizedBox(
                        width: double.infinity,
                        height: 43,
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
                            backgroundColor: yellow,
                            foregroundColor: navy,
                            elevation: 0,
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

                      const SizedBox(height: 13),

                      // LINK MASUK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah punya akun? ',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF555555),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 11,
                                color: navy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
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
