import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:hanindyamom/services/profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _photoPath; // path relatif dari server
  File? _pickedImageFile; // file lokal yang dipilih untuk upload

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await ProfileService().getProfile();
      _nameCtrl.text = p.name;
      _emailCtrl.text = p.email;
      _photoPath = p.photo;
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final profile = await ProfileService().updateProfile(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        photoFile: _pickedImageFile,
      );
      _photoPath = profile.photo;
      _pickedImageFile = null;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil tersimpan')));
      Navigator.of(context).pop(true);
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $msg')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (picked == null) return;
    final file = File(picked.path);
    final int size = await file.length();
    // Validasi ukuran ≤ 2MB
    if (size > 2 * 1024 * 1024) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ukuran foto melebihi 2MB')));
      return;
    }
    // Validasi dasar tipe file berdasarkan ekstensi
    final lower = picked.name.toLowerCase();
    if (!(lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png'))) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Format gambar harus JPG/PNG')));
      return;
    }
    setState(() {
      _pickedImageFile = file;
    });
  }

  Future<void> _deletePhoto() async {
    setState(() => _saving = true);
    try {
      final profile = await ProfileService().updateProfile(photo: '');
      _photoPath = profile.photo;
      _pickedImageFile = null;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Foto profil dihapus')));
      setState(() {});
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic>
          ? (e.response?.data['message'] ?? e.message)
          : e.message;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $msg')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(title: const Text('Edit Profil')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Foto profil + aksi
                        Row(
                          children: [
                            _buildAvatar(),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: _saving ? null : _pickImage,
                                    icon: const Icon(Icons.photo),
                                    label: const Text('Ubah Foto'),
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: _saving ? null : _deletePhoto,
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text('Hapus Foto', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailCtrl,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return null; // opsional
                            final pattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                            return pattern.hasMatch(v) ? null : 'Email tidak valid';
                          },
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _saving ? null : _save,
                            child: _saving ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
    );
  }

  Widget _buildAvatar() {
    final double size = 72;
    ImageProvider? image;
    if (_pickedImageFile != null) {
      image = FileImage(_pickedImageFile!);
    } else if (_photoPath != null && _photoPath!.isNotEmpty) {
      final url = ProfileService.buildPhotoUrl(_photoPath);
      if (url != null) image = NetworkImage(url);
    }
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      backgroundImage: image,
      child: image == null ? Icon(Icons.person, size: size * 0.6, color: Theme.of(context).colorScheme.primary) : null,
    );
  }
}


