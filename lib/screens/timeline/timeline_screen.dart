import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum ActivityFilter { all, feeding, diaper, sleep, growth, milestone, nutrition }

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  ActivityFilter _selectedFilter = ActivityFilter.all;
  
  // Mock data untuk demo
  List<TimelineActivity> activities = [];

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    final now = DateTime.now();
    
    activities = [
      TimelineActivity(
        id: '1',
        type: ActivityType.feeding,
        time: now.subtract(const Duration(minutes: 30)),
        title: 'ASI Kiri',
        subtitle: '15 menit',
        icon: Icons.restaurant,
        color: Colors.blue,
      ),
      TimelineActivity(
        id: '2',
        type: ActivityType.diaper,
        time: now.subtract(const Duration(hours: 1)),
        title: 'Ganti Popok',
        subtitle: 'Pipis',
        icon: Icons.baby_changing_station,
        color: Colors.orange,
      ),
      TimelineActivity(
        id: '3',
        type: ActivityType.sleep,
        time: now.subtract(const Duration(hours: 2)),
        title: 'Tidur',
        subtitle: '1j 30m',
        icon: Icons.bedtime,
        color: Colors.purple,
      ),
      TimelineActivity(
        id: '4',
        type: ActivityType.feeding,
        time: now.subtract(const Duration(hours: 3)),
        title: 'Formula',
        subtitle: '120ml • 10 menit',
        icon: Icons.restaurant,
        color: Colors.blue,
      ),
      TimelineActivity(
        id: '5',
        type: ActivityType.diaper,
        time: now.subtract(const Duration(hours: 4)),
        title: 'Ganti Popok',
        subtitle: 'Pup • Kuning • Lembek',
        icon: Icons.baby_changing_station,
        color: Colors.orange,
      ),
      TimelineActivity(
        id: '6',
        type: ActivityType.sleep,
        time: now.subtract(const Duration(hours: 6)),
        title: 'Tidur',
        subtitle: '2j 15m',
        icon: Icons.bedtime,
        color: Colors.purple,
      ),
      // Growth log
      TimelineActivity(
        id: '7',
        type: ActivityType.growth,
        time: now.subtract(const Duration(hours: 7)),
        title: 'Growth Update',
        subtitle: 'Berat 8.2 kg • Tinggi 69 cm',
        icon: Icons.monitor_weight,
        color: Colors.pink,
      ),
      // Milestone log
      TimelineActivity(
        id: '8',
        type: ActivityType.milestone,
        time: now.subtract(const Duration(hours: 10)),
        title: 'Milestone Tercapai',
        subtitle: 'Berdiri tanpa bantuan',
        icon: Icons.emoji_events,
        color: Colors.amber,
      ),
      // Nutrition log
      TimelineActivity(
        id: '9',
        type: ActivityType.nutrition,
        time: now.subtract(const Duration(hours: 11)),
        title: 'Menu Harian',
        subtitle: 'MPASI: bubur ayam + sayur',
        icon: Icons.restaurant_menu,
        color: Colors.green,
      ),
    ];
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
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: filteredActivities.isEmpty 
                ? _buildEmptyState() 
                : _buildTimeline(),
          ),
        ],
      ),
    );
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
    
    return ListView.builder(
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
    // TODO: Implement edit functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fitur edit belum tersedia')),
    );
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
              setState(() {
                activities.removeWhere((a) => a.id == activity.id);
              });
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Aktivitas telah dihapus')),
              );
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
