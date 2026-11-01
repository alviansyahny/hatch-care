import 'package:flutter/material.dart';

class SkScreen extends StatelessWidget {
  const SkScreen({super.key});

  static const Color _navy = Color(0xFF003063);
  static const Color _yellow = Color(0xFFFADE65);

  static const List<_SkItem> _items = [
    _SkItem(
      title: 'Ketentuan Umum',
      icon: Icons.fact_check_outlined,
      description:
          'HATCH-CARE merupakan aplikasi untuk membantu pengguna memantau kondisi inkubator dan proses penetasan telur ayam melalui informasi yang tersedia pada sistem.',
    ),
    _SkItem(
      title: 'Penggunaan Aplikasi',
      icon: Icons.tune,
      description:
          'Pengguna diharapkan menggunakan aplikasi sesuai fungsinya dan tidak menyalahgunakan fitur yang tersedia atau mengakses akun milik orang lain tanpa izin.',
    ),
    _SkItem(
      title: 'Informasi Monitoring',
      icon: Icons.sensors,
      description:
          'Informasi suhu, kelembapan, kondisi telur, dan hasil analisis yang ditampilkan bergantung pada data sensor, kamera, koneksi, serta sistem analisis yang digunakan.',
    ),
    _SkItem(
      title: 'Hasil Analisis Telur',
      icon: Icons.image_search,
      description:
          'Hasil analisis sistem merupakan informasi pendukung pemantauan dan tidak menjamin keberhasilan penetasan. Pengguna tetap perlu melakukan pemeriksaan dan pengawasan yang sesuai.',
    ),
    _SkItem(
      title: 'Keamanan Akun',
      icon: Icons.lock_outline,
      description:
          'Pengguna bertanggung jawab menjaga keamanan akun dan tidak membagikan password kepada pihak lain.',
    ),
    _SkItem(
      title: 'Privasi Pengguna',
      icon: Icons.verified_user_outlined,
      description:
          'Informasi akun dan data penggunaan harus dikelola sesuai kebijakan privasi HATCH-CARE yang berlaku. Jangan menampilkan atau membagikan data pribadi pengguna tanpa dasar dan izin yang sesuai.',
    ),
    _SkItem(
      title: 'Perubahan Ketentuan',
      icon: Icons.edit_note,
      description:
          'Syarat dan ketentuan dapat diperbarui apabila terdapat perubahan fitur atau kebijakan aplikasi. Perubahan penting perlu diinformasikan kepada pengguna.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _navy,
        elevation: 0,
        iconTheme: const IconThemeData(color: _yellow),
        title: const Text(
          'Syarat Dan Ketentuan',
          style: TextStyle(
            color: _yellow,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const SizedBox(height: 14),
                itemBuilder: (context, index) =>
                    _SkCard(number: index + 1, item: _items[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.grey[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Persetujuan dilakukan melalui checkbox di formulir pendaftaran.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkItem {
  final String title;
  final IconData icon;
  final String description;

  const _SkItem({
    required this.title,
    required this.icon,
    required this.description,
  });
}

class _SkCard extends StatelessWidget {
  final int number;
  final _SkItem item;

  const _SkCard({required this.number, required this.item});

  @override
  Widget build(BuildContext context) {
    const navy = SkScreen._navy;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0xFF0B1B3A),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: navy,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(item.icon, size: 18, color: navy.withOpacity(0.7)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}