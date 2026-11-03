import 'package:flutter/material.dart';

import 'package:hatch_care/core/constants/app_colors.dart';

/// Placeholder sementara untuk tab Egg Check.
///
/// Akan diganti dengan implementasi penuh di tugas berikutnya.
class EggCheckPlaceholderPage extends StatelessWidget {
  const EggCheckPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Egg Check',
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
