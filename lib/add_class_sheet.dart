import 'package:flutter/material.dart';
import 'models.dart';

class AddClassSheet extends StatefulWidget {
  final String initialDay;
  const AddClassSheet({super.key, required this.initialDay});

  @override
  State<AddClassSheet> createState() => _AddClassSheetState();
}

class _AddClassSheetState extends State<AddClassSheet> {
  final _titleCtrl = TextEditingController();
  final _instructorCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  late String _day;
  TimeOfDay _start = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _end = const TimeOfDay(hour: 10, minute: 0);
  int _colorIndex = 0;

  @override
  void initState() {
    super.initState();
    _day = widget.initialDay;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _instructorCtrl.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _start : _end,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _start = picked;
        } else {
          _end = picked;
        }
      });
    }
  }

  void _save() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final entry = ClassEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      instructor: _instructorCtrl.text.trim(),
      room: _roomCtrl.text.trim(),
      day: _day,
      start: _fmt(_start),
      end: _fmt(_end),
      colorIndex: _colorIndex,
    );
    Navigator.pop(context, entry);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.paper,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'حصة جديدة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.ink),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _label('اسم المادة / Subject'),
                TextField(
                  controller: _titleCtrl,
                  autofocus: true,
                  decoration: _inputDecoration('مثال: الرياضيات / Math'),
                ),
                const SizedBox(height: 14),
                _label('اليوم'),
                DropdownButtonFormField<String>(
                  value: _day,
                  decoration: _inputDecoration(null),
                  items: kDays
                      .map((d) => DropdownMenuItem(
                            value: d.key,
                            child: Text('${d.ar} / ${d.en}'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _day = v ?? _day),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('من'),
                          OutlinedButton(
                            onPressed: () => _pickTime(true),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.rule),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(_fmt(_start)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _label('إلى'),
                          OutlinedButton(
                            onPressed: () => _pickTime(false),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.rule),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(_fmt(_end)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _label('المدرس / Instructor'),
                TextField(
                  controller: _instructorCtrl,
                  decoration: _inputDecoration(null),
                ),
                const SizedBox(height: 14),
                _label('القاعة / Room'),
                TextField(
                  controller: _roomCtrl,
                  decoration: _inputDecoration(null),
                ),
                const SizedBox(height: 14),
                _label('اللون'),
                Row(
                  children: List.generate(AppColors.classColors.length, (i) {
                    final selected = i == _colorIndex;
                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _colorIndex = i),
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.classColors[i],
                            shape: BoxShape.circle,
                            border: selected
                                ? Border.all(color: AppColors.ink, width: 2)
                                : null,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: const Text(
                    'حفظ الحصة',
                    style: TextStyle(
                      color: AppColors.paper,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A5648),
          ),
        ),
      );

  InputDecoration _inputDecoration(String? hint) => InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.rule),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColors.rule),
        ),
      );
}
