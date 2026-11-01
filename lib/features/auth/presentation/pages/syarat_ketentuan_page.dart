import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';

/// Halaman Syarat dan Ketentuan aplikasi HATCH-CARE.
class SyaratKetentuanPage extends StatelessWidget {
  const SyaratKetentuanPage({super.key});

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
      backgroundColor: AppColors.neutral,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.tertiary),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Syarat Dan Ketentuan',
          style: TextStyle(
            color: AppColors.tertiary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: _items.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) =>
                    _SkCard(number: index + 1, item: _items[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.sm,
                AppSpacing.xl,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: AppColors.textSubtle,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Text(
                      'Persetujuan dilakukan melalui checkbox di formulir pendaftaran.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textBody),
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
              color: AppColors.primaryDark,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                color: AppColors.neutral,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Icon(
                      item.icon,
                      size: 18,
                      color: AppColors.primary.withValues(alpha: 0.7),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: AppColors.textBody,
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
