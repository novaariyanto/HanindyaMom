import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:hanindyamom/services/nutrition_service.dart';

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
  File? _file;
  bool _isLoading = false;
  bool _picking = false;

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
    // Validasi babyId (UUID)
    if (widget.babyId.isEmpty || widget.babyId.length != 36) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID bayi tidak valid')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      if (_file != null) {
        await NutritionService().createWithFile(
          babyId: widget.babyId,
          time: _time,
          title: _titleController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          photoFile: _file!,
        );
      } else {
        await NutritionService().create(
          babyId: widget.babyId,
          time: _time,
          title: _titleController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        );
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu harian disimpan')));
    } on DioException catch (e) {
      String msg = e.message ?? 'Gagal menyimpan';
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) msg = data['message'].toString();
        // tampilkan error validasi pertama jika ada
        if (data['errors'] is Map<String, dynamic>) {
          final errs = data['errors'] as Map<String, dynamic>;
          if (errs.isNotEmpty) {
            final firstKey = errs.keys.first;
            final firstVal = errs[firstKey];
            if (firstVal is List && firstVal.isNotEmpty) {
              msg = firstVal.first.toString();
            } else if (firstVal is String) {
              msg = firstVal;
            }
          }
        }
      }
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $msg')));
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
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
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: const Text('Upload Foto (opsional)'),
                      subtitle: Text(_file?.path.split('/').last.split('\\').last ?? 'Tidak ada file'),
                      trailing: _picking ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: _picking
                          ? null
                          : () async {
                              setState(() => _picking = true);
                              try {
                                final picker = ImagePicker();
                                final x = await picker.pickImage(
                                  source: ImageSource.gallery,
                                  imageQuality: 80,
                                  maxWidth: 1600,
                                  maxHeight: 1600,
                                );
                                if (x == null) return;
                                final f = File(x.path);
                                final size = await f.length();
                                if (size > 2 * 1024 * 1024) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ukuran foto melebihi 2MB')));
                                  return;
                                }
                                final lower = x.name.toLowerCase();
                                if (!(lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png'))){
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format gambar harus JPG/PNG')));
                                  return;
                                }
                                if (!mounted) return;
                                setState(() {
                                  _file = f;
                                });
                              } catch (err) {
                                if (!mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memilih gambar: $err')));
                              } finally {
                                if (mounted) setState(() => _picking = false);
                              }
                            },
                    ),
                  ],
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
