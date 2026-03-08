import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_medication_page.dart';
import 'dashboard_page.dart';
import 'schedule_page.dart';
import 'settings_page.dart';

class TrendsPage extends StatefulWidget {
  const TrendsPage({super.key});

  @override
  State<TrendsPage> createState() => _TrendsPageState();
}

class _TrendsPageState extends State<TrendsPage> {
  final List<MedicationEntry> _added = [];
  static const String _storageKey = 'medications';

  @override
  void initState() {
    super.initState();
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

  List<DateTime> _last7Days(DateTime today) {
    return List.generate(7, (i) => DateTime(today.year, today.month, today.day - (6 - i)));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime today = DateTime.now();
    final days = _last7Days(today);
    final int totalPlanned = days.fold(0, (sum, d) => sum + _entriesForDate(d).length);
    final int totalTaken = days.fold(0, (sum, d) => sum + _takenCountForDate(d));
    final double weeklyProgress = totalPlanned == 0 ? 0 : totalTaken / totalPlanned;
    final int percent = (weeklyProgress * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9F6),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark, color: Color(0xFF1F1F1F)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Weekly Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 8),
          _RingSummary(percent: percent, progress: weeklyProgress),
          const SizedBox(height: 20),
          const _EncourageBlock(),
          const SizedBox(height: 20),
          _WeekCard(days: days, progressForDate: _progressForDate),
          const SizedBox(height: 18),
          const _StreakCard(
            title: 'Morning Vitamins',
            subtitle: '6/7 days completed',
            icon: CupertinoIcons.leaf_arrow_circlepath,
            accent: Color(0xFFE1F8E9),
          ),
          const SizedBox(height: 12),
          const _StreakCard(
            title: 'Evening Magnesium',
            subtitle: 'Perfect streak! 7/7',
            icon: CupertinoIcons.drop,
            accent: Color(0xFFF1F4F7),
          ),
          const SizedBox(height: 18),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2AD660),
              foregroundColor: const Color(0xFF0F1A12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const DashboardPage()),
                (route) => false,
              );
            },
            child: const Text('Back to Dashboard'),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Swipe up for detailed history',
              style: TextStyle(color: Color(0xFF9AA1A7)),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2,
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
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const DashboardPage()),
            );
          }
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SchedulePage()),
            );
          }
          if (index == 3) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            );
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

class _RingSummary extends StatelessWidget {
  final int percent;
  final double progress;

  const _RingSummary({required this.percent, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 220,
        width: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 200,
              width: 200,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 16,
                backgroundColor: const Color(0xFFE1E7EA),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2AD660)),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Adherence',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EncourageBlock extends StatelessWidget {
  const _EncourageBlock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          "You're doing great!",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Consistency is key. You've stayed on\ntrack for most of the week.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF6B7280),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

class _WeekCard extends StatelessWidget {
  final List<DateTime> days;
  final double Function(DateTime) progressForDate;

  const _WeekCard({required this.days, required this.progressForDate});

  String _rangeLabel() {
    final DateTime start = days.first;
    final DateTime end = days.last;
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[start.month - 1]} ${start.day} - ${months[end.month - 1]} ${end.day}';
  }

  @override
  Widget build(BuildContext context) {
    const weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Container(
      padding: const EdgeInsets.all(16),
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (i) {
              final double progress = progressForDate(days[i]);
              final Color dot = progress >= 0.6
                  ? const Color(0xFF2AD660)
                  : const Color(0xFFE1E7EA);
              return Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    weekdayLabels[i],
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8A8F95),
                    ),
                  ),
                ],
              );
            }),
          ),
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _rangeLabel(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
              ),
              const Text(
                'GOAL: 90%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2AD660),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const _StreakCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFCFF5D9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF2AD660)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5E6670),
                  ),
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_right, color: Color(0xFF9AA1A7)),
        ],
      ),
    );
  }
}
