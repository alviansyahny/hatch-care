import 'package:flutter/material.dart';
import 'live_screen.dart';
import 'history_screen.dart';

class NotifikasiScreen extends StatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  State<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends State<NotifikasiScreen> {
  static const Color navy = Color(0xFF0D3158);
  static const Color blue = Color(0xFF315F9B);
  static const Color yellow = Color(0xFFFFDF72);

  int selectedIndex = 0;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> navigateTo(int index) async {
    setState(() => selectedIndex = index);

    switch (index) {
      case 0:
        Navigator.pop(context);
        break;

      case 1:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LiveScreen()),
        );
        break;

      case 2:
        showMessage('Halaman Egg Check sedang disiapkan');
        break;

      case 3:
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HistoryScreen()),
        );
        break;
    }

    if (mounted) {
      setState(() => selectedIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),

      // HEADER
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: yellow),
            ),
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: yellow,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      // ISI NOTIFIKASI
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            // NOTIFIKASI SUHU
            notificationCard(
              icon: Icons.thermostat,
              title: 'Suhu Inkubator',
              iconColor: const Color(0xFFB17A00),
              iconBackground: const Color(0xFFFFF6D9),
              borderColor: const Color(0xFFFFE6A0),
              titleColor: navy,
              message:
                  'Suhu terdeteksi mencapai 38.8°C (batas atas 38.0°C). Sistem kipas otomatis diaktifkan untuk pendinginan.',
              time: '5 menit yang lalu',
              buttonText: 'Cek Inkubator',
              buttonFilled: true,
              onPressed: () {
                showMessage('Membuka informasi inkubator');
              },
              chip: null,
            ),

            const SizedBox(height: 12),

            // NOTIFIKASI KELEMBAPAN
            notificationCard(
              icon: Icons.water_drop_outlined,
              title: 'Kelembapan Ruang Telur Menurun',
              iconColor: navy,
              iconBackground: const Color(0xFFEAF0F9),
              borderColor: const Color(0xFFD9E5F6),
              titleColor: navy,
              message:
                  'Kelembapan saat ini 48% RH (target ideal 55-60% RH). Pastikan baki penampung air terisi penuh.',
              time: '28 menit yang lalu',
              buttonText: 'Periksa Baki',
              buttonFilled: false,
              onPressed: () {
                showMessage('Silakan periksa baki air inkubator');
              },
              chip: 'Kelembapan',
              subtitle: 'Ruang Telur A',
            ),

            const SizedBox(height: 12),

            // NOTIFIKASI SISTEM
            notificationCard(
              icon: Icons.sensors,
              title: 'Sistem',
              iconColor: const Color(0xFF315F9B),
              iconBackground: const Color(0xFFF0F4FA),
              borderColor: const Color(0xFFE5ECF6),
              titleColor: navy,
              message:
                  'Sinkronisasi sensor telemetri real-time berhasil dipulihkan secara normal.',
              time: 'Kemarin, 14:20',
              buttonText: 'Selesai',
              buttonFilled: false,
              isCompleted: true,
              onPressed: () {},
              chip: null,
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 8, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: navy.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            navItem(Icons.home_rounded, 'Home', 0),
            navItem(Icons.videocam_outlined, 'Live', 1),
            navItem(Icons.egg_alt_outlined, 'Egg Check', 2),
            navItem(Icons.show_chart, 'History', 3),
          ],
        ),
      ),
    );
  }

  // KARTU NOTIFIKASI
  Widget notificationCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required Color iconBackground,
    required Color borderColor,
    required Color titleColor,
    required String message,
    required String time,
    required String buttonText,
    required bool buttonFilled,
    required VoidCallback onPressed,
    String? chip,
    String? subtitle,
    bool isCompleted = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: borderColor),
                ),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const SizedBox(width: 11),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (chip != null) ...[
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF1FC),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFD5E2F5),
                              ),
                            ),
                            child: Text(
                              chip,
                              style: TextStyle(
                                color: navy,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              subtitle ?? '',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF8195B5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 7),
                    ],

                    Text(
                      title,
                      style: TextStyle(
                        color: titleColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text(
            message,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF536D96),
              height: 1.6,
            ),
          ),

          const SizedBox(height: 10),

          Divider(height: 1, color: const Color(0xFFE9EDF4)),

          const SizedBox(height: 9),

          Row(
            children: [
              Icon(
                isCompleted ? Icons.check : Icons.access_time,
                size: 12,
                color: const Color(0xFF8AA2C5),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  time,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8199BD),
                  ),
                ),
              ),

              if (isCompleted)
                const Row(
                  children: [
                    Icon(Icons.check, color: Color(0xFF8AA2C5), size: 13),
                    SizedBox(width: 3),
                    Text(
                      'Selesai',
                      style: TextStyle(color: Color(0xFF8AA2C5), fontSize: 10),
                    ),
                  ],
                )
              else
                OutlinedButton(
                  onPressed: onPressed,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: buttonFilled ? yellow : Colors.white,
                    foregroundColor: navy,
                    side: BorderSide(
                      color: buttonFilled ? yellow : const Color(0xFFD4E0F1),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // BOTTOM NAVIGATION ITEM
  Widget navItem(IconData icon, String title, int index) {
    final bool active = selectedIndex == index;

    return InkWell(
      onTap: () => navigateTo(index),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: active ? navy : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: active ? yellow : blue),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                fontSize: 9,
                color: active ? yellow : navy,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
