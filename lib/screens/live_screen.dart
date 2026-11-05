import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class LiveScreen extends StatefulWidget {
  const LiveScreen({super.key});

  static const Color navy = Color(0xFF073566);
  static const Color darkNavy = Color(0xFF062447);
  static const Color softGrey = Color(0xFFF3F3F3);

  @override
  State<LiveScreen> createState() => _LiveScreenState();
}

class _LiveScreenState extends State<LiveScreen> {
  static const String _apiUrl =
      'https://iot.walker880.my.id/api/incubator/latest';

  Timer? _pollTimer;

  bool _isInitialLoading = true;
  bool _isRefreshing = false;

  bool _isOnline = false;
  int? _totalEggs;
  int? _lastSeenSec;
  DateTime? _lastCaptureDateTime;
  List<dynamic> _detections = [];

  Uint8List? _imageBytes;
  bool _isNetworkImage = false;
  String? _networkImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchLatest();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _fetchLatest(),
    );
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  Uint8List? _parseBase64(String? dataUri) {
    if (dataUri == null || dataUri.isEmpty) return null;
    try {
      final clean = dataUri.contains(',') ? dataUri.split(',').last : dataUri;
      return base64Decode(clean.trim());
    } catch (_) {
      return null;
    }
  }

  bool _isNetworkUrl(String? str) {
    if (str == null) return false;
    return str.startsWith('http://') || str.startsWith('https://');
  }

  DateTime? _parseTimestamp(dynamic ts, dynamic lastUpdated) {
    if (ts != null && ts is num && ts > 0) {
      return DateTime.fromMillisecondsSinceEpoch(ts.toInt() * 1000);
    }
    if (lastUpdated != null &&
        lastUpdated is String &&
        lastUpdated.isNotEmpty) {
      try {
        return DateTime.parse(lastUpdated).toLocal();
      } catch (_) {}
    }
    return null;
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final isToday =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')} WIB';

    if (isToday) {
      return 'Hari ini, $timeStr';
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $timeStr';
  }

  String _formatLastSeen(int? sec) {
    if (sec == null) return 'Tidak diketahui';
    if (sec < 5) return 'baru saja';
    if (sec < 60) return '$sec detik lalu';
    final min = sec ~/ 60;
    if (min < 60) return '$min menit lalu';
    final hours = min ~/ 60;
    return '$hours jam lalu';
  }

  Future<void> _fetchLatest({bool isManual = false}) async {
    if (isManual) {
      if (_isRefreshing) return;
      setState(() => _isRefreshing = true);
    }

    try {
      final response = await http
          .get(Uri.parse(_apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final dynamic body = jsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          _applyIncubatorData(body);
          if (isManual && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isOnline
                      ? 'Data diperbarui: $_totalEggs butir telur terdeteksi'
                      : 'Data diperbarui (Inkubator Offline)',
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
      } else {
        if (isManual && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Server merespons kode ${response.statusCode}'),
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isOnline = false;
        });
        if (isManual) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal terhubung ke server inkubator'),
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _isInitialLoading = false;
        });
      }
    }
  }

  void _applyIncubatorData(Map<String, dynamic> data) {
    final lastSeenSec = data['last_seen_sec'] as int?;
    final serverOnline = data['online'] == true;
    final bool online = lastSeenSec != null ? lastSeenSec <= 60 : serverOnline;

    final totalEggs = (data['total_eggs'] as num?)?.toInt() ?? 0;
    final detections = (data['detections'] as List<dynamic>?) ?? [];
    final rawImg = (data['image'] ?? data['url']) as String?;
    final lastUpdated = data['last_updated'];
    final timestamp = data['timestamp'];

    final dt = _parseTimestamp(timestamp, lastUpdated);

    Uint8List? bytes;
    bool isNet = false;
    String? netUrl;

    if (rawImg != null && rawImg.isNotEmpty) {
      if (_isNetworkUrl(rawImg)) {
        isNet = true;
        netUrl = rawImg;
      } else {
        bytes = _parseBase64(rawImg);
      }
    }

    setState(() {
      _isOnline = online;
      _lastSeenSec = lastSeenSec;
      _totalEggs = totalEggs;
      _detections = detections;
      if (dt != null) {
        _lastCaptureDateTime = dt;
      }
      if (bytes != null) {
        _imageBytes = bytes;
        _isNetworkImage = false;
        _networkImageUrl = null;
      } else if (isNet) {
        _isNetworkImage = true;
        _networkImageUrl = netUrl;
        _imageBytes = null;
      }
    });
  }

  bool get _hasImage =>
      _imageBytes != null || (_isNetworkImage && _networkImageUrl != null);

  Widget _buildLiveImage({bool isDialog = false}) {
    if (_imageBytes != null) {
      return Image.memory(
        _imageBytes!,
        fit: isDialog ? BoxFit.contain : BoxFit.cover,
        width: double.infinity,
        height: isDialog ? null : double.infinity,
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(isDialog: isDialog),
      );
    }

    if (_isNetworkImage && _networkImageUrl != null) {
      return Image.network(
        _networkImageUrl!,
        fit: isDialog ? BoxFit.contain : BoxFit.cover,
        width: double.infinity,
        height: isDialog ? null : double.infinity,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                        progress.expectedTotalBytes!
                  : null,
              color: Colors.amber,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) =>
            _buildPlaceholder(isDialog: isDialog),
      );
    }

    return _buildPlaceholder(isDialog: isDialog);
  }

  Widget _buildPlaceholder({bool isDialog = false}) {
    if (_isInitialLoading) {
      return Container(
        color: const Color(0xFF0F172A),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Colors.amber, strokeWidth: 2.5),
              SizedBox(height: 10),
              Text(
                'Menghubungkan ke inkubator...',
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isOnline
                  ? Icons.camera_alt_outlined
                  : Icons.videocam_off_outlined,
              size: 42,
              color: Colors.white.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 8),
            Text(
              _isOnline
                  ? 'Menunggu Tangkapan Citra'
                  : 'Inkubator Offline / Kamera Terputus',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _isOnline
                  ? 'Kamera ESP32-CAM sedang memproses frame'
                  : 'ESP32 belum mengirim citra tray ke server',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showZoomDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.88),
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              maxScale: 5.0,
              minScale: 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _buildLiveImage(isDialog: true),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 26),
                tooltip: 'Tutup',
                onPressed: () => Navigator.pop(context),
              ),
            ),
            Positioned(
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'Cubit untuk memperbesar (Zoom)',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOnline) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOnline ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOnline
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isOnline ? 'Live (Online)' : 'Offline',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: isOnline
                  ? const Color(0xFF166534)
                  : const Color(0xFF991B1B),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final captureText = _lastCaptureDateTime != null
        ? _formatDateTime(_lastCaptureDateTime!)
        : 'Hari ini, ${_formatDateTime(DateTime.now()).split(', ').last}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: LiveScreen.navy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.amber),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Live Incubator',
          style: TextStyle(
            color: Colors.amber,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.amber,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.amber),
            tooltip: 'Segarkan',
            onPressed: _isRefreshing
                ? null
                : () => _fetchLatest(isManual: true),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Status & Waktu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 13,
                              color: Color(0xFF526B8A),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              captureText,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF526B8A),
                              ),
                            ),
                          ],
                        ),
                        _buildStatusBadge(_isOnline),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Kotak Citra Live Tray
                    ClipRRect(
                      borderRadius: BorderRadius.circular(13),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 200,
                            child: _buildLiveImage(),
                          ),

                          // Badge Overlay Kamera
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isOnline
                                      ? const Color(0xFF22C55E)
                                      : const Color(0xFFEF4444),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _isOnline
                                          ? const Color(0xFF22C55E)
                                          : const Color(0xFFEF4444),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    _isOnline
                                        ? 'LIVE OVERHEAD FEED'
                                        : 'CAMERA OFFLINE',
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: _isOnline
                                          ? const Color(0xFF86EFAC)
                                          : const Color(0xFFFCA5A5),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Badge Deteksi Telur di Tray (overlay)
                          if (_totalEggs != null && _totalEggs! > 0)
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.egg,
                                      size: 11,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$_totalEggs Butir',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Tombol Perbesar Foto
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Material(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: _hasImage
                                    ? _showZoomDialog
                                    : () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Belum ada citra untuk diperbesar',
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.zoom_in,
                                        size: 13,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Perbesar Foto',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
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

                    // Grid Real-Time Metadata: Total Telur & Status Koneksi
                    Row(
                      children: [
                        // Kartu Total Telur di Tray
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: LiveScreen.softGrey,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.egg_outlined,
                                        size: 16,
                                        color: LiveScreen.darkNavy,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Telur di Tray',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF526B8A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${_totalEggs ?? 0} Butir',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: LiveScreen.darkNavy,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Deteksi otomatis YOLOv8',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        // Kartu Status Koneksi ESP32
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _isOnline
                                  ? const Color(0xFFF0FDF4)
                                  : const Color(0xFFFEF2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _isOnline
                                    ? const Color(0xFFBBF7D0)
                                    : const Color(0xFFFECACA),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: _isOnline
                                            ? const Color(
                                                0xFF22C55E,
                                              ).withValues(alpha: 0.15)
                                            : const Color(
                                                0xFFEF4444,
                                              ).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _isOnline
                                            ? Icons.sensors
                                            : Icons.sensors_off,
                                        size: 16,
                                        color: _isOnline
                                            ? const Color(0xFF16A34A)
                                            : const Color(0xFFDC2626),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Expanded(
                                      child: Text(
                                        'Status Kamera',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF526B8A),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  _isOnline ? 'Live (Online)' : 'Offline',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: _isOnline
                                        ? const Color(0xFF166534)
                                        : const Color(0xFF991B1B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _isOnline
                                      ? (_lastSeenSec != null
                                            ? 'Aktif ${_formatLastSeen(_lastSeenSec)}'
                                            : 'Terhubung')
                                      : 'Sinyal terputus',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: _isOnline
                                        ? const Color(0xFF15803D)
                                        : const Color(0xFFB91C1C),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Kartu Timestamp Tangkapan Terakhir
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: LiveScreen.softGrey,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: LiveScreen.navy.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.access_time_filled,
                              size: 18,
                              color: LiveScreen.navy,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Waktu Tangkapan Terakhir',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _lastCaptureDateTime != null
                                      ? _formatDateTime(_lastCaptureDateTime!)
                                      : 'Menunggu tangkapan kamera...',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: LiveScreen.darkNavy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isRefreshing)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: LiveScreen.navy,
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Deteksi Rinci / Informasi Monitoring
                    if (_detections.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LiveScreen.softGrey,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 14,
                                  color: LiveScreen.navy,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Deteksi Objek Telur di Tray',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: LiveScreen.darkNavy,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: _detections.asMap().entries.map((
                                entry,
                              ) {
                                final idx = entry.key + 1;
                                final item = entry.value;
                                String label = 'Telur #$idx';
                                if (item is Map && item['confidence'] != null) {
                                  final c = ((item['confidence'] as num) * 100)
                                      .toInt();
                                  label += ' ($c%)';
                                }
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: const Color(0xFFCBD5E1),
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: LiveScreen.darkNavy,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: LiveScreen.softGrey,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 14,
                                  color: LiveScreen.navy,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Informasi Monitoring Tray Inkubator',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: LiveScreen.darkNavy,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Kamera overhead ESP32-CAM mengambil foto tray inkubator secara berkala. Model deteksi menghitung jumlah butir telur di tray secara real-time. Layar ini memperbarui data otomatis tiap 20 detik.',
                              style: TextStyle(
                                fontSize: 10,
                                height: 1.5,
                                color: Color(0xFF555555),
                              ),
                              textAlign: TextAlign.justify,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Tombol Periksa Ulang Telur
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0D000000),
                    offset: Offset(0, -2),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _isRefreshing
                      ? null
                      : () => _fetchLatest(isManual: true),
                  icon: _isRefreshing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.camera_alt_outlined, size: 16),
                  label: Text(
                    _isRefreshing ? 'Memperbarui...' : 'Periksa Ulang Telur',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: LiveScreen.darkNavy,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    disabledBackgroundColor: LiveScreen.darkNavy.withValues(
                      alpha: 0.6,
                    ),
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
