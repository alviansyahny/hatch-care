import 'package:flutter/material.dart';
import 'live_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  static const Color navy = Color(0xFF073566);
  static const Color blue = Color(0xFF315F9B);

  int selectedFilter = 0;

  final List<String> filters = ['Semua', 'Fertile', 'Infertile', 'Mortalitas'];

  final List<Map<String, dynamic>> historyData = [
    {
      'number': '07',
      'day': 'Hari 11',
      'status': 'Fertile',
      'id': 'B04-EGG-07',
      'time': '18 Mei, 14:38',
      'image': 'assets/images/egg07.png',
      'progress': '95%',
    },
    {
      'number': '06',
      'day': 'Hari 11',
      'status': 'Fertile',
      'id': 'B04-EGG-06',
      'time': '18 Mei, 14:30',
      'image': 'assets/images/egg06.png',
      'progress': '94%',
    },
    {
      'number': '05',
      'day': 'Hari 11',
      'status': 'Fertile',
      'id': 'B04-EGG-05',
      'time': '18 Mei, 14:22',
      'image': 'assets/images/egg05.png',
      'progress': '98%',
    },
    {
      'number': '04',
      'day': 'Hari 11',
      'status': 'Mortalitas',
      'id': 'B04-EGG-04',
      'time': '18 Mei, 14:15',
      'image': 'assets/images/egg04.png',
      'progress': '89%',
    },
    {
      'number': '03',
      'day': 'Hari 11',
      'status': 'Infertile',
      'id': 'B04-EGG-03',
      'time': '18 Mei, 14:05',
      'image': 'assets/images/egg03.png',
      'progress': '97%',
    },
  ];

  List<Map<String, dynamic>> get filteredHistory {
    if (selectedFilter == 0) return historyData;

    final selectedStatus = filters[selectedFilter];

    return historyData
        .where((item) => item['status'] == selectedStatus)
        .toList();
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Fertile':
        return const Color(0xFF1768B2);
      case 'Infertile':
        return const Color(0xFF777777);
      case 'Mortalitas':
        return const Color(0xFFD94343);
      default:
        return navy;
    }
  }

  Color statusBackground(String status) {
    switch (status) {
      case 'Fertile':
        return const Color(0xFFE6F0FF);
      case 'Infertile':
        return const Color(0xFFEAEAEA);
      case 'Mortalitas':
        return const Color(0xFFFFE1E1);
      default:
        return Colors.grey.shade200;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),

      // HEADER
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFFFFDF72),
            size: 21,
          ),
        ),
        title: const Text(
          'History',
          style: TextStyle(
            color: Color(0xFFFFDF72),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // FILTER KATEGORI
            SizedBox(
              height: 61,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 15,
                ),
                itemCount: filters.length,
                itemBuilder: (context, index) {
                  final active = selectedFilter == index;

                  final counts = [24, 20, 2, 2];

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedFilter = index;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: active ? navy : const Color(0xFFF0F2F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Text(
                              filters[index],
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: active
                                    ? Colors.white
                                    : const Color(0xFF526174),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${counts[index]}',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: active ? const Color(0xFFFFDF72) : blue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // DAFTAR HISTORY
            Expanded(
              child: filteredHistory.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada riwayat pemeriksaan.',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 12),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 15),
                      itemCount: filteredHistory.length,
                      itemBuilder: (context, index) {
                        final item = filteredHistory[index];

                        return historyCard(item);
                      },
                    ),
            ),
          ],
        ),
      ),

      // BOTTOM NAVIGATION
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(10, 5, 10, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
            bottomItem(Icons.home_rounded, 'Home', 0),
            bottomItem(Icons.videocam_outlined, 'Live', 1),
            bottomItem(Icons.egg_alt_outlined, 'Egg Check', 2),
            bottomItem(Icons.show_chart, 'History', 3),
          ],
        ),
      ),
    );
  }

  // HISTORY CARD
  Widget historyCard(Map<String, dynamic> item) {
    final status = item['status'] as String;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => showDetail(item),
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // FOTO TELUR
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    item['image'],
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: const Color(0xFFEAF1FA),
                        child: const Icon(Icons.egg_alt, color: blue, size: 27),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 3,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: navy.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item['progress'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 9),

            // INFORMASI TELUR
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Egg #${item['number']}',
                        style: const TextStyle(
                          color: Color(0xFF17395F),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCE9FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['day'],
                          style: const TextStyle(
                            color: navy,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 3),

                  Text(
                    status,
                    style: TextStyle(
                      color: status == 'Mortalitas'
                          ? Colors.red
                          : const Color(0xFF263A54),
                      fontSize: 10,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item['id'],
                    style: const TextStyle(
                      color: Color(0xFF7A8797),
                      fontSize: 8,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    item['time'],
                    style: const TextStyle(
                      color: Color(0xFF60799F),
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            // STATUS BADGE DAN PANAH
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBackground(status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: statusColor(status)),
                      const SizedBox(width: 3),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 8,
                          color: statusColor(status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF315F9B),
                  size: 19,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // DETAIL RIWAYAT
  void showDetail(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Detail Pemeriksaan Telur',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text('Nomor Telur: Egg #${item['number']}'),
              const SizedBox(height: 10),
              Text('ID Telur: ${item['id']}'),
              const SizedBox(height: 10),
              Text('Hari Inkubasi: ${item['day']}'),
              const SizedBox(height: 10),
              Text('Hasil: ${item['status']}'),
              const SizedBox(height: 10),
              Text('Waktu Pemeriksaan: ${item['time']}'),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // BOTTOM NAV ITEM
  Widget bottomItem(IconData icon, String title, int index) {
    final active = index == 3;

    return InkWell(
      onTap: () {
        if (index == 3) return;

        if (index == 0) {
          Navigator.pop(context);
        } else if (index == 1) {
          Navigator.pop(context);
          // Navigasi Live dapat dibuka dari Dashboard.
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$title sedang disiapkan')));
        }
      },
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: active ? navy : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: active ? const Color(0xFFFFDF72) : blue,
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 8,
                color: active ? const Color(0xFFFFDF72) : blue,
                fontWeight: active ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
