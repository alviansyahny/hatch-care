import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/constants/app_spacing.dart';
import 'package:hatch_care/core/enums/egg_status.dart';
import 'package:hatch_care/features/egg_check/domain/models/egg_check_models.dart';

/// Daftar horizontal kartu candling baki telur terkini ("Recent Tray Candlings").
class EggCheckTrayList extends StatelessWidget {
  const EggCheckTrayList({
    super.key,
    required this.batchTitle,
    required this.items,
    required this.onSelectItem,
  });

  final String batchTitle;
  final List<EggCheckTrayItem> items;
  final ValueChanged<int> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header seksi (responsif dengan Wrap agar tidak overflow pada layar kecil)
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: 4,
          children: [
            const Text(
              'Recent Tray Candlings',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              batchTitle,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.iconAccent,
              ),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.sm),

        // Daftar horizontal telur
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
            itemBuilder: (context, index) {
              final item = items[index];
              return _TrayItemCard(
                item: item,
                onTap: () => onSelectItem(item.eggNumber),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TrayItemCard extends StatelessWidget {
  const _TrayItemCard({
    required this.item,
    required this.onTap,
  });

  final EggCheckTrayItem item;
  final VoidCallback onTap;

  Color get _statusDotColor {
    final status = item.status;
    if (status == null) return AppColors.badgeInfertileDot;
    return switch (status) {
      EggStatus.fertil => AppColors.statusConnected,
      EggStatus.infertil => AppColors.badgeInfertileDot,
      EggStatus.mortalitas => AppColors.badgeMortalitasDot,
    };
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 104,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar / Placeholder preview candling
            Container(
              height: 84,
              width: 104,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: item.isLiveTarget
                      ? AppColors.primary
                      : AppColors.borderLight,
                  width: item.isLiveTarget ? 1.5 : 1.0,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: item.isLiveTarget
                  ? _buildLiveTargetPreview()
                  : _buildCandledPreview(),
            ),

            const SizedBox(height: 6),

            // Nomor telur + titik status
            Row(
              children: [
                Expanded(
                  child: Text(
                    item.displayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _statusDotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 1),

            // Teks status
            Text(
              item.statusLabel,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveTargetPreview() {
    return Container(
      color: const Color(0xFFEBEFF4),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(
              Icons.camera_alt_outlined,
              color: AppColors.iconAccent,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              'Live Target',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.iconAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCandledPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Visualisasi telur candling transluminasi dengan gradien hangat
        Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0.0, -0.1),
              radius: 0.85,
              colors: [
                Color(0xFFFFC658),
                Color(0xFFE67E22),
                Color(0xFFB03A2E),
                Color(0xFF1E0A04),
              ],
              stops: [0.0, 0.45, 0.75, 1.0],
            ),
          ),
          child: CustomPaint(
            painter: _MiniVeinPainter(),
          ),
        ),

        // Badge persentase keyakinan di pojok kanan bawah
        if (item.confidencePercent != null)
          Positioned(
            right: 6,
            bottom: 6,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.tertiary,
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                '${item.confidencePercent}%',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Mini painter untuk efek pembuluh darah pada kartu thumbnail kecil.
class _MiniVeinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final veinPaint = Paint()
      ..color = const Color(0xFF5A1400).withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final path = Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(
        center.dx - 12,
        center.dy - 10,
        center.dx - 22,
        center.dy - 20,
      )
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(
        center.dx + 14,
        center.dy - 8,
        center.dx + 25,
        center.dy - 18,
      )
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(
        center.dx + 10,
        center.dy + 14,
        center.dx + 18,
        center.dy + 25,
      );

    canvas.drawPath(path, veinPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
