import 'package:flutter/material.dart';
import 'models.dart';
import 'storage.dart';
import 'add_class_sheet.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<ClassEntry> _entries = [];
  bool _loading = true;

  static const double hourHeight = 64;
  static const double hourColWidth = 48;
  static const double dayColWidth = 118;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await ScheduleStorage.load();
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _persist() async {
    await ScheduleStorage.save(_entries);
  }

  void _openAdd({String? day}) async {
    final result = await showModalBottomSheet<ClassEntry>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddClassSheet(initialDay: day ?? kDays.first.key),
    );
    if (result != null) {
      setState(() => _entries.add(result));
      _persist();
    }
  }

  void _removeEntry(String id) {
    setState(() => _entries.removeWhere((e) => e.id == id));
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.green)),
      );
    }

    final totalHours = kEndHour - kStartHour;
    final gridHeight = totalHours * hourHeight;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.paper,
        appBar: AppBar(
          backgroundColor: AppColors.paper,
          elevation: 0,
          toolbarHeight: 76,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'جدول الحصص',
                style: TextStyle(
                  color: AppColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  'Weekly Class Timetable',
                  style: TextStyle(
                    color: AppColors.muted,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openAdd(),
          backgroundColor: AppColors.green,
          icon: const Icon(Icons.add, color: AppColors.paper),
          label: const Text(
            'إضافة حصة',
            style: TextStyle(color: AppColors.paper, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.rule),
                  borderRadius: BorderRadius.circular(4),
                  color: const Color(0xFFFFFEFB),
                ),
                child: Column(
                  children: [
                    // Header row
                    Row(
                      children: [
                        Container(
                          width: hourColWidth,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: AppColors.headerBg,
                            border: Border(
                              bottom: BorderSide(color: AppColors.rule),
                              left: BorderSide(color: AppColors.rule),
                            ),
                          ),
                        ),
                        ...kDays.map((d) => Container(
                              width: dayColWidth,
                              height: 52,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: AppColors.headerBg,
                                border: Border(
                                  bottom: BorderSide(color: AppColors.rule),
                                  left: BorderSide(color: AppColors.rule),
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    d.ar,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      d.en,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.muted,
                                        fontFamily: 'Roboto',
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                    // Grid body
                    SizedBox(
                      height: gridHeight,
                      child: Stack(
                        children: [
                          // hour lines + labels + tappable cells
                          Row(
                            children: [
                              Column(
                                children: List.generate(totalHours, (i) {
                                  final h = kStartHour + i;
                                  return Container(
                                    width: hourColWidth,
                                    height: hourHeight,
                                    alignment: Alignment.topCenter,
                                    padding: const EdgeInsets.only(top: 4),
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(color: Color(0xFFEDE9DE)),
                                        left: BorderSide(color: AppColors.rule),
                                      ),
                                    ),
                                    child: Directionality(
                                      textDirection: TextDirection.ltr,
                                      child: Text(
                                        '${h.toString().padLeft(2, '0')}:00',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppColors.muted,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                              ...kDays.map((d) => Column(
                                    children: List.generate(totalHours, (i) {
                                      return GestureDetector(
                                        onTap: () => _openAdd(day: d.key),
                                        child: Container(
                                          width: dayColWidth,
                                          height: hourHeight,
                                          decoration: const BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(color: Color(0xFFEDE9DE)),
                                              left: BorderSide(color: Color(0xFFEDE9DE)),
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  )),
                            ],
                          ),
                          // class blocks
                          ..._entries.map((c) {
                            final dayIndex = kDays.indexWhere((d) => d.key == c.day);
                            if (dayIndex == -1) return const SizedBox.shrink();
                            final top = (c.startVal - kStartHour) * hourHeight;
                            final height = (c.endVal - c.startVal) * hourHeight;
                            final left = hourColWidth + dayIndex * dayColWidth;
                            return Positioned(
                              top: top,
                              left: left + 3,
                              width: dayColWidth - 6,
                              height: height,
                              child: GestureDetector(
                                onLongPress: () => _confirmDelete(c),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: c.color,
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.18),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                  child: SingleChildScrollView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c.title,
                                          style: const TextStyle(
                                            color: AppColors.paper,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Directionality(
                                          textDirection: TextDirection.ltr,
                                          child: Text(
                                            '${c.start} – ${c.end}',
                                            style: const TextStyle(
                                              color: AppColors.paper,
                                              fontSize: 10,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        ),
                                        if (c.room.isNotEmpty)
                                          Text(
                                            c.room,
                                            style: const TextStyle(
                                              color: AppColors.paper,
                                              fontSize: 10,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(ClassEntry c) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paper,
        title: const Text('حذف الحصة؟'),
        content: Text('هل تريد حذف "${c.title}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeEntry(c.id);
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
