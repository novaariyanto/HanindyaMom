import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:hanindyamom/models/baby.dart';

class BabyFormScreen extends StatefulWidget {
  final Baby? baby; // null untuk add, ada value untuk edit

  const BabyFormScreen({super.key, this.baby});

  @override
  State<BabyFormScreen> createState() => _BabyFormScreenState();
}

class _BabyFormScreenState extends State<BabyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  
  DateTime? _selectedDate;
  String? _photoPath;
  bool _isLoading = false;

  bool get isEditing => widget.baby != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _initializeFormWithBabyData();
    }
  }

  void _initializeFormWithBabyData() {
    final baby = widget.baby!;
    _nameController.text = baby.name;
    _selectedDate = baby.birthDate;
    _photoPath = baby.photoPath;
    if (baby.weight != null) {
      _weightController.text = baby.weight.toString();
    }
    if (baby.height != null) {
      _heightController.text = baby.height.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('Kamera'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    _photoPath = image.path;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeri'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                  maxWidth: 800,
                  maxHeight: 800,
                  imageQuality: 80,
                );
                if (image != null) {
                  setState(() {
                    _photoPath = image.path;
                  });
                }
              },
            ),
            if (_photoPath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _photoPath = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveBaby() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal lahir harus dipilih')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Simulasi save (dalam implementasi nyata akan save ke database/API)
    await Future.delayed(const Duration(seconds: 1));

    final baby = Baby(
      id: isEditing ? widget.baby!.id : DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      birthDate: _selectedDate!,
      photoPath: _photoPath,
      weight: _weightController.text.isNotEmpty 
          ? double.tryParse(_weightController.text) 
          : null,
      height: _heightController.text.isNotEmpty 
          ? double.tryParse(_heightController.text) 
          : null,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.of(context).pop(baby);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Profil Bayi' : 'Tambah Bayi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Photo Section
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(60),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: _photoPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(58),
                            child: Image.asset(
                              _photoPath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.baby_changing_station,
                                  size: 50,
                                  color: theme.colorScheme.primary,
                                );
                              },
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tambah Foto',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Bayi',
                  hintText: 'Masukkan nama bayi',
                  prefixIcon: Icon(Icons.baby_changing_station),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama bayi tidak boleh kosong';
                  }
                  if (value.trim().length < 2) {
                    return 'Nama minimal 2 karakter';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Birth Date Field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Tanggal Lahir',
                    hintText: 'Pilih tanggal lahir',
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(
                    _selectedDate != null
                        ? DateFormat('dd MMMM yyyy', 'id_ID').format(_selectedDate!)
                        : 'Pilih tanggal lahir',
                    style: _selectedDate != null
                        ? theme.textTheme.bodyLarge
                        : theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Optional Fields Section
              Text(
                'Informasi Tambahan (Opsional)',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Weight Field
              TextFormField(
                controller: _weightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  hintText: 'Contoh: 3.2',
                  prefixIcon: Icon(Icons.monitor_weight),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Berat badan harus berupa angka positif';
                    }
                    if (weight > 50) {
                      return 'Berat badan tidak valid';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Height Field
              TextFormField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  hintText: 'Contoh: 50',
                  prefixIcon: Icon(Icons.height),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final height = double.tryParse(value);
                    if (height == null || height <= 0) {
                      return 'Tinggi badan harus berupa angka positif';
                    }
                    if (height > 150) {
                      return 'Tinggi badan tidak valid';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveBaby,
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
                      : Text(isEditing ? 'Simpan Perubahan' : 'Tambah Bayi'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
