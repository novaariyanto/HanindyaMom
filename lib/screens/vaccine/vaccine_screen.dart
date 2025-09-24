import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/vaccine_service.dart';
import 'package:intl/intl.dart';
import 'package:dio/dio.dart';
import 'package:hanindyamom/models/vaccine.dart';
import 'package:hanindyamom/l10n/app_localizations.dart';

class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  bool _loading = true;
  String? _error;
  List<VaccineEntry> items = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetch();
  }

  Future<void> _fetch() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      items = await VaccineService().list(babyId);
      setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('vaccine.title'))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text(loc.tr('common.load_failed', {'error': '$_error'})))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final v = items[index];
                    final date = DateTime.tryParse(v.scheduleDate) ?? DateTime.now();
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.vaccines, color: Colors.blue),
                        title: Text(v.vaccineName, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('${DateFormat('dd MMM yyyy', loc.dateLocaleTag).format(date)}\n${loc.tr('vaccine.status')}: ${v.status}${v.notes == null ? '' : '\n${loc.tr('vaccine.notes')}: ${v.notes}'}'),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) async {
                            if (val == 'done') {
                              await VaccineService().update(v.id, status: 'done');
                              _fetch();
                            } else if (val == 'delete') {
                              await VaccineService().delete(v.id);
                              _fetch();
                            } else if (val == 'edit') {
                              _openForm(initial: v);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(value: 'done', child: Text(loc.tr('vaccine.mark_done'))),
                            PopupMenuItem(value: 'edit', child: Text(loc.tr('common.edit'))),
                            PopupMenuItem(value: 'delete', child: Text(loc.tr('common.delete'))),
                          ],
                        ),
                      ),
                    );
                  },
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _openForm({VaccineEntry? initial}) async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final result = await showDialog<_VaccinePayload>(
      context: context,
      builder: (_) => _VaccineDialog(initial: initial),
    );
    if (result == null) return;
    try {
      if (initial == null) {
        final created = await VaccineService().create(
          babyId: babyId,
          vaccineName: result.vaccineName,
          scheduleDate: result.scheduleDate,
          status: result.status,
          notes: result.notes,
        );
        setState(() => items.insert(0, created));
      } else {
        final updated = await VaccineService().update(
          initial.id,
          vaccineName: result.vaccineName,
          scheduleDate: result.scheduleDate,
          status: result.status,
          notes: result.notes,
        );
        final idx = items.indexWhere((x) => x.id == initial.id);
        setState(() => items[idx] = updated);
      }
    } on DioException catch (e) {
      final msg = e.response?.data is Map<String, dynamic> ? (e.response?.data['message'] ?? e.message) : e.message;
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('common.save_failed', {'error': '$msg'}))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('common.save_failed', {'error': '$e'}))));
    }
  }
}

class _VaccinePayload {
  final String vaccineName;
  final String scheduleDate; // YYYY-MM-DD
  final String status; // 'scheduled' | 'done'
  final String? notes;
  _VaccinePayload({required this.vaccineName, required this.scheduleDate, required this.status, this.notes});
}

class _VaccineDialog extends StatefulWidget {
  final VaccineEntry? initial;
  const _VaccineDialog({this.initial});
  @override
  State<_VaccineDialog> createState() => _VaccineDialogState();
}

class _VaccineDialogState extends State<_VaccineDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();
  String _status = 'scheduled';

  @override
  void initState() {
    super.initState();
    final v = widget.initial;
    if (v != null) {
      _nameCtrl.text = v.vaccineName;
      _notesCtrl.text = v.notes ?? '';
      _date = DateTime.tryParse(v.scheduleDate) ?? DateTime.now();
      _status = v.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.initial == null ? loc.tr('vaccine.add_title') : loc.tr('vaccine.edit_title')),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: loc.tr('vaccine.name_label')),
                validator: (v) => v == null || v.trim().isEmpty ? loc.tr('common.required') : null,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Text(DateFormat('yyyy-MM-dd').format(_date))),
                  TextButton.icon(
                    onPressed: () async {
                      final d = await showDatePicker(context: context, initialDate: _date, firstDate: DateTime(2000), lastDate: DateTime(2100));
                      if (d != null) setState(() => _date = d);
                    },
                    icon: const Icon(Icons.event),
                    label: Text(loc.tr('common.pick_date')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(loc.tr('vaccine.status')),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(value: 'scheduled', label: Text(loc.tr('vaccine.status_scheduled'))),
                      ButtonSegment(value: 'done', label: Text(loc.tr('vaccine.status_done'))),
                    ],
                    selected: {_status},
                    onSelectionChanged: (s) => setState(() => _status = s.first),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: loc.tr('vaccine.notes_optional')),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(loc.tr('common.cancel'))),
        ElevatedButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            final payload = _VaccinePayload(
              vaccineName: _nameCtrl.text.trim(),
              scheduleDate: DateFormat('yyyy-MM-dd').format(_date),
              status: _status,
              notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
            );
            Navigator.pop(context, payload);
          },
          child: Text(loc.tr('common.save')),
        ),
      ],
    );
  }
}
