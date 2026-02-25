import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class AddMedicationPage extends StatefulWidget {
  final MedicationEntry? initial;

  const AddMedicationPage({super.key, this.initial});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  static const List<int> _minuteOptions = [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55];
  final Set<int> _selectedDays = <int>{1, 2, 3, 4, 5, 6, 7};

  late int _hour;
  late int _minute;
  late bool _isAm;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _hour = initial?.hour ?? 9;
    _minute = initial?.minute ?? 30;
    _isAm = initial?.isAm ?? true;
    _nameController.text = initial?.name ?? '';
    _doseController.text = initial?.dose ?? '';
    _selectedDays
      ..clear()
      ..addAll(initial?.days ?? <int>{1, 2, 3, 4, 5, 6, 7});
    _hourController = FixedExtentScrollController(initialItem: _hour - 1);
    final int minuteIndex = _minuteOptions.indexOf(_minute).clamp(0, _minuteOptions.length - 1);
    _minuteController = FixedExtentScrollController(initialItem: minuteIndex);
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _doseController.dispose();
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _stepHour(int delta) {
    final int next = ((_hour - 1 + delta) % 12 + 12) % 12 + 1;
    setState(() => _hour = next);
    _hourController.animateToItem(
      next - 1,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  void _stepMinute(int delta) {
    final int currentIndex = _minuteOptions.indexOf(_minute);
    final int safeIndex = currentIndex == -1 ? 0 : currentIndex;
    final int nextIndex =
        ((safeIndex + delta) % _minuteOptions.length + _minuteOptions.length) % _minuteOptions.length;
    setState(() => _minute = _minuteOptions[nextIndex]);
    _minuteController.animateToItem(
      nextIndex,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool hasName = _nameController.text.trim().isNotEmpty;
    final bool isEdit = widget.initial != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: Color(0xFF1F1F1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          isEdit ? 'Edit Medication' : 'Add Medication',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          const _SectionLabel(text: "What's the name?"),
          const SizedBox(height: 12),
          _TextInputCard(
            controller: _nameController,
            hintText: 'e.g. Vitamin D3',
          ),
          const SizedBox(height: 20),
          const _SectionLabel(text: "What's the dosage?"),
          const SizedBox(height: 12),
          _TextInputCard(
            controller: _doseController,
            hintText: 'e.g. 250mg, 1 Capsule',
          ),
          const SizedBox(height: 28),
          const _SectionLabel(text: 'What time?'),
          const SizedBox(height: 12),
          _TimePickerCard(
            hour: _hour,
            minute: _minute,
            isAm: _isAm,
            hourController: _hourController,
            minuteController: _minuteController,
            minuteOptions: _minuteOptions,
            onHourChanged: (value) => setState(() => _hour = value),
            onMinuteChanged: (value) => setState(() => _minute = value),
            onPeriodChanged: (value) => setState(() => _isAm = value),
            onStepHour: (delta) => _stepHour(delta),
            onStepMinute: (delta) => _stepMinute(delta),
          ),
          const SizedBox(height: 28),
          const _SectionLabel(text: 'Repeat on'),
          const SizedBox(height: 12),
          _WeekdaySelector(
            selectedDays: _selectedDays,
            onChanged: () => setState(() {}),
          ),
          if (isEdit) ...[
            const SizedBox(height: 24),
            _DeleteButton(
              onTap: () => Navigator.of(context).pop(MedicationEditorResult.delete()),
            ),
          ],
          const SizedBox(height: 28),
          _AddButton(
            enabled: hasName,
            label: isEdit ? 'Save Changes' : 'Add Medication',
            onTap: hasName
                ? () {
                    final now = DateTime.now();
                    final entry = MedicationEntry(
                      name: _nameController.text.trim(),
                      dose: _doseController.text.trim(),
                      hour: _hour,
                      minute: _minute,
                      isAm: _isAm,
                      days: _selectedDays.toList()..sort(),
                      createdAt: widget.initial?.createdAt ?? now,
                    );
                    Navigator.of(context).pop(MedicationEditorResult.save(entry));
                  }
                : null,
          ),
        ],
      ),
    );
  }
}

class MedicationEntry {
  final String name;
  final String dose;
  final int hour;
  final int minute;
  final bool isAm;
  final List<int> days;
  final DateTime createdAt;

  const MedicationEntry({
    required this.name,
    required this.dose,
    required this.hour,
    required this.minute,
    required this.isAm,
    required this.days,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'dose': dose,
        'hour': hour,
        'minute': minute,
        'isAm': isAm,
        'days': days,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      name: json['name'] as String? ?? '',
      dose: json['dose'] as String? ?? '',
      hour: json['hour'] as int? ?? 9,
      minute: json['minute'] as int? ?? 0,
      isAm: json['isAm'] as bool? ?? true,
      days: (json['days'] as List<dynamic>? ?? const [1, 2, 3, 4, 5, 6, 7])
          .map((e) => e as int)
          .toList(),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  String get timeLabel {
    final String h = hour.toString().padLeft(2, '0');
    final String m = minute.toString().padLeft(2, '0');
    return '$h:$m ${isAm ? 'AM' : 'PM'}';
  }

  String get frequencyLabel {
    if (days.length == 7) return 'Every day';
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final sorted = days.toList()..sort();
    return sorted.map((d) => labels[(d - 1).clamp(0, 6)]).join(', ');
  }
}

enum MedicationEditorAction { save, delete }

class MedicationEditorResult {
  final MedicationEditorAction action;
  final MedicationEntry? entry;

  const MedicationEditorResult._(this.action, this.entry);

  factory MedicationEditorResult.save(MedicationEntry entry) =>
      MedicationEditorResult._(MedicationEditorAction.save, entry);

  factory MedicationEditorResult.delete() =>
      const MedicationEditorResult._(MedicationEditorAction.delete, null);
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        color: Color(0xFF5E6670),
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TextInputCard extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;

  const _TextInputCard({required this.controller, required this.hintText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 18,
            color: Color(0xFFC2C6CC),
            fontWeight: FontWeight.w600,
          ),
        ),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TimePickerCard extends StatelessWidget {
  final int hour;
  final int minute;
  final bool isAm;
  final FixedExtentScrollController hourController;
  final FixedExtentScrollController minuteController;
  final List<int> minuteOptions;
  final ValueChanged<int> onHourChanged;
  final ValueChanged<int> onMinuteChanged;
  final ValueChanged<bool> onPeriodChanged;
  final ValueChanged<int> onStepHour;
  final ValueChanged<int> onStepMinute;

  const _TimePickerCard({
    required this.hour,
    required this.minute,
    required this.isAm,
    required this.hourController,
    required this.minuteController,
    required this.minuteOptions,
    required this.onHourChanged,
    required this.onMinuteChanged,
    required this.onPeriodChanged,
    required this.onStepHour,
    required this.onStepMinute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _TimeWheel(
            controller: hourController,
            values: List<int>.generate(12, (index) => index + 1),
            selectedValue: hour,
            onSelected: onHourChanged,
            onStep: onStepHour,
          ),
          const Text(':', style: TextStyle(fontSize: 26, color: Color(0xFF9AA1A7))),
          _TimeWheel(
            controller: minuteController,
            values: minuteOptions,
            selectedValue: minute,
            onSelected: onMinuteChanged,
            onStep: onStepMinute,
          ),
          _AmPmToggle(
            isAm: isAm,
            onChanged: onPeriodChanged,
          ),
        ],
      ),
    );
  }
}

class _TimeWheel extends StatelessWidget {
  final FixedExtentScrollController controller;
  final List<int> values;
  final int selectedValue;
  final ValueChanged<int> onSelected;
  final ValueChanged<int> onStep;

  const _TimeWheel({
    required this.controller,
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    required this.onStep,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      height: 150,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) {
          final double localY = details.localPosition.dy;
          if (localY < 75) {
            onStep(-1);
          } else {
            onStep(1);
          }
        },
        child: ListWheelScrollView.useDelegate(
          controller: controller,
          physics: const FixedExtentScrollPhysics(),
          itemExtent: 48,
          onSelectedItemChanged: (index) => onSelected(values[index]),
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: values.length,
            builder: (context, index) {
              final bool isSelected = values[index] == selectedValue;
              final String label = values[index].toString().padLeft(2, '0');
              return Center(
                child: Container(
                  width: 64,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFDFF8E8) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: isSelected ? 30 : 20,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                      color: isSelected ? const Color(0xFF2AD660) : const Color(0xFFCDD2D7),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AmPmToggle extends StatelessWidget {
  final bool isAm;
  final ValueChanged<bool> onChanged;

  const _AmPmToggle({required this.isAm, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AmPmPill(text: 'AM', selected: isAm, onTap: () => onChanged(true)),
        const SizedBox(height: 12),
        _AmPmPill(text: 'PM', selected: !isAm, onTap: () => onChanged(false)),
      ],
    );
  }
}

class _AmPmPill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _AmPmPill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2AD660) : const Color(0xFFF3F4F5),
          borderRadius: BorderRadius.circular(14),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2AD660).withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : const Color(0xFF9AA1A7),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _WeekdaySelector extends StatelessWidget {
  final Set<int> selectedDays;
  final VoidCallback onChanged;

  const _WeekdaySelector({required this.selectedDays, required this.onChanged});

  static const List<String> _labels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(7, (index) {
          final day = index + 1;
          final selected = selectedDays.contains(day);
          return Padding(
            padding: EdgeInsets.only(right: index == 6 ? 0 : 10),
            child: _DayChip(
              label: _labels[index],
              selected: selected,
              onTap: () {
                if (selectedDays.length == 1 && selected) return;
                if (selected) {
                  selectedDays.remove(day);
                } else {
                  selectedDays.add(day);
                }
                onChanged();
              },
            ),
          );
        }),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DayChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 44,
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF2AD660) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : const Color(0xFF8A8F95),
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onTap;
  final String label;

  const _AddButton({required this.enabled, required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF88C8E8) : const Color(0xFFBFD7E6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(CupertinoIcons.check_mark_circled_solid, color: Colors.white),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _DeleteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFFDECEC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF5B5B5)),
        ),
        child: const Text(
          'Delete Medication',
          style: TextStyle(
            color: Color(0xFFD9534F),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
