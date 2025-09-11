import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/models/nutrition.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/nutrition_service.dart';
import 'package:image_picker/image_picker.dart';

class NutritionListScreen extends StatefulWidget {
  const NutritionListScreen({super.key});
  @override
  State<NutritionListScreen> createState() => _NutritionListScreenState();
}

class _NutritionListScreenState extends State<NutritionListScreen> {
  List<NutritionEntry> items = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
  }

  Future<void> _fetch() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) {
      setState(() => _loading = false);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      items = await NutritionService().list(babyId);
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _delete(NutritionEntry n) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Menu'),
        content: Text('Hapus "${n.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await NutritionService().delete(n.id);
      setState(() => items.removeWhere((x) => x.id == n.id));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }

  Future<void> _createOrEdit({NutritionEntry? initial}) async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final res = await showDialog<_NutritionPayload>(
      context: context,
      builder: (_) => _NutritionDialog(initial: initial),
    );
    if (res == null) return;
    try {
      NutritionEntry out;
      if (initial == null) {
        if (res.file != null) {
          out = await NutritionService().createWithFile(babyId: babyId, time: res.time, title: res.title, notes: res.notes, photoFile: res.file!);
        } else {
          out = await NutritionService().create(babyId: babyId, time: res.time, title: res.title, notes: res.notes, photoUrl: res.photoUrl);
        }
        setState(() => items.insert(0, out));
      } else {
        if (res.file != null) {
          out = await NutritionService().updateWithFile(initial.id, time: res.time, title: res.title, notes: res.notes, photoFile: res.file!);
        } else {
          out = await NutritionService().update(initial.id, time: res.time, title: res.title, notes: res.notes, photoUrl: res.photoUrl);
        }
        final idx = items.indexWhere((x) => x.id == initial.id);
        setState(() => items[idx] = out);
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic> ? (e.response?.data['message'] ?? e.message) : e.message;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $msg')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Menu Harian')),
      floatingActionButton: FloatingActionButton(onPressed: () => _createOrEdit(), child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16.0),
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemCount: items.length,
                    itemBuilder: (_, i) => _buildItem(items[i], theme),
                  ),
                )),
    );
  }

  Widget _buildItem(NutritionEntry n, ThemeData theme) {
    ImageProvider? image;
    if (n.photoPath != null && n.photoPath!.isNotEmpty) {
      final url = NutritionService.buildPhotoUrl(n.photoPath);
      if (url != null) image = NetworkImage(url);
    }
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: image,
          child: image == null ? const Icon(Icons.restaurant_menu) : null,
        ),
        title: Text(n.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(DateFormat('dd MMM yyyy • HH:mm', 'id_ID').format(n.time)),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') _createOrEdit(initial: n);
            if (v == 'delete') _delete(n);
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Hapus')),
          ],
        ),
      ),
    );
  }
}

class _NutritionPayload {
  final DateTime time;
  final String title;
  final String? notes;
  final String? photoUrl;
  final File? file;
  _NutritionPayload({required this.time, required this.title, this.notes, this.photoUrl, this.file});
}

class _NutritionDialog extends StatefulWidget {
  final NutritionEntry? initial;
  const _NutritionDialog({this.initial});
  @override
  State<_NutritionDialog> createState() => _NutritionDialogState();
}

class _NutritionDialogState extends State<_NutritionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _photoUrlCtrl = TextEditingController();
  DateTime _time = DateTime.now();
  File? _file;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      _titleCtrl.text = init.title;
      _notesCtrl.text = init.notes ?? '';
      _time = init.time;
      _photoUrlCtrl.text = init.photoPath ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Tambah Menu' : 'Edit Menu'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Judul Menu'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(_time))),
                  TextButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(context: context, initialDate: _time, firstDate: DateTime.now().subtract(const Duration(days: 7)), lastDate: DateTime.now());
                      if (d == null) return;
                      final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_time));
                      if (t == null) return;
                      setState(() => _time = DateTime(d.year, d.month, d.day, t.hour, t.minute));
                    },
                    icon: const Icon(Icons.event),
                    label: const Text('Pilih Waktu'),
                  ),
                ],
              ),
              const Divider(),
              TextFormField(
                controller: _photoUrlCtrl,
                decoration: const InputDecoration(labelText: 'URL Foto (opsional)'),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      final picker = ImagePicker();
                      final x = await picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
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
                      setState(() => _file = f);
                    },
                    icon: const Icon(Icons.photo),
                    label: const Text('Pilih Foto'),
                  ),
                  const SizedBox(width: 8),
                  if (_file != null) const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final payload = _NutritionPayload(
              time: _time,
              title: _titleCtrl.text.trim(),
              notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
              photoUrl: _photoUrlCtrl.text.trim().isEmpty ? null : _photoUrlCtrl.text.trim(),
              file: _file,
            );
            Navigator.pop(context, payload);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}


