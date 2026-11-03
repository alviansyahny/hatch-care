import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/features/dashboard/domain/models/dashboard_models.dart';

/// Kartu kondisi inkubator: nilai sensor terkini + grafik tren 24 jam.
///
/// Menggabungkan tampilan teks (design/screens/09_dashboard_1.png) dan
/// grafik garis (design/screens/10_dashboard_2.png) dalam satu kartu
/// yang dapat di-scroll bersama dashboard.
class IncubatorConditionCard extends StatelessWidget {
  const IncubatorConditionCard({
    super.key,
    required this.condition,
    required this.chartPoints,
  });

  final IncubatorCondition condition;
  final List<ChartDataPoint> chartPoints;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.neutral,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul kartu + ikon menu
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Kondisi Inkubator',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(Icons.more_vert, color: AppColors.textMuted, size: 20),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Legenda grafik (turun ke baris baru kalau layar sempit)
          const Wrap(
            spacing: AppSpacing.md,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _LegendItem(color: AppColors.primary, label: 'Suhu (°C)'),
              _LegendItem(color: AppColors.tertiary, label: 'Kelembapan (%RH)'),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Grafik tren (fl_chart)
          SizedBox(
            height: 120,
            child: chartPoints.length < 2
                ? const SizedBox.shrink()
                : _ConditionLineChart(points: chartPoints),
          ),

          const SizedBox(height: AppSpacing.md),

          // Divider tipis
          const Divider(color: AppColors.borderLight, height: 1),

          const SizedBox(height: AppSpacing.md),

          // Nilai sensor terkini: Suhu | Kelembapan
          Row(
            children: [
              Expanded(
                child: _SensorValue(
                  label: 'Suhu',
                  icon: Icons.thermostat_outlined,
                  valueText: '${condition.temperature.toStringAsFixed(1)} °C',
                  statusLabel: condition.tempStatus,
                ),
              ),
              Container(width: 1, height: 48, color: AppColors.borderLight),
              Expanded(
                child: _SensorValue(
                  label: 'Kelembapan',
                  icon: Icons.water_drop_outlined,
                  valueText: '${condition.humidity} %RH',
                  statusLabel: condition.humStatus,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Operasi & rotasi rak (turun ke baris baru kalau layar sempit)
          Wrap(
            spacing: AppSpacing.md,
            runSpacing: 4,
            children: [
              _InfoItem(
                icon: Icons.access_time_outlined,
                text: 'Operasi: ${condition.operationalHours} Jam',
              ),
              _InfoItem(
                icon: Icons.sync_outlined,
                text: 'Rotasi Rak: Tiap ${condition.rackRotationHours} Jam',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Grafik garis tren suhu & kelembapan
// ---------------------------------------------------------------------------

class _ConditionLineChart extends StatelessWidget {
  const _ConditionLineChart({required this.points});

  final List<ChartDataPoint> points;

  List<FlSpot> _tempSpots() =>
      points.map((p) => FlSpot(p.hour, p.tempSeries)).toList();

  List<FlSpot> _humSpots() =>
      points.map((p) => FlSpot(p.hour, p.humSeries)).toList();

  Widget _buildXTitle(double value, TitleMeta meta) {
    // Hanya tampilkan label di jam bulat yang ditentukan.
    if (value != value.roundToDouble()) return const SizedBox.shrink();
    final label = switch (value.round()) {
      0 => '00:00',
      4 => '04:00',
      8 => '08:00',
      12 => '12:00',
      16 => '16:00',
      20 => 'Sekarang',
      _ => null,
    };
    if (label == null) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        label,
        style: const TextStyle(fontSize: 9, color: AppColors.textMuted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        minY: 35,
        maxY: 100,
        clipData: const FlClipData.all(),
        lineBarsData: [
          // Garis suhu — biru (AppColors.primary)
          LineChartBarData(
            spots: _tempSpots(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.primary,
            barWidth: 2,
            dotData: FlDotData(
              checkToShowDot: (spot, barData) => spot == barData.spots.last,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primary,
                    strokeWidth: 0,
                    strokeColor: AppColors.primary,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          // Garis kelembapan — kuning (AppColors.tertiary)
          LineChartBarData(
            spots: _humSpots(),
            isCurved: true,
            curveSmoothness: 0.35,
            color: AppColors.tertiary,
            barWidth: 2,
            dotData: FlDotData(
              checkToShowDot: (spot, barData) => spot == barData.spots.last,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.tertiary,
                    strokeWidth: 0,
                    strokeColor: AppColors.tertiary,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.tertiary.withValues(alpha: 0.12),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 4,
              reservedSize: 22,
              getTitlesWidget: _buildXTitle,
            ),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widget pembantu
// ---------------------------------------------------------------------------

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppColors.textBody),
          ),
        ),
      ],
    );
  }
}

class _SensorValue extends StatelessWidget {
  const _SensorValue({
    required this.label,
    required this.icon,
    required this.valueText,
    required this.statusLabel,
  });

  final String label;
  final IconData icon;
  final String valueText;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label + badge: badge turun ke baris baru kalau tidak muat
          Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 14, color: AppColors.iconAccent),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              _StatusBadge(label: statusLabel),
            ],
          ),
          const SizedBox(height: 4),
          // Nilai besar: mengecil sendiri kalau tidak muat
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valueText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeSuccessBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: AppColors.badgeSuccessText,
        ),
      ),
    );
  }
}
