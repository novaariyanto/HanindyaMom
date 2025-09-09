import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/models/growth.dart';
import 'package:hanindyamom/repositories/timeline_repository.dart';
import 'package:hanindyamom/models/timeline.dart' as tl;

class GrowthFormScreen extends StatefulWidget {
  final String babyId;
  const GrowthFormScreen({super.key, required this.babyId});

  @override
  State<GrowthFormScreen> createState() => _GrowthFormScreenState();
}

class _GrowthFormScreenState extends State<GrowthFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headController = TextEditingController();
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 6)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text);
    final head = _headController.text.isNotEmpty ? double.tryParse(_headController.text) : null;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    final record = GrowthRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      babyId: widget.babyId,
      date: _date,
      weightKg: weight,
      heightCm: height,
      headCircumferenceCm: head,
    );

    // Push ke timeline
    final repo = context.read<TimelineRepository>();

    final status = GrowthUtils.classifyByBmi(weightKg: weight, heightCm: height);
    final statusText = GrowthUtils.statusText(status);

    repo.add(tl.TimelineActivity(
      id: 'growth_${record.id}',
      type: tl.ActivityType.growth,
      time: DateTime(_date.year, _date.month, _date.day, DateTime.now().hour, DateTime.now().minute),
      title: 'Growth Update',
      subtitle: '${weight.toStringAsFixed(1)} kg • ${height.toStringAsFixed(0)} cm • $statusText',
      icon: Icons.monitor_weight,
      color: Colors.pink,
    ));

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop(record);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Data pertumbuhan disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Input Pertumbuhan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Tanggal Pengukuran'),
                  subtitle: Text(DateFormat('dd MMM yyyy', 'id_ID').format(_date)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Berat (kg)',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return 'Masukkan berat yang valid';
                  if (d > 60) return 'Berat tidak masuk akal';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tinggi (cm)',
                  prefixIcon: Icon(Icons.height),
                ),
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return 'Masukkan tinggi yang valid';
                  if (d > 150) return 'Tinggi tidak masuk akal';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _headController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Lingkar Kepala (cm) (opsional)',
                  prefixIcon: Icon(Icons.circle_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : const Text('Simpan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
