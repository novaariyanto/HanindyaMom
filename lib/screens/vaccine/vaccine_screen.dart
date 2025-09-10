import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/vaccine_service.dart';
import 'package:intl/intl.dart';

class VaccineScreen extends StatefulWidget {
  const VaccineScreen({super.key});

  @override
  State<VaccineScreen> createState() => _VaccineScreenState();
}

class _VaccineScreenState extends State<VaccineScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> items = [];

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
      final list = await VaccineService().list(babyId);
      items = list
          .map((v) => {
                'id': v.id,
                'name': v.vaccineName,
                'date': v.scheduleDate,
                'status': v.status,
                'notes': v.notes,
              })
          .toList();
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
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Vaksin')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final v = items[index];
                    final date = DateTime.tryParse(v['date'] ?? '') ?? DateTime.now();
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.vaccines, color: Colors.blue),
                        title: Text(v['name'] ?? '-', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        subtitle: Text('${DateFormat('dd MMM yyyy', 'id_ID').format(date)}\nStatus: ${v['status']}'),
                        isThreeLine: true,
                        trailing: PopupMenuButton<String>(
                          onSelected: (val) async {
                            if (val == 'done') {
                              await VaccineService().update(v['id'], status: 'done');
                              _fetch();
                            } else if (val == 'delete') {
                              await VaccineService().delete(v['id']);
                              _fetch();
                            }
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(value: 'done', child: Text('Tandai Selesai')),
                            PopupMenuItem(value: 'delete', child: Text('Hapus')),
                          ],
                        ),
                      ),
                    );
                  },
                )),
      floatingActionButton: FloatingActionButton(
        onPressed: _addVaccine,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addVaccine() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await VaccineService().create(babyId: babyId, vaccineName: 'Vaksin Baru', scheduleDate: today);
    _fetch();
  }
}
