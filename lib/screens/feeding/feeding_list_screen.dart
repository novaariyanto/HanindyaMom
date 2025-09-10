import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/feeding_service.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/screens/activities/feeding_form_screen.dart';
import 'package:hanindyamom/models/feeding.dart' as ui;

class FeedingListScreen extends StatefulWidget {
  const FeedingListScreen({super.key});

  @override
  State<FeedingListScreen> createState() => _FeedingListScreenState();
}

class _FeedingListScreenState extends State<FeedingListScreen> {
  final _items = <FeedingLogApiModel>[];
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();
  bool _loading = true;
  bool _loadingMore = false;
  String? _error;
  int _page = 1;
  final int _limit = 20;
  bool _hasMore = true;
  String _q = '';

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refresh();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    setState(() {
      _loading = true;
      _error = null;
      _page = 1;
      _hasMore = true;
      _items.clear();
    });
    try {
      final list = await FeedingService().list(babyId, page: _page, limit: _limit, q: _q);
      setState(() {
        _items.addAll(list);
        _loading = false;
        _hasMore = list.length == _limit;
      });
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (!_hasMore || _loadingMore || _loading) return;
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final list = await FeedingService().list(babyId, page: next, limit: _limit, q: _q);
      setState(() {
        _page = next;
        _items.addAll(list);
        _hasMore = list.length == _limit;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() {
        _loadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat halaman berikutnya: $e')));
      }
    }
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _onSearch() {
    _q = _searchCtrl.text.trim();
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Feeding')),
      body: Column(
        children: [
          _buildSearchBar(theme),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_error != null
                    ? _buildErrorState()
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: _items.isEmpty ? _buildEmptyState(theme) : _buildList(theme),
                      )),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNew,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: const InputDecoration(
                hintText: 'Cari jenis/notes...',
                prefixIcon: Icon(Icons.search),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _onSearch,
            child: const Text('Cari'),
          ),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
        final f = _items[index];
        final dt = DateTime.tryParse(f.startTime) ?? DateTime.now();
        final when = DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt);
        final type = _mapType(f.type);
        return Card(
          child: ListTile(
            leading: const Icon(Icons.restaurant, color: Colors.blue),
            title: Text('${type.label} • ${f.durationMinutes} menit'),
            subtitle: Text('$when${f.notes != null ? '\n${f.notes}' : ''}'),
            isThreeLine: f.notes != null,
            onTap: () => _edit(f),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  _edit(f);
                } else if (v == 'delete') {
                  await _delete(f.id);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Hapus')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.restaurant, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Belum ada data feeding', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text('Tarik ke bawah untuk refresh atau tambah data baru.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Gagal memuat: $_error'),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _refresh, child: const Text('Coba Lagi')),
        ],
      ),
    );
  }

  Future<void> _addNew() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final ok = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => FeedingFormScreen(babyId: babyId)),
    );
    if (ok == true) _refresh();
  }

  Future<void> _edit(FeedingLogApiModel f) async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    // Map ke model UI untuk form
    final type = _mapType(f.type).type;
    final start = DateTime.tryParse(f.startTime) ?? DateTime.now();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FeedingFormScreen(
          babyId: babyId,
          feeding: ui.Feeding(
            id: f.id,
            babyId: f.babyId,
            type: type,
            startTime: start,
            durationMinutes: f.durationMinutes,
            notes: f.notes,
          ),
        ),
      ),
    );
    _refresh();
  }

  Future<void> _delete(String id) async {
    try {
      await FeedingService().delete(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Berhasil dihapus')));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal menghapus: $e')));
    }
  }
}

class _FeedingTypeMap {
  final String label;
  final ui.FeedingType type;
  _FeedingTypeMap(this.label, this.type);
}

_FeedingTypeMap _mapType(String t) {
  switch (t) {
    case 'asi_left':
      return _FeedingTypeMap('ASI Kiri', ui.FeedingType.breastLeft);
    case 'asi_right':
      return _FeedingTypeMap('ASI Kanan', ui.FeedingType.breastRight);
    case 'formula':
      return _FeedingTypeMap('Formula', ui.FeedingType.formula);
    case 'pump':
      return _FeedingTypeMap('Pompa', ui.FeedingType.pump);
    default:
      return _FeedingTypeMap(t, ui.FeedingType.breastLeft);
  }
}


