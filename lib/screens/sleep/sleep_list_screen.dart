import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/sleep_service.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/screens/activities/sleep_form_screen.dart';
import 'package:hanindyamom/models/sleep.dart' as ui;
import 'package:hanindyamom/l10n/app_localizations.dart';

class SleepListScreen extends StatefulWidget {
  const SleepListScreen({super.key});

  @override
  State<SleepListScreen> createState() => _SleepListScreenState();
}

class _SleepListScreenState extends State<SleepListScreen> {
  final _items = <SleepLogApiModel>[];
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
      final list = await SleepService().list(babyId, page: _page, limit: _limit, q: _q);
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
      final list = await SleepService().list(babyId, page: next, limit: _limit, q: _q);
      setState(() {
        _page = next;
        _items.addAll(list);
        _hasMore = list.length == _limit;
        _loadingMore = false;
      });
    } catch (e) {
      setState(() => _loadingMore = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('common.load_failed', {'error': '$e'}))));
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
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('sleep.title'))),
      body: Column(
        children: [
          _buildSearchBar(theme, loc),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_error != null
                    ? _buildErrorState(loc)
                    : RefreshIndicator(
                        onRefresh: _refresh,
                        child: _items.isEmpty ? _buildEmptyState(theme, loc) : _buildList(theme, loc),
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

  Widget _buildSearchBar(ThemeData theme, AppLocalizations loc) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: loc.tr('common.search_hint'),
                prefixIcon: const Icon(Icons.search),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: _onSearch, child: Text(loc.tr('common.search'))),
        ],
      ),
    );
  }

  Widget _buildList(ThemeData theme, AppLocalizations loc) {
    return ListView.separated(
      controller: _scroll,
      padding: const EdgeInsets.all(16),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
        }
        final s = _items[index];
        final start = DateTime.tryParse(s.startTime) ?? DateTime.now();
        final end = DateTime.tryParse(s.endTime) ?? DateTime.now();
        final duration = Duration(minutes: s.durationMinutes);
        return Card(
          child: ListTile(
            leading: const Icon(Icons.bedtime, color: Colors.purple),
            title: Text('${DateFormat('dd MMM yyyy, HH:mm', loc.dateLocaleTag).format(start)} • ${DateFormat('HH:mm', loc.dateLocaleTag).format(end)}'),
            subtitle: Text('${loc.tr('sleep.duration')}: ${duration.inHours}${loc.tr('common.hour_unit')} ${duration.inMinutes % 60}${loc.tr('common.minute_unit')}${s.notes != null ? '\n${s.notes}' : ''}'),
            isThreeLine: s.notes != null,
            onTap: () => _edit(s),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  _edit(s);
                } else if (v == 'delete') {
                  await _delete(s.id);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text(AppLocalizations.of(context).tr('common.edit'))),
                PopupMenuItem(value: 'delete', child: Text(AppLocalizations.of(context).tr('common.delete'))),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, AppLocalizations loc) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(Icons.bedtime, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text(loc.tr('sleep.empty_title'), style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(loc.tr('common.pull_to_refresh_or_add'),
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildErrorState(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(loc.tr('common.load_failed', {'error': '$_error'})),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: _refresh, child: Text(loc.tr('common.retry'))),
        ],
      ),
    );
  }

  Future<void> _addNew() async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final ok = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SleepFormScreen(babyId: babyId)),
    );
    if (ok == true) _refresh();
  }

  Future<void> _edit(SleepLogApiModel s) async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    final start = DateTime.tryParse(s.startTime) ?? DateTime.now();
    final end = DateTime.tryParse(s.endTime) ?? DateTime.now();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SleepFormScreen(
          babyId: babyId,
          sleep: ui.Sleep(id: s.id, babyId: s.babyId, startTime: start, endTime: end, notes: s.notes),
        ),
      ),
    );
    _refresh();
  }

  Future<void> _delete(String id) async {
    try {
      await SleepService().delete(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('common.deleted'))));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('common.delete_failed', {'error': '$e'}))));
    }
  }
}


