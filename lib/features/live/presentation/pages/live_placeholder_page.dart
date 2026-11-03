import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';

/// Placeholder sementara untuk tab Live.
///
/// Akan diganti dengan implementasi penuh di tugas berikutnya.
class LivePlaceholderPage extends StatelessWidget {
  const LivePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Live',
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
