import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/network/api_exception.dart';
import 'package:hatch_care/features/history/domain/models/history_models.dart';
import 'package:hatch_care/features/history/presentation/providers/history_provider.dart';
import 'package:hatch_care/features/history/presentation/widgets/capture_detail_sheet.dart';
import 'package:hatch_care/features/history/presentation/widgets/capture_grid_tile.dart';
import 'package:hatch_care/features/history/presentation/widgets/history_filter_chips.dart';

/// Layar riwayat tangkapan kamera inkubator (tab History di menu bawah).
///
/// Menampilkan semua foto yang diambil ESP32-CAM pada 1 jam terakhir dari
/// halaman Live, lengkap dengan kondisi tray saat foto diambil (suhu,
/// kelembapan, lampu, motor) dan hasil deteksi telur YOLO untuk foto
/// terbaru. Ketuk kartu untuk detail + perbandingan before/after.
class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  bool? _wasActive;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh otomatis saat tab History kembali aktif, agar foto baru dari
    // menu Live (beserta analisis YOLO-nya) langsung muncul.
    final isActive = TickerMode.of(context);
    if (_wasActive == false && isActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        try {
          await ref.read(incubatorHistoryProvider.notifier).refresh();
        } on ApiException {
          // Kegagalan sudah ditampilkan lewat state provider.
        }
      });
    }
    _wasActive = isActive;
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(incubatorHistoryProvider);
    final data = asyncData.value ?? const CaptureHistoryData.empty();
    final records = ref.watch(filteredCaptureRecordsProvider);
    final isRefreshing = ref.watch(captureRefreshingProvider);
    final isFirstLoading = asyncData.isLoading && !asyncData.hasValue;
    final hasError = asyncData.hasError && !asyncData.hasValue;
    final errorMessage = asyncData.error is ApiException
        ? (asyncData.error! as ApiException).message
        : 'Tidak dapat terhubung ke server inkubator.';

    return Scaffold(
      backgroundColor: AppColors.fieldFill,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.neutral,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            tooltip: 'Segarkan',
            icon: isRefreshing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.tertiary,
                    ),
                  )
                : const Icon(Icons.refresh),
            onPressed: isRefreshing
                ? null
                : () => ref.read(incubatorHistoryProvider.notifier).refresh(),
          ),
        ],
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SafeArea(
        child: isFirstLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : hasError
            ? _ErrorView(
                message: errorMessage,
                onRetry: () =>
                    ref.read(incubatorHistoryProvider.notifier).refresh(),
              )
            : _HistoryBody(data: data, records: records),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Isi halaman saat data sudah termuat
// ---------------------------------------------------------------------------

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.data, required this.records});

  final CaptureHistoryData data;
  final List<CaptureRecord> records;

  @override
  Widget build(BuildContext context) {
    if (data.records.isEmpty) {
      return const _EmptyView();
    }

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusStrip(online: data.online, total: data.records.length),
                const SizedBox(height: AppSpacing.md),
                _SummaryRow(
                  temperature: data.temperature,
                  humidity: data.humidity,
                  latest: data.records.first,
                ),
                const SizedBox(height: AppSpacing.md),
                const HistoryFilterChips(),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xs,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          sliver: records.isEmpty
              ? const SliverToBoxAdapter(child: _FilteredEmptyView())
              : SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: AppSpacing.sm,
                    crossAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: records.length,
                  itemBuilder: (context, index) {
                    final record = records[index];
                    return CaptureGridTile(
                      record: record,
                      onTap: () => showCaptureDetailSheet(
                        context,
                        records: data.records,
                        index: data.records.indexOf(record),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Status + ringkasan
// ---------------------------------------------------------------------------

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.online, required this.total});

  final bool online;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: online ? AppColors.statusConnected : AppColors.textMuted,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              online
                  ? 'Kamera online · $total foto (1 jam terakhir)'
                  : 'Kamera offline · $total foto tersimpan',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textBody,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.temperature,
    required this.humidity,
    required this.latest,
  });

  final double? temperature;
  final double? humidity;
  final CaptureRecord latest;

  @override
  Widget build(BuildContext context) {
    final eggCount = latest.eggCount;
    final subtitle = latest.hasDetection
        ? '${latest.intactEggCount} utuh · ${latest.crackedEggCount} retak'
        : latest.detectionPending
        ? 'sedang dianalisis'
        : latest.detectionFailed
        ? 'deteksi gagal'
        : null;
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.thermostat,
            label: 'Suhu',
            value: temperature != null
                ? '${temperature!.toStringAsFixed(1)}°C'
                : '-',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            icon: Icons.water_drop_outlined,
            label: 'Kelembapan',
            value: humidity != null ? '${humidity!.toStringAsFixed(0)}%' : '-',
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _SummaryCard(
            icon: Icons.egg_outlined,
            label: 'Telur',
            value: eggCount != null ? '$eggCount butir' : '-',
            subtitle: subtitle,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.infoCardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// State kosong & error
// ---------------------------------------------------------------------------

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Belum ada foto inkubator.\nFoto akan muncul setelah kamera '
              'mengirim tangkapan pertama.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSlate),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilteredEmptyView extends StatelessWidget {
  const _FilteredEmptyView();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(AppSpacing.xl),
      child: Center(
        child: Text(
          'Tidak ada foto pada filter ini.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: AppColors.textSlate),
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '$message Coba lagi nanti.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textSlate),
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Coba Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
