import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hanindyamom/models/diaper.dart';
import 'package:hanindyamom/services/diaper_service.dart';

class DiaperFormScreen extends StatefulWidget {
  final String babyId;
  final Diaper? diaper; // null untuk add, ada value untuk edit

  const DiaperFormScreen({
    super.key,
    required this.babyId,
    this.diaper,
  });

  @override
  State<DiaperFormScreen> createState() => _DiaperFormScreenState();
}

class _DiaperFormScreenState extends State<DiaperFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DiaperType _selectedType = DiaperType.wet;
  DiaperColor? _selectedColor;
  DiaperTexture? _selectedTexture;
  DateTime _changeTime = DateTime.now();
  bool _isLoading = false;

  bool get isEditing => widget.diaper != null;
  bool get showColorAndTexture => _selectedType != DiaperType.wet;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeFormWithDiaperData();
    }
  }

  void _initializeFormWithDiaperData() {
    final diaper = widget.diaper!;
    _selectedType = diaper.type;
    _selectedColor = diaper.color;
    _selectedTexture = diaper.texture;
    _changeTime = diaper.changeTime;
    if (diaper.notes != null) {
      _notesController.text = diaper.notes!;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectChangeTime() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _changeTime,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now(),
    );
    
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_changeTime),
      );
      
      if (pickedTime != null) {
        setState(() {
          _changeTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveDiaper() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final isoTime = DateFormat('yyyy-MM-ddTHH:mm:ss').format(_changeTime);
      await DiaperService().create(
        babyId: widget.babyId,
        type: _mapDiaperType(_selectedType),
        time: isoTime,
        color: _selectedColor?.displayName,
        texture: _selectedTexture?.displayName,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );
      if (!mounted) return;
      setState(() => _isLoading = false);
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(isEditing ? 'Data popok diperbarui' : 'Data popok ditambahkan')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Popok' : 'Ganti Popok'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.baby_changing_station,
                          color: Colors.orange,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Ganti Popok',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Catat informasi pergantian popok bayi',
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
              ),

              const SizedBox(height: 24),

              // Change Time
              Text(
                'Waktu Ganti Popok',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('Waktu'),
                  subtitle: Text(
                    DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_changeTime),
                  ),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _selectChangeTime,
                ),
              ),

              const SizedBox(height: 24),

              // Diaper Type
              Text(
                'Jenis Popok',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: DiaperType.values.map((type) {
                    return RadioListTile<DiaperType>(
                      title: Row(
                        children: [
                          Icon(_getDiaperIcon(type), size: 20),
                          const SizedBox(width: 8),
                          Text(type.displayName),
                        ],
                      ),
                      value: type,
                      groupValue: _selectedType,
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                          // Reset color and texture when type changes
                          if (_selectedType == DiaperType.wet) {
                            _selectedColor = null;
                            _selectedTexture = null;
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ),

              // Color (only for dirty/mixed)
              if (showColorAndTexture) ...[
                const SizedBox(height: 24),
                Text(
                  'Warna',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: DiaperColor.values.map((color) {
                      return RadioListTile<DiaperColor>(
                        title: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: _getColorValue(color),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: theme.colorScheme.outline,
                                  width: 1,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(color.displayName),
                          ],
                        ),
                        value: color,
                        groupValue: _selectedColor,
                        onChanged: (value) {
                          setState(() {
                            _selectedColor = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // Texture
                Text(
                  'Tekstur',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: DiaperTexture.values.map((texture) {
                      return RadioListTile<DiaperTexture>(
                        title: Text(texture.displayName),
                        value: texture,
                        groupValue: _selectedTexture,
                        onChanged: (value) {
                          setState(() {
                            _selectedTexture = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Notes
              Text(
                'Catatan (Opsional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'Tambahkan catatan jika perlu...',
                  prefixIcon: Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveDiaper,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(isEditing ? 'Simpan Perubahan' : 'Simpan Data'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getDiaperIcon(DiaperType type) {
    switch (type) {
      case DiaperType.wet:
        return Icons.water_drop;
      case DiaperType.dirty:
        return Icons.circle;
      case DiaperType.mixed:
        return Icons.blur_circular;
    }
  }

  String _mapDiaperType(DiaperType type) {
    switch (type) {
      case DiaperType.wet:
        return 'pipis';
      case DiaperType.dirty:
        return 'pup';
      case DiaperType.mixed:
        return 'campuran';
    }
  }

  Color _getColorValue(DiaperColor color) {
    switch (color) {
      case DiaperColor.yellow:
        return Colors.yellow;
      case DiaperColor.brown:
        return Colors.brown;
      case DiaperColor.green:
        return Colors.green;
      case DiaperColor.black:
        return Colors.black;
      case DiaperColor.other:
        return Colors.grey;
    }
  }
}
