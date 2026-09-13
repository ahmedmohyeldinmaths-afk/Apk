import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';

class ScheduleStorage {
  static const _key = 'class_schedule_entries_v1';

  static Future<List<ClassEntry>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      return _seed();
    }
    try {
      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => ClassEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _seed();
    }
  }

  static Future<void> save(List<ClassEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_key, raw);
  }

  static List<ClassEntry> _seed() => [
        ClassEntry(
          id: 'seed1',
          title: 'الرياضيات',
          instructor: 'أ. سارة',
          room: 'قاعة 3',
          day: 'sat',
          start: '09:00',
          end: '10:30',
          colorIndex: 0,
        ),
        ClassEntry(
          id: 'seed2',
          title: 'Physics',
          instructor: 'Dr. Amin',
          room: 'Lab 2',
          day: 'sun',
          start: '10:30',
          end: '12:00',
          colorIndex: 2,
        ),
        ClassEntry(
          id: 'seed3',
          title: 'اللغة العربية',
          instructor: 'أ. منى',
          room: 'قاعة 1',
          day: 'mon',
          start: '08:00',
          end: '09:30',
          colorIndex: 3,
        ),
        ClassEntry(
          id: 'seed4',
          title: 'Chemistry',
          instructor: 'Dr. Nabil',
          room: 'Lab 1',
          day: 'tue',
          start: '13:00',
          end: '14:30',
          colorIndex: 1,
        ),
      ];
}
