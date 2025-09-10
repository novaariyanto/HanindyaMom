import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:hanindyamom/screens/growth/growth_form_screen.dart';
import 'package:hanindyamom/models/growth.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/growth_service.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  List<GrowthRecord> records = [];
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
        _fetch();
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
    if (babyId != null && mounted) {
      _fetch();
    }
  }

  @override
  void dispose() {
    _babyProvider?.removeListener(_onBabyChanged);
    super.dispose();
  }

  Future<void> _fetch() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final apiList = await GrowthService().list(babyId);
      records = apiList
          .map((g) => GrowthRecord(
                id: g.id,
                babyId: g.babyId,
                date: DateTime.tryParse(g.date) ?? DateTime.now(),
                weightKg: g.weight,
                heightCm: g.height,
              ))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
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

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Tracker')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChartCard(),
                      const SizedBox(height: 16),
                      Text('Riwayat Pertumbuhan', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ...records.reversed.map((r) => _buildGrowthCard(r)).toList(),
                    ],
                  ),
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addRecord,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildChartCard() {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Grafik Pertumbuhan (Berat)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(dateFormat: DateFormat('dd/MM')),
                legend: Legend(isVisible: true),
                series: <CartesianSeries<GrowthRecord, DateTime>>[
                  LineSeries<GrowthRecord, DateTime>(
                    name: 'Berat (kg)',
                    dataSource: records,
                    xValueMapper: (r, _) => r.date,
                    yValueMapper: (r, _) => r.weightKg,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: Colors.pinkAccent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text('Grafik Pertumbuhan (Tinggi)', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            SizedBox(
              height: 220,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(dateFormat: DateFormat('dd/MM')),
                legend: Legend(isVisible: true),
                series: <CartesianSeries<GrowthRecord, DateTime>>[
                  LineSeries<GrowthRecord, DateTime>(
                    name: 'Tinggi (cm)',
                    dataSource: records,
                    xValueMapper: (r, _) => r.date,
                    yValueMapper: (r, _) => r.heightCm,
                    markerSettings: const MarkerSettings(isVisible: true),
                    color: Colors.blueAccent,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrowthCard(GrowthRecord r) {
    final status = GrowthUtils.classifyByBmi(weightKg: r.weightKg, heightCm: r.heightCm);
    final statusText = GrowthUtils.statusText(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.pink.shade100,
          child: const Icon(Icons.monitor_weight, color: Colors.pink),
        ),
        title: Text('${r.weightKg.toStringAsFixed(1)} kg • ${r.heightCm.toStringAsFixed(0)} cm'),
        subtitle: Text('${DateFormat('dd MMM yyyy', 'id_ID').format(r.date)} • $statusText'),
        trailing: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // TODO: edit record
          },
        ),
      ),
    );
  }

  Future<void> _addRecord() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => GrowthFormScreen(babyId: babyId)),
    );
    _fetch();
  }
}
