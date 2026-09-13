import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';
import 'schedule_screen.dart';

void main() {
  runApp(const ScheduleApp());
}

class ScheduleApp extends StatelessWidget {
  const ScheduleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'جدول الحصص',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.green,
          background: AppColors.paper,
        ),
        fontFamily: 'Georgia',
      ),
      home: const ScheduleScreen(),
    );
  }
}
