import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/egg_check/domain/models/candling_job_models.dart';
import 'package:hatch_care/features/egg_check/presentation/providers/egg_check_backend_provider.dart';

/// Layar Egg Checking terintegrasi dengan backend IoT ESP32 & AI Candling.
///
/// Semua jaringan lewat repository (tidak ada HTTP di layar):
/// - Status perangkat: [eggDeviceStatusProvider] (polling 5 detik).
/// - Riwayat tangkapan: [eggCaptureHistoryProvider].
/// - Proses capture: [eggCaptureProvider] (polling job 1,5 detik).
class EggCheckPage extends ConsumerStatefulWidget {
  const EggCheckPage({super.key});

  @override
  ConsumerState<EggCheckPage> createState() => _EggCheckPageState();
}

class _EggCheckPageState extends ConsumerState<EggCheckPage> {
  // Parameter Capture
  double exposure = 500;
  double gain = 0;
  double quality = 6;
  double delayMs = 250;

  // Hasil Analisis Terpilih
  String selectedStageTitle = 'Foto Asli (Candling)';
  String? selectedImageBase64;
  EggCaptureDetail? selectedResult;
  EggCaptureDetail? _appliedCaptureResult;

  @override
  Widget build(BuildContext context) {
    final deviceStatus = ref.watch(eggDeviceStatusProvider);
    final history = ref.watch(eggCaptureHistoryProvider);
    final capture = ref.watch(eggCaptureProvider);

    // Hasil capture yang baru selesai otomatis tampil di preview + snackbar.
    ref.listen(eggCaptureProvider, (previous, next) {
      final result = next.value?.result;
      if (result != null && !identical(result, _appliedCaptureResult)) {
        _appliedCaptureResult = result;
        setState(() {
          selectedResult = result;
          selectedImageBase64 = result.mainImageBase64;
          selectedStageTitle = 'Foto Asli (Candling)';
        });
      }
      final wasCapturing = previous?.value?.isCapturing ?? false;
      final isCapturing = next.value?.isCapturing ?? false;
      final message = next.value?.statusMessage ?? '';
      if (wasCapturing && !isCapturing && message.isNotEmpty) {
        final success = message.contains('Selesai');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: success
                ? Colors.green.shade700
                : Colors.red.shade700,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      appBar: AppBar(
        backgroundColor: AppColors.deepNavy,
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
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              ref.read(eggDeviceStatusProvider.notifier).refresh();
              ref.read(eggCaptureHistoryProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Device Card
            _buildDeviceStatusCard(deviceStatus),
            const SizedBox(height: 14),

            // Preview & Hasil AI Card
            _buildPreviewAndAiCard(),
            const SizedBox(height: 16),

            // 5 Tahapan Computer Vision Gallery
            if (selectedResult != null &&
                selectedResult!.stages.isNotEmpty) ...[
              _buildCvStagesSection(selectedResult!.stages),
              const SizedBox(height: 16),
            ],

            // Pengaturan Kamera & Tombol Capture
            _buildCameraControlCard(
              capture.value ?? const EggCaptureState.initial(),
            ),
            const SizedBox(height: 20),

            // Riwayat Tangkapan Terakhir
            _buildHistorySection(history),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Uint8List? _decodeBase64(String? dataUri) {
    if (dataUri == null || dataUri.isEmpty) return null;
    try {
      final clean = dataUri.contains(',') ? dataUri.split(',').last : dataUri;
      return base64Decode(clean);
    } catch (_) {
      return null;
    }
  }

  Color _getBadgeColor(String? label) {
    switch (label?.toLowerCase()) {
      case 'fertil':
        return AppColors.badgeFertil;
      case 'infertil':
        return AppColors.badgeInfertil;
      case 'mortal':
        return AppColors.badgeMortal;
      default:
        return Colors.grey.shade700;
    }
  }

  Widget _buildDeviceStatusCard(AsyncValue<EggDeviceStatus> asyncStatus) {
    final status = asyncStatus.value ?? const EggDeviceStatus(online: false);
    final isDeviceOnline = status.online;
    final rssi = status.rssi;
    final lastSeenSec = status.lastSeenSec;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              color: isDeviceOnline
                  ? AppColors.statusOnline
                  : AppColors.statusOffline,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDeviceOnline ? 'ESP32-CAM ONLINE' : 'ESP32-CAM OFFLINE',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDeviceOnline
                    ? AppColors.statusOnlineText
                    : AppColors.statusOfflineText,
              ),
            ),
          ),
          if (rssi != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.wifi, size: 14, color: AppColors.textSlate),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '$rssi dBm',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSlate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (lastSeenSec != null) ...[
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                '${lastSeenSec}s lalu',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSlateLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviewAndAiCard() {
    final result = selectedResult;
    final predictionLabel = result?.label;
    final confidence = result?.confidence;
    final probabilities = result?.probabilities ?? const <String, double>{};
    final llmAnalysis = result?.llmAnalysis;
    final mainImage = _decodeBase64(
      selectedImageBase64 ?? result?.mainImageBase64,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slateBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
              Expanded(
                child: Text(
                  selectedStageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ),
              if (predictionLabel != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getBadgeColor(predictionLabel),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    predictionLabel.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Area Citra Telur
          Container(
            height: 240,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.candlingDark,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.candlingFrame),
            ),
            child: mainImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.memory(
                      mainImage,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      cacheWidth: 900,
                    ),
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.egg_outlined,
                          size: 48,
                          color: Colors.white30,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada tangkapan citra.\nTekan tombol Ambil Foto di bawah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
          ),

          // Detail Keyakinan Model NN
          if (confidence != null) ...[
            const SizedBox(height: 14),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Keyakinan Model (Confidence):',
                  style: TextStyle(fontSize: 12, color: AppColors.textSlate),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blueAccent,
                ),
              ),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: confidence.clamp(0.0, 1.0),
                backgroundColor: AppColors.slateBorder,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.blueAccent,
                ),
                minHeight: 6,
              ),
            ),
          ],

          // Breakdown Probabilitas
          if (probabilities.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                _buildProbChip(
                  'Fertil',
                  probabilities['fertil'],
                  AppColors.badgeFertil,
                ),
                const SizedBox(width: 8),
                _buildProbChip(
                  'Infertil',
                  probabilities['infertil'],
                  AppColors.badgeInfertil,
                ),
                const SizedBox(width: 8),
                _buildProbChip(
                  'Mortal',
                  probabilities['mortal'],
                  AppColors.badgeMortal,
                ),
              ],
            ),
          ],

          // Penjelasan LLM Vision
          if (llmAnalysis != null && llmAnalysis.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.expertBoxBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.expertBoxBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 16,
                        color: AppColors.expertGreen,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Analisis Pakar AI (LLM Vision)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.expertGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    llmAnalysis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppColors.expertText,
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

  Widget _buildProbChip(String label, double? val, Color color) {
    final double pct = (val ?? 0.0) * 100;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.pageBackground,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.slateBorder),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${pct.toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCvStagesSection(List<CandlingStage> stages) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5 Tahap Pemrosesan Computer Vision (Pilih untuk melihat):',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.sectionLabel,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: stages.map((stage) {
                final isSelected = selectedStageTitle == stage.title;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedStageTitle = stage.title;
                      selectedImageBase64 = stage.imageBase64;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 72,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.blueAccent
                            : AppColors.slateBorder,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(7),
                            ),
                            child: Image.memory(
                              _decodeBase64(stage.imageBase64) ?? Uint8List(0),
                              fit: BoxFit.cover,
                              cacheWidth: 300,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(color: AppColors.candlingDarkDeep),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          color: isSelected
                              ? AppColors.blueAccent
                              : AppColors.pageBackground,
                          child: Text(
                            stage.title,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSlateDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraControlCard(EggCaptureState capture) {
    final isCapturing = capture.isCapturing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pengaturan Kamera & Relay Candling',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 12),

          _buildSliderRow(
            'Eksposur',
            exposure,
            0,
            1200,
            isCapturing,
            (v) => setState(() => exposure = v),
          ),
          _buildSliderRow(
            'Gain Sensor',
            gain,
            0,
            30,
            isCapturing,
            (v) => setState(() => gain = v),
          ),
          _buildSliderRow(
            'Kualitas JPEG',
            quality,
            4,
            15,
            isCapturing,
            (v) => setState(() => quality = v),
          ),
          _buildSliderRow(
            'Tunggu LED (ms)',
            delayMs,
            100,
            3000,
            isCapturing,
            (v) => setState(() => delayMs = v),
          ),

          const SizedBox(height: 14),

          // Tombol Ambil Foto
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: isCapturing
                  ? null
                  : () => ref
                        .read(eggCaptureProvider.notifier)
                        .start(
                          CaptureParams(
                            exposure: exposure.toInt(),
                            gain: gain.toInt(),
                            quality: quality.toInt(),
                            settleMs: delayMs.toInt(),
                          ),
                        ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.deepNavy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: isCapturing
                  ? FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Memproses (${capture.elapsedSeconds}s)...',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Ambil Foto Candling',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          if (isCapturing) ...[
            const SizedBox(height: 10),
            Text(
              capture.statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.blueAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSliderRow(
    String title,
    double val,
    double min,
    double max,
    bool isCapturing,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$title (${val.toInt()}):',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSlateDark,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: val,
              min: min,
              max: max,
              activeColor: AppColors.blueAccent,
              inactiveColor: AppColors.slateBorder,
              onChanged: isCapturing ? null : onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistorySection(
    AsyncValue<List<EggCaptureSummary>> asyncHistory,
  ) {
    final isLoading = asyncHistory.isLoading && !asyncHistory.hasValue;
    final historyList = asyncHistory.value ?? const <EggCaptureSummary>[];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                'Riwayat Tangkapan Terakhir',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.deepNavy,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.refresh,
                size: 18,
                color: AppColors.textSlate,
              ),
              onPressed: () =>
                  ref.read(eggCaptureHistoryProvider.notifier).refresh(),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(12),
              child: CircularProgressIndicator(),
            ),
          )
        else if (historyList.isEmpty)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              asyncHistory.hasError && !asyncHistory.hasValue
                  ? 'Gagal memuat riwayat: '
                        '${(asyncHistory.error! as ApiException).message}'
                  : 'Belum ada riwayat foto candling.',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSlateLight,
              ),
            ),
          )
        else
          SizedBox(
            height: 115,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: historyList.length,
              itemBuilder: (context, idx) {
                final item = historyList[idx];
                final bytes = _decodeBase64(item.mainImageBase64);
                final label = item.label;

                return GestureDetector(
                  onTap: () => _loadJobDetail(item.id),
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.slateBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: bytes != null
                              ? ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(7),
                                  ),
                                  child: Image.memory(
                                    bytes,
                                    fit: BoxFit.cover,
                                    cacheWidth: 300,
                                  ),
                                )
                              : Container(
                                  color: AppColors.candlingDarkDeep,
                                  child: const Icon(
                                    Icons.broken_image,
                                    size: 20,
                                    color: Colors.white54,
                                  ),
                                ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 4,
                            horizontal: 2,
                          ),
                          color: _getBadgeColor(label),
                          child: Text(
                            '#${item.id} ${label?.toUpperCase() ?? ''}',
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
          ),
      ],
    );
  }

  Future<void> _loadJobDetail(int jobId) async {
    try {
      final detail = await ref
          .read(eggCheckRepositoryProvider)
          .fetchJobDetail(jobId);
      if (!mounted) return;
      setState(() {
        selectedResult = detail;
        selectedImageBase64 = detail.mainImageBase64;
        selectedStageTitle = 'Foto Asli (Candling)';
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail job #$jobId: ${e.message}'),
        ),
      );
    }
  }
}
