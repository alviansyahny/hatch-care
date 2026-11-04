import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EggCheckScreen extends StatefulWidget {
  const EggCheckScreen({super.key});

  @override
  State<EggCheckScreen> createState() => _EggCheckScreenState();
}

class _EggCheckScreenState extends State<EggCheckScreen> {
  static const String baseUrl = 'https://iot.walker880.my.id';

  final Color navy = const Color(0xFF0D3158);
  final Color blue = const Color(0xFF315F9B);
  final Color yellow = const Color(0xFFFFDF72);
  final Color bgLight = const Color(0xFFF7F9FC);

  // Status Perangkat ESP32
  bool isDeviceOnline = false;
  int? rssi;
  int? lastSeenSec;
  Timer? statusTimer;

  // Parameter Capture
  double exposure = 500;
  double gain = 0;
  double quality = 6;
  double delayMs = 250;

  // State Job Capture
  bool isCapturing = false;
  String jobStatusMessage = '';
  int elapsedSeconds = 0;
  Timer? jobPollTimer;
  Timer? elapsedTimer;

  // Hasil Analisis Terpilih
  Uint8List? mainImageBytes;
  String? predictionLabel;
  double? confidence;
  Map<String, dynamic>? probabilitas;
  String? llmAnalysis;
  Map<String, Uint8List> cvStages = {};
  String selectedStageTitle = 'Foto Asli (Candling)';

  // History List
  List<dynamic> historyList = [];
  bool isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    fetchDeviceStatus();
    statusTimer = Timer.periodic(const Duration(seconds: 5), (_) => fetchDeviceStatus());
    fetchHistory();
  }

  @override
  void dispose() {
    statusTimer?.cancel();
    jobPollTimer?.cancel();
    elapsedTimer?.cancel();
    super.dispose();
  }

  Uint8List? _parseBase64(String? dataUri) {
    if (dataUri == null || dataUri.isEmpty) return null;
    try {
      final clean = dataUri.contains(',') ? dataUri.split(',').last : dataUri;
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  Future<void> fetchDeviceStatus() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/egg/status')).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            isDeviceOnline = data['online'] == true;
            rssi = data['rssi'];
            lastSeenSec = data['last_seen_sec'];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> fetchHistory() async {
    setState(() => isLoadingHistory = true);
    try {
      final res = await http.get(Uri.parse('$baseUrl/egg/history')).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final list = jsonDecode(res.body);
        if (mounted) {
          setState(() {
            historyList = list is List ? list : [];
            isLoadingHistory = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => isLoadingHistory = false);
    }
  }

  Future<void> loadJobDetail(int jobId) async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/egg/job/$jobId')).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final job = jsonDecode(res.body);
        _applyJobData(job);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat detail job #$jobId: $e')),
      );
    }
  }

  void _applyJobData(Map<String, dynamic> job) {
    final rawUrl = job['url'] as String?;
    final pred = job['prediction_result'] as Map<String, dynamic>?;

    final Map<String, Uint8List> stages = {};
    if (pred != null && pred['visualisasi'] != null) {
      final vis = pred['visualisasi'] as Map<String, dynamic>;
      if (vis['citra_crop'] != null) {
        final b = _parseBase64(vis['citra_crop']);
        if (b != null) stages['1. Crop Telur'] = b;
      }
      if (vis['citra_biner_roi'] != null) {
        final b = _parseBase64(vis['citra_biner_roi']);
        if (b != null) stages['2. ROI Biner'] = b;
      }
      if (vis['citra_rekonstruksi_rgb'] != null) {
        final b = _parseBase64(vis['citra_rekonstruksi_rgb']);
        if (b != null) stages['3. Masked RGB'] = b;
      }
      if (vis['citra_peta_darah'] != null) {
        final b = _parseBase64(vis['citra_peta_darah']);
        if (b != null) stages['4. Peta Darah'] = b;
      }
      if (vis['citra_jaringan_darah'] != null) {
        final b = _parseBase64(vis['citra_jaringan_darah']);
        if (b != null) stages['5. Vaskular'] = b;
      }
    }

    setState(() {
      mainImageBytes = _parseBase64(rawUrl);
      selectedStageTitle = 'Foto Asli (Candling)';
      predictionLabel = job['prediction_label'] ?? pred?['label'];
      confidence = (job['confidence'] ?? pred?['keyakinan'])?.toDouble();
      probabilitas = pred?['probabilitas'];
      llmAnalysis = job['llm_analysis'];
      cvStages = stages;
    });
  }

  Future<void> startCapture() async {
    setState(() {
      isCapturing = true;
      jobStatusMessage = 'Mengirim perintah ambil foto ke server...';
      elapsedSeconds = 0;
    });

    elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => elapsedSeconds++);
    });

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/egg/capture'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'exposure': exposure.toInt(),
          'gain': gain.toInt(),
          'quality': quality.toInt(),
          'settle_ms': delayMs.toInt(),
        }),
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        _finishCapture(false, 'Gagal membuat job capture di server (${res.statusCode})');
        return;
      }

      final body = jsonDecode(res.body);
      final int jobId = body['job'];

      jobPollTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) async {
        if (elapsedSeconds > 65) {
          timer.cancel();
          _finishCapture(false, 'Waktu habis menunggu respons ESP32.');
          return;
        }

        try {
          final pollRes = await http.get(Uri.parse('$baseUrl/egg/job/$jobId'));
          if (pollRes.statusCode == 200) {
            final job = jsonDecode(pollRes.body);
            final status = job['status'];

            if (status == 'pending') {
              if (mounted) setState(() => jobStatusMessage = 'Menunggu ESP32 mengambil tugas...');
            } else if (status == 'taken') {
              if (mounted) setState(() => jobStatusMessage = 'ESP32 sedang memotret & mengekstrak citra...');
            } else if (status == 'done') {
              timer.cancel();
              _finishCapture(true, 'Pengambilan Foto & Analisis AI Selesai!');
              _applyJobData(job);
              fetchHistory();
            } else if (status == 'failed') {
              timer.cancel();
              _finishCapture(false, 'Proses pengambilan foto gagal di perangkat ESP32.');
            }
          }
        } catch (_) {}
      });
    } catch (e) {
      _finishCapture(false, 'Kesalahan koneksi: $e');
    }
  }

  void _finishCapture(bool success, String message) {
    jobPollTimer?.cancel();
    elapsedTimer?.cancel();
    if (mounted) {
      setState(() {
        isCapturing = false;
        jobStatusMessage = message;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: success ? Colors.green.shade700 : Colors.red.shade700,
        ),
      );
    }
  }

  Color _getBadgeColor(String? label) {
    switch (label?.toLowerCase()) {
      case 'fertil':
        return const Color(0xFF2CA02C);
      case 'infertil':
        return const Color(0xFF1F77B4);
      case 'mortal':
        return const Color(0xFFD62728);
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: navy,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Egg Checking (Candling)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              fetchDeviceStatus();
              fetchHistory();
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Device Card
            _buildDeviceStatusCard(),
            const SizedBox(height: 14),

            // Preview & Hasil AI Card
            _buildPreviewAndAiCard(),
            const SizedBox(height: 16),

            // 5 Tahapan Computer Vision Gallery
            if (cvStages.isNotEmpty) ...[
              _buildCvStagesSection(),
              const SizedBox(height: 16),
            ],

            // Pengaturan Kamera & Tombol Capture
            _buildCameraControlCard(),
            const SizedBox(height: 20),

            // Riwayat Tangkapan Terakhir
            _buildHistorySection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatusCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDeviceOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isDeviceOnline ? 'ESP32-CAM ONLINE' : 'ESP32-CAM OFFLINE',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDeviceOnline ? const Color(0xFF047857) : const Color(0xFFB91C1C),
            ),
          ),
          const Spacer(),
          if (rssi != null)
            Row(
              children: [
                const Icon(Icons.wifi, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 4),
                Text('$rssi dBm', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
              ],
            ),
          if (lastSeenSec != null) ...[
            const SizedBox(width: 12),
            Text(
              '${lastSeenSec}s lalu',
              style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildPreviewAndAiCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                selectedStageTitle,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              if (predictionLabel != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(predictionLabel),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    predictionLabel!.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Area Citra Telur
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF0B132B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFCBD5E1)),
            ),
            child: mainImageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      mainImageBytes!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                    ),
                  )
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.egg_outlined, size: 48, color: Colors.white.withOpacity(0.3)),
                        const SizedBox(height: 8),
                        Text(
                          'Belum ada tangkapan citra.\nTekan tombol Ambil Foto di bawah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),

          // Detail Keyakinan Model NN
          if (confidence != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Keyakinan Model (Confidence):', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                Text(
                  '${(confidence! * 100).toStringAsFixed(1)}%',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: blue),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence!,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(blue),
                minHeight: 6,
              ),
            ),
          ],

          // Breakdown Probabilitas
          if (probabilitas != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildProbChip('Fertil', probabilitas!['fertil'], const Color(0xFF2CA02C)),
                const SizedBox(width: 8),
                _buildProbChip('Infertil', probabilitas!['infertil'], const Color(0xFF1F77B4)),
                const SizedBox(width: 8),
                _buildProbChip('Mortal', probabilitas!['mortal'], const Color(0xFFD62728)),
              ],
            ),
          ],

          // Penjelasan LLM Vision
          if (llmAnalysis != null && llmAnalysis!.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, size: 16, color: Color(0xFF15803D)),
                      SizedBox(width: 6),
                      Text(
                        'Analisis Pakar AI (LLM Vision)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    llmAnalysis!,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProbChip(String label, dynamic val, Color color) {
    final double pct = (val is num ? val.toDouble() : 0.0) * 100;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: bgLight,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCvStagesSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5 Tahap Pemrosesan Computer Vision (Pilih untuk melihat):',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: cvStages.entries.map((entry) {
                final isSelected = selectedStageTitle == entry.key;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStageTitle = entry.key;
                      mainImageBytes = entry.value;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? blue : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                            child: Image.memory(entry.value, fit: BoxFit.cover),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          color: isSelected ? blue : bgLight,
                          child: Text(
                            entry.key.split('. ').last,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCameraControlCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pengaturan Kamera & Relay Candling',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 12),

          _buildSliderRow('Eksposur', exposure, 0, 1200, (v) => setState(() => exposure = v)),
          _buildSliderRow('Gain Sensor', gain, 0, 30, (v) => setState(() => gain = v)),
          _buildSliderRow('Kualitas JPEG', quality, 4, 15, (v) => setState(() => quality = v)),
          _buildSliderRow('Tunggu LED (ms)', delayMs, 100, 3000, (v) => setState(() => delayMs = v)),

          const SizedBox(height: 14),

          // Tombol Ambil Foto
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: isCapturing ? null : startCapture,
              style: ElevatedButton.styleFrom(
                backgroundColor: navy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: isCapturing
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Text('Memproses (${elapsedSeconds}s)...', style: const TextStyle(fontSize: 13)),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.camera_alt_outlined, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Ambil Foto Candling',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
            ),
          ),

          if (isCapturing) ...[
            const SizedBox(height: 10),
            Text(
              jobStatusMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: blue, fontWeight: FontWeight.w600),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSliderRow(String title, double val, double min, double max, ValueChanged<double> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title (${val.toInt()}):',
              style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
            ),
          ),
          Expanded(
            child: Slider(
              value: val,
              min: min,
              max: max,
              activeColor: blue,
              inactiveColor: const Color(0xFFE2E8F0),
              onChanged: isCapturing ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Riwayat Tangkapan Terakhir',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: navy,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF64748B)),
              onPressed: fetchHistory,
            )
          ],
        ),
        const SizedBox(height: 8),

        if (isLoadingHistory)
          const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()))
        else if (historyList.isEmpty)
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text('Belum ada riwayat foto candling.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          )
        else
          SizedBox(
            height: 115,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: historyList.length,
              itemBuilder: (context, idx) {
                final item = historyList[idx];
                final rawUrl = item['url'] as String?;
                final bytes = _parseBase64(rawUrl);
                final label = item['prediction_label'] as String?;

                return GestureDetector(
                  onTap: () => loadJobDetail(item['id']),
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: bytes != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
                                  child: Image.memory(bytes, fit: BoxFit.cover),
                                )
                              : Container(
                                  color: const Color(0xFF0F172A),
                                  child: const Icon(Icons.broken_image, size: 20, color: Colors.white54),
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                          color: _getBadgeColor(label),
                          child: Text(
                            '#${item['id']} ${label?.toUpperCase() ?? ''}',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
      ],
    );
  }
}
