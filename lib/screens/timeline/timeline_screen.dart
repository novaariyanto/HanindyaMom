import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/timeline_service.dart';
import 'package:hanindyamom/services/feeding_service.dart';
import 'package:hanindyamom/services/diaper_service.dart';
import 'package:hanindyamom/services/sleep_service.dart';
import 'package:hanindyamom/services/growth_service.dart';
import 'package:hanindyamom/utils/validators.dart';
import 'package:hanindyamom/screens/activities/feeding_form_screen.dart';
import 'package:hanindyamom/screens/activities/diaper_form_screen.dart';
import 'package:hanindyamom/screens/activities/sleep_form_screen.dart';
import 'package:hanindyamom/screens/growth/growth_form_screen.dart';
import 'package:hanindyamom/screens/nutrition/nutrition_form_screen.dart';
import 'package:hanindyamom/screens/milestone/milestone_form_screen.dart';
import 'package:hanindyamom/models/feeding.dart' as fm;
import 'package:hanindyamom/models/diaper.dart' as dm;
import 'package:hanindyamom/models/sleep.dart' as sm;

enum ActivityFilter { all, feeding, diaper, sleep, growth, milestone, nutrition }

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  ActivityFilter _selectedFilter = ActivityFilter.all;
  List<TimelineActivity> activities = [];
  bool _loading = true;
  String? _error;
  bool _didFetch = false;
  SelectedBabyProvider? _babyProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      _didFetch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchTimeline();
      });
    }
    final provider = context.read<SelectedBabyProvider>();
    if (_babyProvider != provider) {
      _babyProvider?.removeListener(_onBabyChanged);
      _babyProvider = provider;
      _babyProvider?.addListener(_onBabyChanged);
    }
  }

  void _onBabyChanged() {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (!mounted) return;
    if (babyId == null) {
      setState(() {
        _loading = false;
      });
      return;
    }
    _fetchTimeline();
  }

  @override
  void dispose() {
    _babyProvider?.removeListener(_onBabyChanged);
    super.dispose();
  }

  Future<void> _fetchTimeline() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final raw = await TimelineService().list(babyId);
      activities = raw.map<TimelineActivity>((e) {
        final typeStr = (e['type'] as String?) ?? '';
        final timeStr = e['time'] ?? e['start_time'] ?? e['date'];
        final time = DateTime.tryParse(timeStr) ?? DateTime.now();
        final title = e['title'] ?? e['name'] ?? typeStr.toUpperCase();
        final subtitle = e['subtitle'] ?? e['notes'] ?? '';
        final map = _mapType(typeStr);
        final id =  e['id'] ?? e['id'] ?? '';
        return TimelineActivity(
          id: id,
          type: map.type,
          time: time,
          title: title,
          subtitle: subtitle,
          icon: map.icon,
          color: map.color,
        );
      }).toList();
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  List<TimelineActivity> get filteredActivities {
    if (_selectedFilter == ActivityFilter.all) {
      return activities;
    }
    
    final filterType = switch (_selectedFilter) {
      ActivityFilter.feeding => ActivityType.feeding,
      ActivityFilter.diaper => ActivityType.diaper,
      ActivityFilter.sleep => ActivityType.sleep,
      ActivityFilter.growth => ActivityType.growth,
      ActivityFilter.milestone => ActivityType.milestone,
      ActivityFilter.nutrition => ActivityType.nutrition,
      ActivityFilter.all => throw UnimplementedError(),
    };
    
    return activities.where((activity) => activity.type == filterType).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Timeline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : Column(
                  children: [
                    _buildFilterChips(),
                    Expanded(
                      child: filteredActivities.isEmpty ? _buildEmptyState() : _buildTimeline(),
                    ),
                  ],
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.restaurant), title: const Text('Tambah Feeding'), onTap: () async { Navigator.pop(context); await _addFeeding(); }),
            ListTile(leading: const Icon(Icons.baby_changing_station), title: const Text('Tambah Diaper'), onTap: () async { Navigator.pop(context); await _addDiaper(); }),
            ListTile(leading: const Icon(Icons.bedtime), title: const Text('Tambah Tidur'), onTap: () async { Navigator.pop(context); await _addSleep(); }),
            ListTile(leading: const Icon(Icons.monitor_weight), title: const Text('Tambah Growth'), onTap: () async { Navigator.pop(context); await _addGrowth(); }),
            ListTile(leading: const Icon(Icons.emoji_events), title: const Text('Tambah Milestone'), onTap: () async { Navigator.pop(context); await _addMilestone(); }),
            ListTile(leading: const Icon(Icons.restaurant_menu), title: const Text('Tambah Nutrisi'), onTap: () async { Navigator.pop(context); await _addNutrition(); }),
          ],
        ),
      ),
    );
  }

  Future<void> _addFeeding() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final ok = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FeedingFormScreen(babyId: babyId)),
    );
    if (ok == true) _fetchTimeline();
  }

  Future<void> _addDiaper() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final ok = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DiaperFormScreen(babyId: babyId)),
    );
    if (ok == true) _fetchTimeline();
  }

  Future<void> _addSleep() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final ok = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SleepFormScreen(babyId: babyId)),
    );
    if (ok == true) _fetchTimeline();
  }

  Future<void> _addGrowth() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final ok = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GrowthFormScreen(babyId: babyId)),
    );
    if (ok == true) _fetchTimeline();
  }

  Future<void> _addMilestone() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final ok = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => MilestoneFormScreen(babyId: babyId)),
    );
    if (ok == true) _fetchTimeline();
  }

  Future<void> _addNutrition() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final ok = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => NutritionFormScreen(babyId: babyId)),
    );
    if (ok == true) _fetchTimeline();
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Semua',
              filter: ActivityFilter.all,
              icon: Icons.all_inclusive,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Feeding',
              filter: ActivityFilter.feeding,
              icon: Icons.restaurant,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Diaper',
              filter: ActivityFilter.diaper,
              icon: Icons.baby_changing_station,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Tidur',
              filter: ActivityFilter.sleep,
              icon: Icons.bedtime,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Growth',
              filter: ActivityFilter.growth,
              icon: Icons.monitor_weight,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Milestone',
              filter: ActivityFilter.milestone,
              icon: Icons.emoji_events,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Nutrisi',
              filter: ActivityFilter.nutrition,
              icon: Icons.restaurant_menu,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required ActivityFilter filter,
    required IconData icon,
  }) {
    final isSelected = _selectedFilter == filter;
    final theme = Theme.of(context);
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filter;
        });
      },
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timeline,
              size: 80,
              color: theme.colorScheme.onBackground.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada aktivitas',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai catat aktivitas bayi Anda',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final groupedActivities = _groupActivitiesByDate();
    
    return RefreshIndicator(
      onRefresh: _fetchTimeline,
      child: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: groupedActivities.length,
        itemBuilder: (context, index) {
          final entry = groupedActivities.entries.elementAt(index);
          final date = entry.key;
          final dayActivities = entry.value;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDateHeader(date),
              const SizedBox(height: 8),
              ...dayActivities.map((activity) => _buildTimelineItem(activity)),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }

  Map<DateTime, List<TimelineActivity>> _groupActivitiesByDate() {
    final grouped = <DateTime, List<TimelineActivity>>{};
    
    for (final activity in filteredActivities) {
      final date = DateTime(
        activity.time.year,
        activity.time.month,
        activity.time.day,
      );
      
      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(activity);
    }
    
    // Sort by date (newest first)
    final sortedEntries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    
    return Map.fromEntries(sortedEntries);
  }

  Widget _buildDateHeader(DateTime date) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    String dateText;
    if (date == today) {
      dateText = 'Hari Ini';
    } else if (date == yesterday) {
      dateText = 'Kemarin';
    } else {
      dateText = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    }
    
    return Text(
      dateText,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildTimelineItem(TimelineActivity activity) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: activity.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            activity.icon,
            color: activity.color,
            size: 20,
          ),
        ),
        title: Text(
          activity.title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              activity.subtitle,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('HH:mm').format(activity.time),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _editActivity(activity);
            } else if (value == 'delete') {
              _deleteActivity(activity);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 16),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Aktivitas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ActivityFilter.values.map((filter) {
            final label = switch (filter) {
              ActivityFilter.all => 'Semua',
              ActivityFilter.feeding => 'Feeding',
              ActivityFilter.diaper => 'Diaper',
              ActivityFilter.sleep => 'Tidur',
              ActivityFilter.growth => 'Growth',
              ActivityFilter.milestone => 'Milestone',
              ActivityFilter.nutrition => 'Nutrisi',
            };
            
            return RadioListTile<ActivityFilter>(
              title: Text(label),
              value: filter,
              groupValue: _selectedFilter,
              onChanged: (value) {
                setState(() {
                  _selectedFilter = value!;
                });
                Navigator.of(context).pop();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _editActivity(TimelineActivity activity) {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    if (!Validators.isUuid(activity.id)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID aktivitas tidak valid untuk diedit')));
      return;
    }
    switch (activity.type) {
      case ActivityType.feeding:
        _editFeeding(activity.id, babyId);
        break;
      case ActivityType.diaper:
        _editDiaper(activity.id, babyId);
        break;
      case ActivityType.sleep:
        _editSleep(activity.id, babyId);
        break;
      case ActivityType.growth:
        _editGrowth(activity.id, babyId);
        break;
      case ActivityType.milestone:
      case ActivityType.nutrition:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Edit belum tersedia untuk item ini')),
        );
        break;
    }
  }

  void _deleteActivity(TimelineActivity activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Aktivitas'),
        content: const Text('Apakah Anda yakin ingin menghapus aktivitas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              _performDelete(activity);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDelete(TimelineActivity activity) async {
    try {
      // Guard: pastikan id adalah UUID valid
      if (!Validators.isUuid(activity.id)) {
        throw Exception('ID tidak valid untuk operasi ini');
      }
      switch (activity.type) {
        case ActivityType.feeding:
          await FeedingService().delete(activity.id);
          break;
        case ActivityType.diaper:
          await DiaperService().delete(activity.id);
          break;
        case ActivityType.sleep:
          await SleepService().delete(activity.id);
          break;
        case ActivityType.growth:
          await GrowthService().delete(activity.id);
          break;
        case ActivityType.milestone:
        case ActivityType.nutrition:
          // belum ada endpoint spesifik
          break;
      }
      if (!mounted) return;
      Navigator.of(context).pop();
      await _fetchTimeline();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aktivitas telah dihapus')),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: $e')),
      );
    }
  }

  Future<void> _editFeeding(String id, String babyId) async {
    try {
      final f = await FeedingService().getById(id);
      final type = _mapFeedingType(f.type);
      final start = DateTime.tryParse(f.startTime) ?? DateTime.now();
      final feeding = fm.Feeding(
        id: f.id,
        babyId: f.babyId,
        type: type,
        startTime: start,
        durationMinutes: f.durationMinutes,
        notes: f.notes,
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => FeedingFormScreen(babyId: babyId, feeding: feeding),
        ),
      );
      _fetchTimeline();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat feeding: $e')));
    }
  }

  Future<void> _editDiaper(String id, String babyId) async {
    try {
      final d = await DiaperService().getById(id);
      final type = _mapDiaperTypeFromString(d.type);
      final time = DateTime.tryParse(d.time) ?? DateTime.now();
      final diaper = dm.Diaper(
        id: d.id,
        babyId: d.babyId,
        changeTime: time,
        type: type,
        color: _mapDiaperColor(d.color),
        texture: _mapDiaperTexture(d.texture),
        notes: d.notes,
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DiaperFormScreen(babyId: babyId, diaper: diaper),
        ),
      );
      _fetchTimeline();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat diaper: $e')));
    }
  }

  Future<void> _editSleep(String id, String babyId) async {
    try {
      final s = await SleepService().getById(id);
      final start = DateTime.tryParse(s.startTime) ?? DateTime.now();
      final end = DateTime.tryParse(s.endTime) ?? DateTime.now();
      final sleep = sm.Sleep(
        id: s.id,
        babyId: s.babyId,
        startTime: start,
        endTime: end,
        notes: s.notes,
      );
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SleepFormScreen(babyId: babyId, sleep: sleep),
        ),
      );
      _fetchTimeline();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat tidur: $e')));
    }
  }

  Future<void> _editGrowth(String id, String babyId) async {
    try {
      final g = await GrowthService().getById(id);
      final weightCtrl = TextEditingController(text: g.weight.toString());
      final heightCtrl = TextEditingController(text: g.height.toString());
      final headCtrl = TextEditingController(text: g.headCircumference?.toString() ?? '');
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Edit Growth'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Berat (kg)')),
              TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: 'Tinggi (cm)')),
              TextField(controller: headCtrl, decoration: const InputDecoration(labelText: 'Lingkar Kepala (cm)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await GrowthService().update(
                    id,
                    weight: double.tryParse(weightCtrl.text),
                    height: double.tryParse(heightCtrl.text),
                    headCircumference: double.tryParse(headCtrl.text),
                  );
                  if (!mounted) return;
                  Navigator.of(context).pop();
                  _fetchTimeline();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat growth: $e')));
    }
  }

  fm.FeedingType _mapFeedingType(String t) {
    switch (t) {
      case 'asi_left':
        return fm.FeedingType.breastLeft;
      case 'asi_right':
        return fm.FeedingType.breastRight;
      case 'formula':
        return fm.FeedingType.formula;
      case 'pump':
        return fm.FeedingType.pump;
      default:
        return fm.FeedingType.breastLeft;
    }
  }

  dm.DiaperType _mapDiaperTypeFromString(String t) {
    switch (t) {
      case 'pipis':
        return dm.DiaperType.wet;
      case 'pup':
        return dm.DiaperType.dirty;
      case 'campuran':
        return dm.DiaperType.mixed;
      default:
        return dm.DiaperType.wet;
    }
  }

  dm.DiaperColor? _mapDiaperColor(String? name) {
    if (name == null) return null;
    for (final v in dm.DiaperColor.values) {
      if (v.displayName.toLowerCase() == name.toLowerCase()) return v;
    }
    return null;
  }

  dm.DiaperTexture? _mapDiaperTexture(String? name) {
    if (name == null) return null;
    for (final v in dm.DiaperTexture.values) {
      if (v.displayName.toLowerCase() == name.toLowerCase()) return v;
    }
    return null;
  }
}

enum ActivityType { feeding, diaper, sleep, growth, milestone, nutrition }

class TimelineActivity {
  final String id;
  final ActivityType type;
  final DateTime time;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  TimelineActivity({
    required this.id,
    required this.type,
    required this.time,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class _TypeMap {
  final ActivityType type;
  final IconData icon;
  final Color color;
  _TypeMap(this.type, this.icon, this.color);
}

_TypeMap _mapType(String t) {
  switch (t.toLowerCase()) {
    case 'feeding':
    case 'asi_left':
    case 'asi_right':
    case 'formula':
    case 'pump':
      return _TypeMap(ActivityType.feeding, Icons.restaurant, Colors.blue);
    case 'diaper':
    case 'pipis':
    case 'pup':
    case 'campuran':
      return _TypeMap(ActivityType.diaper, Icons.baby_changing_station, Colors.orange);
    case 'sleep':
      return _TypeMap(ActivityType.sleep, Icons.bedtime, Colors.purple);
    case 'growth':
      return _TypeMap(ActivityType.growth, Icons.monitor_weight, Colors.pink);
    case 'milestone':
      return _TypeMap(ActivityType.milestone, Icons.emoji_events, Colors.amber);
    case 'nutrition':
    case 'menu':
      return _TypeMap(ActivityType.nutrition, Icons.restaurant_menu, Colors.green);
    default:
      return _TypeMap(ActivityType.feeding, Icons.info_outline, Colors.grey);
  }
}

// Mencoba mengekstrak UUID dari payload timeline untuk berbagai tipe aktivitas
String _extractId(Map<String, dynamic> e, String typeKey) {
  // prioritas: id -> ${type}_id -> nested object id
  String? id = (e['id'] ?? e['${typeKey}_id'])?.toString();
  if (id != null && id.trim().isNotEmpty) return id.trim();
  // beberapa backend mengemas objek nested, mis: feeding { id: ... }
  final nested = e[typeKey];
  if (nested is Map<String, dynamic>) {
    final nestedId = nested['id']?.toString();
    if (nestedId != null && nestedId.trim().isNotEmpty) return nestedId.trim();
  }
  return '';
}

String _typeKey(ActivityType t) {
  switch (t) {
    case ActivityType.feeding:
      return 'feeding';
    case ActivityType.diaper:
      return 'diaper';
    case ActivityType.sleep:
      return 'sleep';
    case ActivityType.growth:
      return 'growth';
    case ActivityType.milestone:
      return 'milestone';
    case ActivityType.nutrition:
      return 'nutrition';
  }
}
