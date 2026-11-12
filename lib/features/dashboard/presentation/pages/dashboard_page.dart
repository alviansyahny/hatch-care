import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/features/live/domain/models/incubator_models.dart';
import 'package:hatch_care/features/live/presentation/providers/incubator_provider.dart';

/// Halaman Dashboard HATCH-CARE sesuai tampilan dan tata letak versi tim backend.
///
/// Data sensor nyata diambil dari backend IoT (provider inkubator yang sama
/// dengan halaman Live — satu sumber polling, tidak ada HTTP di layar).
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
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

  /// Titik grafik dari riwayat tangkapan (1 jam terakhir).
  /// Suhu dinormalisasi dari rentang 36–39 °C, kelembapan dari 0–100%.
  List<List<double>>? _buildChartPoints(IncubatorSnapshot snapshot) {
    final entries = snapshot.history;
    if (entries.length < 2) return null;
    final points = <List<double>>[];
    for (final entry in entries) {
      final temp = entry.temperature;
      final hum = entry.humidity;
      if (temp == null || hum == null) continue;
      points.add([
        ((temp - 36) / 3).clamp(0.0, 1.0),
        (hum / 100).clamp(0.0, 1.0),
      ]);
    }
    if (points.length < 2) return null;
    return points.reversed.toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncSnapshot = ref.watch(incubatorLatestProvider);
    final snapshot = asyncSnapshot.value ?? const IncubatorSnapshot.empty();

    final lastData = snapshot.lastCaptureAt;
    if (lastData != null && lastData.isAfter(lastUpdate)) {
      lastUpdate = lastData;
    }
    final temperatureText = snapshot.temperature != null
        ? '${snapshot.temperature!.toStringAsFixed(1)}°C'
        : '--';
    final humidityText = snapshot.humidity != null
        ? '${snapshot.humidity!.toStringAsFixed(0)}%'
        : '--';
    final isConnected = snapshot.online;

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

                  // TOMBOL NOTIFIKASI
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFFFFF1BE),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => context.push('/notifications'),
                      icon: const Icon(
                        Icons.notifications_none,
                        color: Color(0xFF0D3158),
                        size: 23,
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
                    colors: [Color(0xFF0D2747), Color(0xFF08203D)],
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  color: isConnected
                                      ? const Color(0xFF42D994)
                                      : const Color(0xFFEF4444),
                                  size: 8,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isConnected ? 'Terhubung' : 'Terputus',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
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
                        Expanded(
                          child: Text(
                            '▣ Hari ke-11 dari 21',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: yellow,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Fase Vaskularisasi',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF9BB8E2),
                              fontSize: 9,
                            ),
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
                        valueColor: AlwaysStoppedAnimation(Color(0xFFFFDF72)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // MONITORING REAL TIME
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Expanded(
                    child: Text(
                      'Monitoring Real-Time',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF17395F),
                      ),
                    ),
                  ),
                  Icon(Icons.sensors, color: Color(0xFF4779B7)),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Pembacaan sensor terakhir: $updateTime',
                style: const TextStyle(color: Color(0xFF8493A9), fontSize: 10),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: sensorCard(
                      title: 'Suhu Inkubator',
                      value: temperatureText,
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
                      value: humidityText,
                      icon: Icons.water_drop_outlined,
                      color: const Color(0xFFB38A23),
                      background: const Color(0xFFFFF5D9),
                      status: 'Sesuai target',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                isConnected
                    ? '*Data sensor real-time dari backend IoT. '
                          'Pembacaan diperbarui otomatis tiap 20 detik.'
                    : '*Inkubator tidak terhubung — nilai "--" berarti sensor '
                          'belum melapor. Data diperbarui otomatis tiap 20 detik.',
                style: const TextStyle(fontSize: 9, color: Color(0xFF8996A9)),
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
                        const Expanded(
                          child: Text(
                            'Kondisi Inkubator',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF17395F),
                            ),
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
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
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                      ],
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      height: 115,
                      width: double.infinity,
                      child: CustomPaint(
                        painter: MonitoringChartPainter(
                          points: _buildChartPoints(snapshot),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: const [
                          Text(
                            '00:00',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            '04:00',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            '08:00',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            '12:00',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(width: 16),
                          Text(
                            '16:00',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.blueGrey,
                            ),
                          ),
                          SizedBox(width: 16),
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
                      count: snapshot.totalEggs > 0
                          ? '${snapshot.totalEggs}'
                          : '--',
                      color: const Color(0xFFEAF1FF),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: eggStat(
                      icon: Icons.egg_alt,
                      title: 'Fertil',
                      count: '--',
                      color: const Color(0xFFFFF0B5),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: eggStat(
                      icon: Icons.egg_outlined,
                      title: 'Infertil',
                      count: '--',
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
                onTap: () => context.go('/home/live'),
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
                tag: 'AI Vision',
                onTap: () => context.go('/home/egg-check'),
              ),
              const SizedBox(height: 9),
              featureTile(
                icon: Icons.history,
                title: 'History',
                subtitle: 'Lihat riwayat monitoring dan perkembangan telur',
                tag: 'Data',
                onTap: () => context.go('/home/history'),
              ),
            ],
          ),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(title, style: TextStyle(fontSize: 10, color: color)),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(status, style: TextStyle(fontSize: 9, color: color)),
          ),
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
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
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              style: const TextStyle(fontSize: 10, color: Color(0xFF60799F)),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              count,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF17395F),
              ),
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
                            overflow: TextOverflow.ellipsis,
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
              const Icon(Icons.chevron_right, color: Color(0xFF82A4D2)),
            ],
          ),
        ),
      ),
    );
  }
}

// CUSTOM GRAFIK MONITORING
class MonitoringChartPainter extends CustomPainter {
  MonitoringChartPainter({this.points});

  /// Titik tren nyata (nilai ternormalisasi 0.0–1.0): [suhu, kelembapan].
  /// null / < 2 titik → memakai garis bawaan agar tampilan tidak berubah.
  final List<List<double>>? points;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE9EDF3)
      ..strokeWidth = 0.7;

    for (int i = 0; i < 4; i++) {
      final y = i * size.height / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
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
      0.38,
      0.40,
      0.34,
      0.29,
      0.34,
      0.42,
      0.39,
      0.30,
      0.26,
      0.36,
      0.44,
      0.34,
    ];

    final humidityPoints = [
      0.70,
      0.65,
      0.67,
      0.61,
      0.49,
      0.55,
      0.69,
      0.72,
      0.61,
      0.44,
      0.51,
      0.60,
    ];

    final realPoints = points;
    final useReal = realPoints != null && realPoints.length >= 2;
    final tempSeries = useReal
        ? realPoints.map((p) => p[0]).toList()
        : tempPoints;
    final humSeries = useReal
        ? realPoints.map((p) => p[1]).toList()
        : humidityPoints;

    final tempPath = Path();
    final humidityPath = Path();

    for (int i = 0; i < tempSeries.length; i++) {
      final x = i * size.width / (tempSeries.length - 1);
      final y1 = tempSeries[i] * size.height;
      final y2 = humSeries[i] * size.height;

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
      Offset(size.width, tempSeries.last * size.height),
      3.5,
      Paint()..color = const Color(0xFF17395F),
    );

    canvas.drawCircle(
      Offset(size.width, humSeries.last * size.height),
      3.5,
      Paint()..color = const Color(0xFFE2C34F),
    );
  }

  @override
  bool shouldRepaint(covariant MonitoringChartPainter oldDelegate) {
    final old = oldDelegate.points;
    final current = points;
    if (old == null && current == null) return false;
    if (old == null || current == null) return true;
    if (old.length != current.length) return true;
    for (int i = 0; i < current.length; i++) {
      if (old[i][0] != current[i][0] || old[i][1] != current[i][1]) return true;
    }
    return false;
  }
}
