import 'package:flutter/material.dart';

import 'package:hatch_care/app/router/app_router.dart';
import 'package:hatch_care/app/theme/app_theme.dart';

/// Widget root aplikasi HATCH-CARE.
class HatchCareApp extends StatelessWidget {
  const HatchCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HATCH-CARE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}

