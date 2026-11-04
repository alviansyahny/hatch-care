import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';
import 'package:hatch_care/core/enums/egg_status.dart';

// --- String UI ---
const _kReadyLabel = 'Ready';

/// Badge status telur berbentuk pill (● label).
///
/// Digunakan di kartu riwayat candling dan widget lain yang
/// menampilkan status telur. Gunakan [EggStatusBadge.ready] untuk
/// status telur yang belum dicandling (Ready).
class EggStatusBadge extends StatelessWidget {
  /// Badge untuk status hasil candling (Fertile / Infertile / Mortalitas).
  const EggStatusBadge({super.key, required EggStatus this.status});

  /// Badge untuk status "Ready" (belum dicandling, bukan hasil candling).
  const EggStatusBadge.ready({super.key}) : status = null;

  /// Status telur. `null` menandakan Ready.
  final EggStatus? status;

  Color get _backgroundColor {
    final s = status;
    if (s == null) return AppColors.badgeInfertileBg;
    return switch (s) {
      EggStatus.fertil => AppColors.badgeFertileBg,
      EggStatus.infertil => AppColors.badgeInfertileBg,
      EggStatus.mortalitas => AppColors.badgeMortalitasBg,
    };
  }

  Color get _textColor {
    final s = status;
    if (s == null) return AppColors.primary;
    return switch (s) {
      EggStatus.fertil => AppColors.primary,
      EggStatus.infertil => AppColors.primary,
      EggStatus.mortalitas => AppColors.badgeMortalitasText,
    };
  }

  Color get _dotColor {
    final s = status;
    if (s == null) return AppColors.badgeInfertileDot;
    return switch (s) {
      EggStatus.fertil => AppColors.statusConnected,
      EggStatus.infertil => AppColors.badgeInfertileDot,
      EggStatus.mortalitas => AppColors.badgeMortalitasDot,
    };
  }

  String get _label {
    return status?.label ?? _kReadyLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            _label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}

