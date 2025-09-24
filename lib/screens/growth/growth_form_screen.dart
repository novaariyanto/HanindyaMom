import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hanindyamom/services/growth_service.dart';
import 'package:hanindyamom/l10n/app_localizations.dart';

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
    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_date);
      await GrowthService().create(
        babyId: widget.babyId,
        date: dateStr,
        weight: weight,
        height: height,
        headCircumference: head,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('growth.saved'))));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('common.save_failed', {'error': '$e'}))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('growth.input_title'))),
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
                  title: Text(loc.tr('growth.measurement_date')),
                  subtitle: Text(DateFormat('dd MMM yyyy', loc.dateLocaleTag).format(_date)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.tr('growth.weight_label'),
                  prefixIcon: const Icon(Icons.monitor_weight),
                ),
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return loc.tr('growth.weight_invalid');
                  if (d > 60) return loc.tr('growth.weight_unreasonable');
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.tr('growth.height_label'),
                  prefixIcon: const Icon(Icons.height),
                ),
                validator: (v) {
                  final d = double.tryParse(v ?? '');
                  if (d == null || d <= 0) return loc.tr('growth.height_invalid');
                  if (d > 150) return loc.tr('growth.height_unreasonable');
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _headController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: loc.tr('growth.head_label_optional'),
                  prefixIcon: const Icon(Icons.circle_outlined),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                      : Text(loc.tr('common.save')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
