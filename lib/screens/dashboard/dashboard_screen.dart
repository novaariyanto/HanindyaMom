import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:hanindyamom/models/baby.dart';
import 'package:hanindyamom/models/feeding.dart';
import 'package:hanindyamom/models/diaper.dart';
import 'package:hanindyamom/models/sleep.dart';
import 'package:hanindyamom/screens/activities/feeding_form_screen.dart';
import 'package:hanindyamom/screens/activities/diaper_form_screen.dart';
import 'package:hanindyamom/screens/activities/sleep_form_screen.dart';
import 'package:hanindyamom/screens/timeline/timeline_screen.dart';

class DashboardScreen extends StatefulWidget {
  final Baby? baby;

  const DashboardScreen({super.key, this.baby});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data untuk demo
  List<Feeding> feedings = [];
  List<Diaper> diapers = [];
  List<Sleep> sleeps = [];

  @override
  void initState() {
    super.initState();
    _generateMockData();
  }

  void _generateMockData() {
    final now = DateTime.now();
    final babyId = widget.baby?.id ?? '1';

    // Mock feeding data
    feedings = [
      Feeding(
        id: '1',
        babyId: babyId,
        type: FeedingType.breastLeft,
        startTime: now.subtract(const Duration(hours: 2)),
        durationMinutes: 15,
      ),
      Feeding(
        id: '2',
        babyId: babyId,
        type: FeedingType.breastRight,
        startTime: now.subtract(const Duration(hours: 5)),
        durationMinutes: 20,
      ),
      Feeding(
        id: '3',
        babyId: babyId,
        type: FeedingType.formula,
        startTime: now.subtract(const Duration(hours: 8)),
        durationMinutes: 10,
        amount: 120,
      ),
    ];

    // Mock diaper data
    diapers = [
      Diaper(
        id: '1',
        babyId: babyId,
        changeTime: now.subtract(const Duration(hours: 1)),
        type: DiaperType.wet,
      ),
      Diaper(
        id: '2',
        babyId: babyId,
        changeTime: now.subtract(const Duration(hours: 4)),
        type: DiaperType.dirty,
        color: DiaperColor.yellow,
        texture: DiaperTexture.soft,
      ),
    ];

    // Mock sleep data
    sleeps = [
      Sleep(
        id: '1',
        babyId: babyId,
        startTime: now.subtract(const Duration(hours: 3)),
        endTime: now.subtract(const Duration(hours: 1, minutes: 30)),
      ),
      Sleep(
        id: '2',
        babyId: babyId,
        startTime: now.subtract(const Duration(hours: 8)),
        endTime: now.subtract(const Duration(hours: 6)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baby = widget.baby;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(baby?.name ?? 'Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TimelineScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (baby != null) _buildBabyHeader(baby),
            const SizedBox(height: 24),
            _buildTodaysSummary(),
            const SizedBox(height: 24),
            _buildActivityChart(),
            const SizedBox(height: 24),
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildBabyHeader(Baby baby) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: baby.photoPath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        baby.photoPath!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Icon(
                      Icons.baby_changing_station,
                      color: theme.colorScheme.primary,
                      size: 30,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    baby.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    baby.ageString,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (baby.weight != null || baby.height != null)
                    Text(
                      '${baby.weight != null ? '${baby.weight}kg' : ''}'
                      '${baby.weight != null && baby.height != null ? ' • ' : ''}'
                      '${baby.height != null ? '${baby.height}cm' : ''}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaysSummary() {
    final theme = Theme.of(context);
    final today = DateTime.now();
    
    // Filter data hari ini
    final todayFeedings = feedings.where((f) => 
        f.startTime.day == today.day && 
        f.startTime.month == today.month && 
        f.startTime.year == today.year).length;
    
    final todayDiapers = diapers.where((d) => 
        d.changeTime.day == today.day && 
        d.changeTime.month == today.month && 
        d.changeTime.year == today.year).length;
    
    final todaySleep = sleeps.where((s) => 
        s.startTime.day == today.day && 
        s.startTime.month == today.month && 
        s.startTime.year == today.year)
        .fold<Duration>(Duration.zero, (total, sleep) => total + sleep.duration);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Hari Ini',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.restaurant,
                title: 'Feeding',
                value: '$todayFeedings',
                subtitle: 'kali',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.baby_changing_station,
                title: 'Diaper',
                value: '$todayDiapers',
                subtitle: 'kali',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.bedtime,
                title: 'Tidur',
                value: '${todaySleep.inHours}j',
                subtitle: '${todaySleep.inMinutes % 60}m',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityChart() {
    final theme = Theme.of(context);
    
    // Data untuk chart (7 hari terakhir)
    final chartData = _generateChartData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas 7 Hari Terakhir',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 250,
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(
                  minimum: 0,
                  maximum: 10,
                  interval: 2,
                ),
                legend: Legend(isVisible: true),
                series: <CartesianSeries<ActivityData, String>>[
                  ColumnSeries<ActivityData, String>(
                    dataSource: chartData,
                    xValueMapper: (ActivityData data, _) => data.day,
                    yValueMapper: (ActivityData data, _) => data.feeding,
                    name: 'Feeding',
                    color: Colors.blue,
                  ),
                  ColumnSeries<ActivityData, String>(
                    dataSource: chartData,
                    xValueMapper: (ActivityData data, _) => data.day,
                    yValueMapper: (ActivityData data, _) => data.diaper,
                    name: 'Diaper',
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<ActivityData> _generateChartData() {
    final now = DateTime.now();
    final data = <ActivityData>[];
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = _getDayName(date.weekday);
      
      // Mock data untuk demo
      data.add(ActivityData(
        day: dayName,
        feeding: (3 + (i % 3)).toDouble(),
        diaper: (2 + (i % 4)).toDouble(),
      ));
    }
    
    return data;
  }

  String _getDayName(int weekday) {
    const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    return days[weekday - 1];
  }

  Widget _buildQuickActions() {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aksi Cepat',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                icon: Icons.restaurant,
                label: 'Feeding',
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => FeedingFormScreen(
                        babyId: widget.baby?.id ?? '1',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.baby_changing_station,
                label: 'Diaper',
                color: Colors.orange,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => DiaperFormScreen(
                        babyId: widget.baby?.id ?? '1',
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                icon: Icons.bedtime,
                label: 'Tidur',
                color: Colors.purple,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => SleepFormScreen(
                        babyId: widget.baby?.id ?? '1',
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActivityData {
  final String day;
  final double feeding;
  final double diaper;

  ActivityData({
    required this.day,
    required this.feeding,
    required this.diaper,
  });
}
