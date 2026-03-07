import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_medication_page.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final List<MedicationEntry> _added = [];
  static const String _storageKey = 'medications';

  late DateTime _focusedMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _focusedMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_storageKey) ?? [];
    final loaded = raw
        .map(
          (item) => MedicationEntry.fromJson(
            jsonDecode(item) as Map<String, dynamic>,
          ),
        )
        .toList();
    if (!mounted) return;
    setState(() {
      _added
        ..clear()
        ..addAll(loaded);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<MedicationEntry> _entriesForDate(DateTime date) {
    return _added.where((e) => e.days.contains(date.weekday)).toList();
  }

  int _takenCountForDate(DateTime date) {
    return _entriesForDate(date)
        .where((e) => e.lastTakenAt != null && _isSameDay(e.lastTakenAt!, date))
        .length;
  }

  double _progressForDate(DateTime date) {
    final entries = _entriesForDate(date);
    if (entries.isEmpty) return 0;
    return _takenCountForDate(date) / entries.length;
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateTime firstDay = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final int startOffset = firstDay.weekday - 1;
    final int daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final DateTime gridStart = firstDay.subtract(Duration(days: startOffset));

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9F6),
        elevation: 0,
        title: const Text(
          'Schedule',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(CupertinoIcons.calendar, color: Color(0xFF1F1F1F)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _MonthHeader(
            month: _focusedMonth,
            onPrevious: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
          const SizedBox(height: 16),
          const _WeekdayHeader(),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 10,
              crossAxisSpacing: 6,
              childAspectRatio: 0.95,
            ),
            itemBuilder: (context, index) {
              final DateTime date = gridStart.add(Duration(days: index));
              final bool inMonth = date.month == _focusedMonth.month;
              final bool isToday = _isSameDay(date, now);
              final bool isSelected = _isSameDay(date, _selectedDate);
              final double progress = _progressForDate(date);

              return GestureDetector(
                onTap: () => setState(() => _selectedDate = date),
                child: _CalendarDayCell(
                  date: date,
                  inMonth: inMonth,
                  isToday: isToday,
                  isSelected: isSelected,
                  progress: progress,
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          _DetailCard(
            date: _selectedDate,
            total: _entriesForDate(_selectedDate).length,
            taken: _takenCountForDate(_selectedDate),
            entries: _entriesForDate(_selectedDate),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2AD660),
        unselectedItemColor: const Color(0xFF9AA1A7),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        onTap: (index) {
          if (index == 0) {
            Navigator.of(context).pop();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar_today, size: 22),
            activeIcon: Icon(CupertinoIcons.calendar_today, size: 22),
            label: 'TODAY',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar, size: 22),
            activeIcon: Icon(CupertinoIcons.calendar, size: 22),
            label: 'SCHEDULE',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar, size: 22),
            activeIcon: Icon(CupertinoIcons.chart_bar, size: 22),
            label: 'TRENDS',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear, size: 22),
            activeIcon: Icon(CupertinoIcons.gear, size: 22),
            label: 'SETTINGS',
          ),
        ],
      ),
    );
  }
}

class _MonthHeader extends StatelessWidget {
  final DateTime month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
  });

  String get _label {
    const labels = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${labels[month.month - 1]} ${month.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: onPrevious,
          icon: const Icon(CupertinoIcons.chevron_left, size: 20),
        ),
        Text(
          _label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
        IconButton(
          onPressed: onNext,
          icon: const Icon(CupertinoIcons.chevron_right, size: 20),
        ),
      ],
    );
  }
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (label) => Expanded(
              child: Center(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8A8F95),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _CalendarDayCell extends StatelessWidget {
  final DateTime date;
  final bool inMonth;
  final bool isToday;
  final bool isSelected;
  final double progress;

  const _CalendarDayCell({
    required this.date,
    required this.inMonth,
    required this.isToday,
    required this.isSelected,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final Color textColor = inMonth ? const Color(0xFF1F1F1F) : const Color(0xFFB3B8BD);
    final Color ringColor = progress > 0 ? const Color(0xFF2AD660) : const Color(0xFFE2E6E9);
    final Color bgColor = isSelected ? const Color(0xFFE8F7EE) : Colors.transparent;
    final Color todayBorder = isToday ? const Color(0xFF2AD660) : Colors.transparent;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: todayBorder, width: 1.2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 28,
            width: 28,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: const Color(0xFFE2E6E9),
                  valueColor: AlwaysStoppedAnimation<Color>(ringColor),
                ),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final DateTime date;
  final int total;
  final int taken;
  final List<MedicationEntry> entries;

  const _DetailCard({
    required this.date,
    required this.total,
    required this.taken,
    required this.entries,
  });

  String get _dateLabel {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final String day = labels[(date.weekday - 1).clamp(0, 6)];
    final String month = date.month.toString().padLeft(2, '0');
    final String dayNum = date.day.toString().padLeft(2, '0');
    return '$day, $month/$dayNum';
  }

  @override
  Widget build(BuildContext context) {
    final double progress = total == 0 ? 0 : taken / total;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dateLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$taken of $total completed',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B9B65),
                ),
              ),
              SizedBox(
                height: 34,
                width: 34,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 4,
                  backgroundColor: const Color(0xFFE2E6E9),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2AD660)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            const Text(
              'No reminders for this day.',
              style: TextStyle(color: Color(0xFF8A8F95)),
            )
          else
            ...entries.map(
              (entry) {
                final bool isTaken =
                    entry.lastTakenAt != null && entry.lastTakenAt!.year == date.year &&
                    entry.lastTakenAt!.month == date.month &&
                    entry.lastTakenAt!.day == date.day;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            entry.timeLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF8A8F95),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isTaken ? const Color(0xFFDFF8E8) : const Color(0xFFF3F4F5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isTaken ? 'Taken' : 'Pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isTaken ? const Color(0xFF2AD660) : const Color(0xFF8A8F95),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
