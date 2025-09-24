import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:hanindyamom/models/baby.dart';
import 'package:hanindyamom/screens/activities/feeding_form_screen.dart';
import 'package:hanindyamom/screens/activities/diaper_form_screen.dart';
import 'package:hanindyamom/screens/activities/sleep_form_screen.dart';
import 'package:hanindyamom/screens/timeline/timeline_screen.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/timeline_service.dart';
import 'package:hanindyamom/l10n/app_localizations.dart';

class DashboardScreen extends StatefulWidget {
  final Baby? baby;

  const DashboardScreen({super.key, this.baby});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _loading = true;
  String? _error;
  int _feedingCount = 0;
  int _diaperCount = 0;
  int _sleepMinutes = 0;
  List<ActivityData> _chartData = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchSummary();
  }

  Future<void> _fetchSummary() async {
    final babyId = context.read<SelectedBabyProvider>().babyId ?? widget.baby?.id;
    if (babyId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await DashboardService().summary(babyId, range: 'daily');
      // Ekspektasi struktur fleksibel
      final feeding = data['feeding_count'] ?? data['feeding'] ?? 0;
      final diaper = data['diaper_count'] ?? data['diaper'] ?? 0;
      final sleep = data['sleep_minutes'] ?? data['sleep'] ?? 0;
      _feedingCount = feeding is int ? feeding : int.tryParse('$feeding') ?? 0;
      _diaperCount = diaper is int ? diaper : int.tryParse('$diaper') ?? 0;
      _sleepMinutes = sleep is int ? sleep : int.tryParse('$sleep') ?? 0;

      final chart = (data['chart'] as List?) ?? [];
      _chartData = chart.map((e) {
        final day = e['day']?.toString() ?? '';
        final f = (e['feeding'] as num?)?.toDouble() ?? 0.0;
        final d = (e['diaper'] as num?)?.toDouble() ?? 0.0;
        return ActivityData(day: day, feeding: f, diaper: d);
      }).toList();

      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baby = widget.baby;
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(baby?.name ?? loc.tr('dashboard.title')),
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text(loc.tr('common.load_failed', {'error': '$_error'})))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (baby != null) _buildBabyHeader(baby),
                      const SizedBox(height: 24),
                      _buildTodaysSummary(loc),
                      const SizedBox(height: 24),
                      _buildActivityChart(loc),
                      const SizedBox(height: 24),
                      _buildQuickActions(loc),
                    ],
                  ),
                )),
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

  Widget _buildTodaysSummary(AppLocalizations loc) {
    final theme = Theme.of(context);
    final totalSleep = Duration(minutes: _sleepMinutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.tr('dashboard.today_summary'),
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
                title: loc.tr('feeding.title'),
                value: '$_feedingCount',
                subtitle: loc.tr('common.times_unit'),
                color: Colors.blue,
                onTap: () {
                  Navigator.of(context).pushNamed('/feeding_list');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.baby_changing_station,
                title: loc.tr('diaper.title'),
                value: '$_diaperCount',
                subtitle: loc.tr('common.times_unit'),
                color: Colors.orange,
                onTap: () {
                  Navigator.of(context).pushNamed('/diaper_list');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSummaryCard(
                icon: Icons.bedtime,
                title: loc.tr('sleep.title'),
                value: '${totalSleep.inHours}${loc.tr('common.hour_unit')}',
                subtitle: '${totalSleep.inMinutes % 60}${loc.tr('common.minute_unit')}',
                color: Colors.purple,
                onTap: () {
                  Navigator.of(context).pushNamed('/sleep_list');
                },
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
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
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

  Widget _buildActivityChart(AppLocalizations loc) {
    final theme = Theme.of(context);
    
    final chartData = _chartData.isNotEmpty ? _chartData : _generateChartData();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.tr('dashboard.last7days'),
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
                    name: loc.tr('feeding.title'),
                    color: Colors.blue,
                  ),
                  ColumnSeries<ActivityData, String>(
                    dataSource: chartData,
                    xValueMapper: (ActivityData data, _) => data.day,
                    yValueMapper: (ActivityData data, _) => data.diaper,
                    name: loc.tr('diaper.title'),
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

  Widget _buildQuickActions(AppLocalizations loc) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.tr('dashboard.quick_actions'),
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
                label: loc.tr('feeding.title'),
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
                label: loc.tr('diaper.title'),
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
                label: loc.tr('sleep.title'),
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
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: null,
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
