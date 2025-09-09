import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:hanindyamom/screens/growth/growth_form_screen.dart';
import 'package:hanindyamom/models/growth.dart';

class GrowthScreen extends StatefulWidget {
  const GrowthScreen({super.key});

  @override
  State<GrowthScreen> createState() => _GrowthScreenState();
}

class _GrowthScreenState extends State<GrowthScreen> {
  // Mock data
  List<GrowthRecord> records = [
    GrowthRecord(id: 'g1', babyId: '1', date: DateTime.now().subtract(const Duration(days: 60)), weightKg: 7.0, heightCm: 65),
    GrowthRecord(id: 'g2', babyId: '1', date: DateTime.now().subtract(const Duration(days: 30)), weightKg: 7.6, heightCm: 67),
    GrowthRecord(id: 'g3', babyId: '1', date: DateTime.now(), weightKg: 8.2, heightCm: 69),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Growth Tracker')),
      body: SingleChildScrollView(
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
      ),
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
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GrowthFormScreen(babyId: '1')),
    );
    // Note: pada implementasi data nyata, refresh records dari sumber data
    setState(() {});
  }
}
