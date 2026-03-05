import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_medication_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
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

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _added.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, data);
  }

  int _to24Hour(MedicationEntry entry) {
    if (entry.isAm) {
      return entry.hour % 12;
    }
    return entry.hour % 12 + 12;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final visibleAdded = _added.where((entry) => entry.days.contains(now.weekday)).toList();
    final morning = visibleAdded.where((e) => _to24Hour(e) < 12).toList();
    final afternoon = visibleAdded.where((e) => _to24Hour(e) >= 12 && _to24Hour(e) < 17).toList();
    final evening = visibleAdded.where((e) => _to24Hour(e) >= 17).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF6F9F6),
        elevation: 0,
        title: const Text(
          'Good Morning',
          style: TextStyle(
            fontSize: 26,
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
          const _DateRow(),
          const SizedBox(height: 24),
          const _ProgressCard(),
          const SizedBox(height: 28),
          if (morning.isNotEmpty) ...[
            const _SectionTitle(title: 'MORNING'),
            const SizedBox(height: 12),
            ...morning.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AddedMedicationTile(
                    entry: entry,
                    onDelete: () {
                      setState(() => _added.remove(entry));
                      _saveAll();
                    },
                    onEdit: () {
                      Navigator.of(context)
                          .push<MedicationEditorResult>(
                            MaterialPageRoute(
                              builder: (_) => AddMedicationPage(initial: entry),
                            ),
                          )
                          .then((result) {
                            if (result == null) return;
                            if (result.action == MedicationEditorAction.delete) {
                              setState(() => _added.remove(entry));
                              _saveAll();
                              return;
                            }
                            if (result.action == MedicationEditorAction.save &&
                                result.entry != null) {
                              final int realIndex = _added.indexOf(entry);
                              if (realIndex != -1) {
                                setState(() => _added[realIndex] = result.entry!);
                              }
                              _saveAll();
                            }
                          });
                    },
                  ),
                )),
            const SizedBox(height: 24),
          ],
          if (afternoon.isNotEmpty) ...[
            const _SectionTitle(title: 'AFTERNOON'),
            const SizedBox(height: 12),
            ...afternoon.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AddedMedicationTile(
                    entry: entry,
                    onDelete: () {
                      setState(() => _added.remove(entry));
                      _saveAll();
                    },
                    onEdit: () {
                      Navigator.of(context)
                          .push<MedicationEditorResult>(
                            MaterialPageRoute(
                              builder: (_) => AddMedicationPage(initial: entry),
                            ),
                          )
                          .then((result) {
                            if (result == null) return;
                            if (result.action == MedicationEditorAction.delete) {
                              setState(() => _added.remove(entry));
                              _saveAll();
                              return;
                            }
                            if (result.action == MedicationEditorAction.save &&
                                result.entry != null) {
                              final int realIndex = _added.indexOf(entry);
                              if (realIndex != -1) {
                                setState(() => _added[realIndex] = result.entry!);
                              }
                              _saveAll();
                            }
                          });
                    },
                  ),
                )),
            const SizedBox(height: 24),
          ],
          if (evening.isNotEmpty) ...[
            const _SectionTitle(title: 'EVENING'),
            const SizedBox(height: 12),
            ...evening.map((entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AddedMedicationTile(
                    entry: entry,
                    onDelete: () {
                      setState(() => _added.remove(entry));
                      _saveAll();
                    },
                    onEdit: () {
                      Navigator.of(context)
                          .push<MedicationEditorResult>(
                            MaterialPageRoute(
                              builder: (_) => AddMedicationPage(initial: entry),
                            ),
                          )
                          .then((result) {
                            if (result == null) return;
                            if (result.action == MedicationEditorAction.delete) {
                              setState(() => _added.remove(entry));
                              _saveAll();
                              return;
                            }
                            if (result.action == MedicationEditorAction.save &&
                                result.entry != null) {
                              final int realIndex = _added.indexOf(entry);
                              if (realIndex != -1) {
                                setState(() => _added[realIndex] = result.entry!);
                              }
                              _saveAll();
                            }
                          });
                    },
                  ),
                )),
          ],
          const SizedBox(height: 20),
          _AddReminderCard(
            onTap: () {
              Navigator.of(context)
                  .push<MedicationEditorResult>(
                    MaterialPageRoute(
                      builder: (_) => const AddMedicationPage(),
                    ),
                  )
                  .then((result) {
                    if (result?.action == MedicationEditorAction.save &&
                        result?.entry != null) {
                      setState(() => _added.add(result!.entry!));
                      _saveAll();
                    }
                  });
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF2AD660),
        unselectedItemColor: const Color(0xFF9AA1A7),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar_today),
            label: 'TODAY',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'SCHEDULE',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chart_bar),
            label: 'TRENDS',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.gear),
            label: 'SETTINGS',
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Tuesday, May 14',
      style: TextStyle(
        fontSize: 16,
        color: Color(0xFF3B9B65),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F1F1F),
              ),
            ),
            SizedBox(height: 6),
            Text(
              '3 of 5 completed',
              style: TextStyle(fontSize: 14, color: Color(0xFF3B9B65)),
            ),
          ],
        ),
        Container(
          height: 64,
          width: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFFB5F3C7), width: 6),
          ),
          child: const Text(
            '65%',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        letterSpacing: 1.2,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: Color(0xFF8A8F95),
      ),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final String status;
  final String name;
  final String time;
  final String dose;
  final String action;
  final bool muted;

  const _MedicationCard({
    required this.status,
    required this.name,
    required this.time,
    required this.dose,
    required this.action,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color titleColor = muted
        ? const Color(0xFF9AA1A7)
        : const Color(0xFF1F1F1F);
    final Color subColor = muted
        ? const Color(0xFFB3B8BD)
        : const Color(0xFF3B9B65);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (status.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: muted
                        ? const Color(0xFFEDEFF1)
                        : const Color(0xFFDFF8E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: muted
                          ? const Color(0xFF9AA1A7)
                          : const Color(0xFF2AD660),
                    ),
                  ),
                ),
              if (status.isNotEmpty) const SizedBox(height: 8),
              Text(
                name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text('$time • $dose', style: TextStyle(color: subColor)),
            ],
          ),
          if (action == 'check')
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFDFF8E8),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(CupertinoIcons.check_mark, color: Color(0xFF2AD660)),
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: muted
                    ? const Color(0xFFF3F4F5)
                    : const Color(0xFF2AD660),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                action,
                style: TextStyle(
                  color: muted ? const Color(0xFF8A8F95) : Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AddedMedicationTile extends StatefulWidget {
  final MedicationEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _AddedMedicationTile({
    required this.entry,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<_AddedMedicationTile> createState() => _AddedMedicationTileState();
}

class _AddedMedicationTileState extends State<_AddedMedicationTile> {
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xFFFDECEC))),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: AnimatedOpacity(
              opacity: _progress > 0.08 ? 1 : 0,
              duration: const Duration(milliseconds: 120),
              child: InkWell(
                onTap: widget.onDelete,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9C9C9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(CupertinoIcons.trash, color: Color(0xFFD9534F)),
                ),
              ),
            ),
          ),
          Dismissible(
            key: ValueKey(
              'medication-${widget.entry.createdAt.toIso8601String()}-${widget.entry.name}',
            ),
            direction: DismissDirection.endToStart,
            dismissThresholds: const {DismissDirection.endToStart: 0.6},
            onUpdate: (details) => setState(() => _progress = details.progress),
            onDismissed: (_) => widget.onDelete(),
            child: InkWell(
              onTap: widget.onEdit,
              borderRadius: BorderRadius.circular(16),
              child: _MedicationCard(
                status: '',
                name: widget.entry.name,
                time: widget.entry.timeLabel,
                dose: widget.entry.dose,
                action: 'Taken',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddReminderCard extends StatelessWidget {
  final VoidCallback? onTap;

  const _AddReminderCard({this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFFEFFAF2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFB5F3C7),
            width: 1.5,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          children: const [
            CircleAvatar(
              backgroundColor: Color(0xFF2AD660),
              child: Icon(CupertinoIcons.add, color: Colors.white),
            ),
            SizedBox(height: 12),
            Text(
              'Add another reminder',
              style: TextStyle(
                color: Color(0xFF3B9B65),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
