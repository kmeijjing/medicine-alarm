import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'account_management_page.dart';
import 'dashboard_page.dart';
import 'schedule_page.dart';
import 'trends_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const String _weekStartKey = 'settings_week_start';

  String _weekStart = 'mon';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _weekStart = prefs.getString(_weekStartKey) ?? 'mon';
    });
  }

  Future<void> _saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SettingsSection(
            title: '설정',
            children: [
              _SettingsTile(title: '알림 설정', onTap: () {}),
              _SettingsTile(title: '언어 설정', onTap: () {}),
              _SettingsTile(title: '달력 시작 요일', onTap: () {}),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: '고객센터',
            children: [
              _SettingsTile(title: '문의하기', onTap: () {}),
              const _SettingsTile(title: '앱 버전'),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: '정보',
            children: [
              _SettingsTile(title: '서비스 이용약관', onTap: () {}),
              _SettingsTile(title: '개인정보 처리방침', onTap: () {}),
              _SettingsTile(title: '공지사항', onTap: () {}),
            ],
          ),
          const SizedBox(height: 16),
          _SettingsSection(
            title: '계정',
            children: [
              _SettingsTile(
                title: '계정관리',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AccountManagementPage(),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
          if (index == 2) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const TrendsPage()),
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;

  const _SettingsTile({required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final Widget trailing = onTap == null
        ? const SizedBox.shrink()
        : const Icon(
            CupertinoIcons.chevron_right,
            color: Color.fromARGB(255, 196, 196, 196),
            size: 16,
          );
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1F1F1F),
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _SegmentedRow extends StatelessWidget {
  final String label;
  final Map<String, String> options;
  final String value;
  final ValueChanged<String> onChanged;

  const _SegmentedRow({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final entries = options.entries.toList();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: List.generate(entries.length, (index) {
                final entry = entries[index];
                final bool selected = entry.key == value;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFFDFF8E8)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? const Color(0xFF2AD660)
                              : const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
