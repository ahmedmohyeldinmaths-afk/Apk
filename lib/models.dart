import 'package:flutter/material.dart';

class AppColors {
  static const paper = Color(0xFFFAF8F4);
  static const ink = Color(0xFF1C1B19);
  static const green = Color(0xFF2F4B3C);
  static const gold = Color(0xFFC7973A);
  static const rule = Color(0xFFDDD8CE);
  static const headerBg = Color(0xFFF1EEE5);
  static const muted = Color(0xFF8C8676);

  static const classColors = <Color>[
    Color(0xFF2F4B3C), // green
    Color(0xFF8A4B3B), // brick
    Color(0xFF3B5A73), // steel blue
    Color(0xFF7A5C2E), // ochre
    Color(0xFF5A3B66), // plum
  ];
}

class DayDef {
  final String key;
  final String ar;
  final String en;
  const DayDef(this.key, this.ar, this.en);
}

const List<DayDef> kDays = [
  DayDef('sat', 'السبت', 'Sat'),
  DayDef('sun', 'الأحد', 'Sun'),
  DayDef('mon', 'الإثنين', 'Mon'),
  DayDef('tue', 'الثلاثاء', 'Tue'),
  DayDef('wed', 'الأربعاء', 'Wed'),
  DayDef('thu', 'الخميس', 'Thu'),
];

const int kStartHour = 8;
const int kEndHour = 18; // exclusive-ish, 11 rows

class ClassEntry {
  final String id;
  String title;
  String instructor;
  String room;
  String day; // key from kDays
  String start; // "HH:mm"
  String end; // "HH:mm"
  int colorIndex;

  ClassEntry({
    required this.id,
    required this.title,
    required this.instructor,
    required this.room,
    required this.day,
    required this.start,
    required this.end,
    required this.colorIndex,
  });

  Color get color => AppColors.classColors[colorIndex % AppColors.classColors.length];

  double get startVal => _parse(start);
  double get endVal => _parse(end);

  static double _parse(String t) {
    final parts = t.split(':');
    final h = int.parse(parts[0]);
    final m = int.parse(parts[1]);
    return h + m / 60.0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'instructor': instructor,
        'room': room,
        'day': day,
        'start': start,
        'end': end,
        'colorIndex': colorIndex,
      };

  factory ClassEntry.fromJson(Map<String, dynamic> j) => ClassEntry(
        id: j['id'] as String,
        title: j['title'] as String,
        instructor: (j['instructor'] ?? '') as String,
        room: (j['room'] ?? '') as String,
        day: j['day'] as String,
        start: j['start'] as String,
        end: j['end'] as String,
        colorIndex: (j['colorIndex'] ?? 0) as int,
      );
}
