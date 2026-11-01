
import 'package:flutter/material.dart';
import 'register_screen.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const Color navy = Color(0xFF023266);
  static const Color yellow = Color(0xFFFBDF65);
  static const Color fieldColor = Color(0xFFF0F3FF);

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      // LOGO HATCH-CARE
                      Container(
                        width: 90,
                        height: 90,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
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

                      const SizedBox(height: 10),

                      // JUDUL
                      const Text(
                        'Halo, Selamat Datang!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF41454F),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // DESKRIPSI
                      const Text(
                        'Masuk untuk memantau proses penetasan telur '
                        'dan perkembangan inkubator anda',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.5,
                          color: Color(0xFF496A9A),
                        ),
                      ),

                      const SizedBox(height: 30),

                      // FORM LOGIN
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: const Color(0xFFF5F5F5),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // USERNAME ATAU EMAIL
                              const Text(
                                'Username atau Email',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: navy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 7),

                              SizedBox(
                                height: 43,
                                child: TextFormField(
                                  controller: usernameController,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: navy,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        'contoh@email.com atau username',
                                    hintStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF858585),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.mail_outline,
                                      color: Color(0xFF496A9A),
                                      size: 18,
                                    ),
                                    filled: true,
                                    fillColor: fieldColor,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(11),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(11),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(11),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF8AA5D0),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Username atau email wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 15),

                              // KATA SANDI
                              const Text(
                                'Kata Sandi',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: navy,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(height: 7),

                              SizedBox(
                                height: 43,
                                child: TextFormField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: navy,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Masukkan kata sandi',
                                    hintStyle: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF858585),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock_outline,
                                      color: Color(0xFF496A9A),
                                      size: 18,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword =
                                              !obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: const Color(0xFF496A9A),
                                        size: 18,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: fieldColor,
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(11),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(11),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(11),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF8AA5D0),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty) {
                                      return 'Kata sandi wajib diisi';
                                    }
                                    return null;
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

                              // LUPA KATA SANDI
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
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
                                      color: navy,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 18),

                              // TOMBOL MASUK
                              SizedBox(
                                width: double.infinity,
                                height: 43,
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Form login berhasil divalidasi.',
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: yellow,
                                    foregroundColor: Colors.black,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Masuk',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(width: 7),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 17,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 3),

                      // LINK DAFTAR
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum punya akun? ',
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
                                  builder: (context) =>
                                      const RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 11,
                                color: navy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
