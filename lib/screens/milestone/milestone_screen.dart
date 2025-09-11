import 'package:flutter/material.dart';
import 'package:hanindyamom/models/milestone.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/milestones_service.dart';
import 'package:intl/intl.dart';

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  List<Milestone> milestones = [];
  bool _loading = true;
  String? _error;
  bool _didFetch = false;
  SelectedBabyProvider? _babyProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetch();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetch) {
      _didFetch = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _fetch());
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
    if (!mounted) return;
    if (babyId == null) {
      setState(() => _loading = false);
      return;
    }
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final total = milestones.length;
    final achieved = milestones.where((m) => m.achieved).length;
    final progress = total == 0 ? 0.0 : achieved / total;

    return Scaffold(
      appBar: AppBar(title: const Text('Milestone Tracker')),
      floatingActionButton: FloatingActionButton(onPressed: _create, child: const Icon(Icons.add)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : RefreshIndicator(
                  onRefresh: _fetch,
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.emoji_events, color: Colors.amber),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Progress Milestone', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200),
                                    const SizedBox(height: 8),
                                    Text('$achieved / $total tercapai'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...milestones.map(_buildMilestoneCard).toList(),
                    ],
                  ),
                )),
    );
  }

  Widget _buildMilestoneCard(Milestone m) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: m.achieved,
              onChanged: (val) => _toggleAchieved(m, val ?? false),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('${m.month} bln', style: theme.textTheme.bodySmall?.copyWith(color: Colors.pink)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(m.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(m.description, style: theme.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      TextButton.icon(onPressed: () => _edit(m), icon: const Icon(Icons.edit, size: 16), label: const Text('Edit')),
                      const SizedBox(width: 8),
                      TextButton.icon(onPressed: () => _delete(m), icon: const Icon(Icons.delete, size: 16, color: Colors.red), label: const Text('Hapus', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      milestones = await MilestonesService().list(babyId);
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = '$e';
      });
    }
  }

  Future<void> _toggleAchieved(Milestone m, bool val) async {
    try {
      final updated = await MilestonesService().update(
        m.id,
        achieved: val,
        achievedAt: val ? DateTime.now() : null,
      );
      final idx = milestones.indexWhere((x) => x.id == m.id);
      setState(() => milestones[idx] = updated);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal update: $e')));
    }
  }

  Future<void> _create() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final res = await showDialog<Milestone>(
      context: context,
      builder: (_) => _MilestoneDialog(),
    );
    if (res != null) {
      try {
        final created = await MilestonesService().create(
          babyId: babyId,
          month: res.month,
          title: res.title,
          description: res.description,
          achieved: res.achieved,
          achievedAt: res.achievedAt,
        );
        setState(() => milestones.insert(0, created));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal membuat: $e')));
      }
    }
  }

  Future<void> _edit(Milestone m) async {
    final res = await showDialog<Milestone>(
      context: context,
      builder: (_) => _MilestoneDialog(initial: m),
    );
    if (res != null) {
      try {
        final updated = await MilestonesService().update(
          m.id,
          month: res.month,
          title: res.title,
          description: res.description,
          achieved: res.achieved,
          achievedAt: res.achievedAt,
        );
        final idx = milestones.indexWhere((x) => x.id == m.id);
        setState(() => milestones[idx] = updated);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    }
  }

  Future<void> _delete(Milestone m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Milestone'),
        content: Text('Hapus "${m.title}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await MilestonesService().delete(m.id);
      setState(() => milestones.removeWhere((x) => x.id == m.id));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }
}

class _MilestoneDialog extends StatefulWidget {
  final Milestone? initial;
  const _MilestoneDialog({this.initial});
  @override
  State<_MilestoneDialog> createState() => _MilestoneDialogState();
}

class _MilestoneDialogState extends State<_MilestoneDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  bool _achieved = false;
  DateTime? _achievedAt;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) {
      final m = widget.initial!;
      _titleCtrl.text = m.title;
      _descCtrl.text = m.description;
      _monthCtrl.text = m.month.toString();
      _achieved = m.achieved;
      _achievedAt = m.achievedAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Tambah Milestone' : 'Edit Milestone'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _monthCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Usia (bulan) 0..120'),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(v);
                  if (n == null || n < 0 || n > 120) return 'Harus 0..120';
                  return null;
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Judul'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _achieved,
                onChanged: (v) => setState(() => _achieved = v ?? false),
                title: const Text('Tercapai'),
              ),
              if (_achieved)
                TextButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final d = await showDatePicker(context: context, initialDate: _achievedAt ?? now, firstDate: DateTime(now.year - 2), lastDate: now);
                    if (d != null) setState(() => _achievedAt = DateTime(d.year, d.month, d.day));
                  },
                  icon: const Icon(Icons.event),
                  label: Text(_achievedAt == null ? 'Pilih tanggal tercapai' : DateFormat('dd MMM yyyy', 'id_ID').format(_achievedAt!)),
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
            final month = int.parse(_monthCtrl.text);
            final m = Milestone(
              id: 'temp',
              babyId: 'temp',
              month: month,
              title: _titleCtrl.text.trim(),
              description: _descCtrl.text.trim(),
              achieved: _achieved,
              achievedAt: _achievedAt,
            );
            Navigator.pop(context, m);
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
