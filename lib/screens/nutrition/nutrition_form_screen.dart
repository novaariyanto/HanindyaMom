import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/repositories/timeline_repository.dart';
import 'package:hanindyamom/models/timeline.dart' as tl;

class NutritionFormScreen extends StatefulWidget {
  final String babyId;
  const NutritionFormScreen({super.key, required this.babyId});

  @override
  State<NutritionFormScreen> createState() => _NutritionFormScreenState();
}

class _NutritionFormScreenState extends State<NutritionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _time = DateTime.now();
  String? _photoPath; // mock
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _time,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_time),
      );
      if (pickedTime != null) {
        setState(() {
          _time = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    // Push ke timeline repo
    final repo = context.read<TimelineRepository>();
    repo.add(tl.TimelineActivity(
      id: 'nutrition_${DateTime.now().millisecondsSinceEpoch}',
      type: tl.ActivityType.nutrition,
      time: _time,
      title: 'Menu Harian',
      subtitle: _titleController.text.trim(),
      icon: Icons.restaurant_menu,
      color: Colors.green,
    ));

    setState(() => _isLoading = false);
    Navigator.of(context).pop(true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu harian disimpan')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catat Menu Harian')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Waktu Makan'),
                  subtitle: Text(DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_time)),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _selectTime,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama menu wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: const Text('Foto Menu (opsional)'),
                  subtitle: Text(_photoPath ?? 'Tidak ada foto'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: () {
                    setState(() {
                      _photoPath = 'mock_photo.jpg';
                    });
                  },
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
