import 'package:flutter/material.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key});

  static const Color navy = Color(0xFF073566);
  static const Color darkNavy = Color(0xFF062447);
  static const Color softGrey = Color(0xFFF3F3F3);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}-'
        '${now.minute.toString().padLeft(2, '0')}-'
        '${now.second.toString().padLeft(2, '0')} WIB';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Waktu pemeriksaan
                    Text(
                      'Hari ini, $time',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF526B8A),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Gambar hasil candling
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 160,
                            child: Image.asset(
                              'assets/images/hasil_candling.png',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFE8EDF2),
                                  child: const Center(
                                    child: Icon(
                                      Icons.image_not_supported_outlined,
                                      size: 45,
                                      color: Colors.grey,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          // Tombol perbesar foto
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Material(
                              color: const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      child: InteractiveViewer(
                                        child: Image.asset(
                                          'assets/images/hasil_candling.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.zoom_in,
                                        size: 13,
                                        color: darkNavy,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Perbesar Foto',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w600,
                                          color: darkNavy,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Hasil klasifikasi
                    const Center(
                      child: Text(
                        'FERTIL',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: darkNavy,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Deskripsi morfologi
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: softGrey,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.biotech, size: 13, color: navy),
                              SizedBox(width: 5),
                              Text(
                                'Deskripsi Morfologi Vaskular',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: darkNavy,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          const Text(
                            'Struktur pembuluh darah alantois (blood islands) '
                            'tampak jelas menyebar dari embrio. Denyut '
                            'kapiler dan batas transparansi kantung udara '
                            'terdeteksi normal sesuai perkembangan fisiologis '
                            'Hari ke-11.',
                            style: TextStyle(
                              fontSize: 9,
                              height: 1.6,
                              color: Color(0xFF555555),
                            ),
                            textAlign: TextAlign.justify,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol periksa ulang
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 7, 14, 12),
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Memulai pemeriksaan ulang telur...'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.camera_alt_outlined, size: 16),
                  label: const Text(
                    'Periksa Ulang Telur',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkNavy,
                    foregroundColor: Colors.white,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
