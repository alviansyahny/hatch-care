
import 'package:flutter/material.dart';
import 'live_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int selectedIndex = 0;

  double temperature = 37.8;
  double humidity = 60.0;

  late DateTime lastUpdate;

  final Color navy = const Color(0xFF0D3158);
  final Color blue = const Color(0xFF315F9B);
  final Color yellow = const Color(0xFFFFDF72);

  @override
  void initState() {
    super.initState();
    lastUpdate = DateTime.now();
  }

  String get updateTime {
    final hour = lastUpdate.hour.toString().padLeft(2, '0');
    final minute = lastUpdate.minute.toString().padLeft(2, '0');
    final second = lastUpdate.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  void showFeature(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature sedang disiapkan'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> openLive() async {
    setState(() => selectedIndex = 1);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LiveScreen(),
      ),
    );

    if (!mounted) return;
    setState(() => selectedIndex = 0);
  }

  Future<void> openHistory() async {
    setState(() => selectedIndex = 3);

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      ),
    );

    if (!mounted) return;
    setState(() => selectedIndex = 0);
  }

  void handleNavigation(int index) {
    switch (index) {
      case 0:
        setState(() => selectedIndex = 0);
        break;
      case 1:
        openLive();
        break;
      case 2:
        setState(() => selectedIndex = 2);
        showFeature('Egg Checking');
        break;
      case 3:
        openHistory();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selamat Datang!',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF343B49),
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Pantau kondisi inkubator dan perkembangan telur hari ini',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF60799F),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFFFF1BE),
                    child: IconButton(
                      onPressed: () => showFeature('Notifikasi'),
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Color(0xFF173D67),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // STATUS INKUBATOR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF0D2747),
                      Color(0xFF08203D),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 15,
                          backgroundColor: Color(0xFF294664),
                          child: Icon(
                            Icons.egg_alt,
                            color: Color(0xFFFFDF72),
                            size: 17,
                          ),
                        ),
                        const SizedBox(width: 9),
                        const Expanded(
                          child: Text(
                            'Status Inkubator',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.circle,
                                color: Color(0xFF42D994),
                                size: 8,
                              ),
                              SizedBox(width: 5),
                              Text(
                                'Terhubung',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 17),
                    const Text(
                      'Sistem PID aktif, parameter termal & sirkulasi udara beroperasi normal.',
                      style: TextStyle(
                        color: Color(0xFFB8D0F4),
                        fontSize: 12,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 17),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '▣ Hari ke-11 dari 21',
                          style: TextStyle(
                            color: yellow,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Fase Vaskularisasi',
                          style: TextStyle(
                            color: Color(0xFF9BB8E2),
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 11 / 21,
                        minHeight: 8,
                        backgroundColor: Color(0xFF40536A),
                        valueColor: AlwaysStoppedAnimation(
                          Color(0xFFFFDF72),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // MONITORING REAL TIME
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Monitoring Real-Time',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF17395F),
                    ),
                  ),
                  const Icon(
                    Icons.sensors,
                    color: Color(0xFF4779B7),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Pembacaan sensor terakhir: $updateTime',
                style: const TextStyle(
                  color: Color(0xFF8493A9),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: sensorCard(
                      title: 'Suhu Inkubator',
                      value: '${temperature.toStringAsFixed(1)}°C',
                      icon: Icons.thermostat,
                      color: const Color(0xFF3976B8),
                      background: const Color(0xFFEAF3FF),
                      status: 'Sesuai target',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: sensorCard(
                      title: 'Kelembapan',
                      value: '${humidity.toStringAsFixed(0)}%',
                      icon: Icons.water_drop_outlined,
                      color: const Color(0xFFB38A23),
                      background: const Color(0xFFFFF5D9),
                      status: 'Sesuai target',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              const Text(
                '*Angka saat ini merupakan data contoh. Integrasi sensor ESP32 akan dilakukan selanjutnya.',
                style: TextStyle(
                  fontSize: 9,
                  color: Color(0xFF8996A9),
                ),
              ),

              const SizedBox(height: 22),

              // GRAFIK
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kondisi Inkubator',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF17395F),
                          ),
                        ),
                        IconButton(
                          onPressed: () => showFeature('Detail grafik'),
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFF5277AC),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Suhu (°C)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(width: 15),
                        Container(
                          width: 10,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5C34E),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        const SizedBox(width: 5),
                        const Text(
                          'Kelembapan (%)',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 115,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: MonitoringChartPainter(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('00:00', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                        Text('04:00', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                        Text('08:00', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                        Text('12:00', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                        Text('16:00', style: TextStyle(fontSize: 9, color: Colors.blueGrey)),
                        Text(
                          'Sekarang',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF17395F),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // STATISTIK TELUR
              Row(
                children: [
                  Expanded(
                    child: eggStat(
                      icon: Icons.grid_view_rounded,
                      title: 'Total Telur',
                      count: '20',
                      color: const Color(0xFFEAF1FF),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: eggStat(
                      icon: Icons.egg_alt,
                      title: 'Fertil',
                      count: '10',
                      color: const Color(0xFFFFF0B5),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: eggStat(
                      icon: Icons.egg_outlined,
                      title: 'Infertil',
                      count: '10',
                      color: const Color(0xFFDCE8FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 23),

              // FITUR UTAMA
              const Text(
                'Fitur Utama',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF17395F),
                ),
              ),
              const SizedBox(height: 12),

              featureTile(
                icon: Icons.videocam_outlined,
                title: 'Live Monitoring',
                subtitle: 'Pantau visual inkubator secara langsung 24/7',
                tag: 'ESP32-CAM',
                onTap: openLive,
              ),
              const SizedBox(height: 9),
              featureTile(
                icon: Icons.tune,
                title: 'Remote Control',
                subtitle: 'Atur aktuator pemanas, kipas, & rotasi rak otomatis',
                tag: 'PID Relay',
                onTap: () => showFeature('Remote Control'),
              ),
              const SizedBox(height: 9),
              featureTile(
                icon: Icons.lightbulb_outline,
                title: 'Egg Checking',
                subtitle: 'Periksa kondisi embrio melalui proses candling',
                tag: 'SVM',
                onTap: () => showFeature('Egg Checking'),
              ),
              const SizedBox(height: 9),
              featureTile(
                icon: Icons.history,
                title: 'History',
                subtitle: 'Lihat riwayat monitoring dan perkembangan telur',
                tag: 'Data',
                onTap: openHistory,
              ),
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 12,
              offset: Offset(0, -3),
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

  // SENSOR CARD
  Widget sensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color background,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 10, color: color)),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 5),
          Text(status, style: TextStyle(fontSize: 9, color: color)),
        ],
      ),
    );
  }

  // EGG STATISTIC
  Widget eggStat({
    required IconData icon,
    required String title,
    required String count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: color,
            child: Icon(icon, size: 15, color: navy),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF60799F),
            ),
          ),
          Text(
            count,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF17395F),
            ),
          ),
          const Text(
            'butir',
            style: TextStyle(fontSize: 9, color: Colors.blueGrey),
          ),
        ],
      ),
    );
  }

  // FEATURE TILE
  Widget featureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              CircleAvatar(
                radius: 21,
                backgroundColor: const Color(0xFFEAF2FC),
                child: Icon(icon, color: blue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Color(0xFF17395F),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F5EE),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Color(0xFF27865D),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF71839E),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF82A4D2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOTTOM NAV ITEM
  Widget navItem(IconData icon, String title, int index) {
    final bool active = selectedIndex == index;

    return InkWell(
      onTap: () => handleNavigation(index),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        decoration: BoxDecoration(
          color: active ? navy : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 19,
              color: active ? yellow : blue,
            ),
            const SizedBox(height: 3),
            Text(
              title,
              style: TextStyle(
                fontSize: 9,
                color: active ? yellow : blue,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// CUSTOM GRAFIK MONITORING
class MonitoringChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE9EDF3)
      ..strokeWidth = 0.7;

    for (int i = 0; i < 4; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    final tempPaint = Paint()
      ..color = const Color(0xFF5277AC)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final humidityPaint = Paint()
      ..color = const Color(0xFFE2C34E)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final tempPoints = [
      0.38, 0.40, 0.34, 0.29, 0.34, 0.42,
      0.39, 0.30, 0.26, 0.36, 0.44, 0.34,
    ];

    final humidityPoints = [
      0.70, 0.65, 0.67, 0.61, 0.49, 0.55,
      0.69, 0.72, 0.61, 0.44, 0.51, 0.60,
    ];

    final tempPath = Path();
    final humidityPath = Path();

    for (int i = 0; i < tempPoints.length; i++) {
      final x = i * size.width / (tempPoints.length - 1);
      final y1 = tempPoints[i] * size.height;
      final y2 = humidityPoints[i] * size.height;

      if (i == 0) {
        tempPath.moveTo(x, y1);
        humidityPath.moveTo(x, y2);
      } else {
        tempPath.lineTo(x, y1);
        humidityPath.lineTo(x, y2);
      }
    }

    canvas.drawPath(tempPath, tempPaint);
    canvas.drawPath(humidityPath, humidityPaint);

    canvas.drawCircle(
      Offset(size.width, tempPoints.last * size.height),
      3.5,
      Paint()..color = const Color(0xFF17395F),
    );

    canvas.drawCircle(
      Offset(size.width, humidityPoints.last * size.height),
      3.5,
      Paint()..color = const Color(0xFFE2C34F),
    );
  }

  @override
  bool shouldRepaint(covariant MonitoringChartPainter oldDelegate) {
    return false;
  }
}
