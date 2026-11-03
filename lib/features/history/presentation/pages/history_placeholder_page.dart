import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';

/// Placeholder sementara untuk tab History.
///
/// Akan diganti dengan implementasi penuh di tugas berikutnya.
class HistoryPlaceholderPage extends StatelessWidget {
  const HistoryPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'History',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
