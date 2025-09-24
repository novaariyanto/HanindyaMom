import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/services/growth_service.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/screens/growth/growth_form_screen.dart';
import 'package:hanindyamom/l10n/app_localizations.dart';

class GrowthListScreen extends StatefulWidget {
  const GrowthListScreen({super.key});

  @override
  State<GrowthListScreen> createState() => _GrowthListScreenState();
}

class _GrowthListScreenState extends State<GrowthListScreen> {
  final _items = <GrowthLogApiModel>[];
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
      final list = await GrowthService().list(babyId, page: _page, limit: _limit, q: _q);
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
      final list = await GrowthService().list(babyId, page: next, limit: _limit, q: _q);
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
      appBar: AppBar(title: Text(loc.tr('growth.title'))),
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
        final g = _items[index];
        final date = DateTime.tryParse(g.date) ?? DateTime.now();
        final when = DateFormat('dd MMM yyyy', loc.dateLocaleTag).format(date);
        return Card(
          child: ListTile(
            leading: const Icon(Icons.monitor_weight, color: Colors.pink),
            title: Text('${g.weight.toStringAsFixed(1)} kg • ${g.height.toStringAsFixed(0)} cm'),
            subtitle: Text('$when${g.headCircumference != null ? ' • LK ${g.headCircumference} cm' : ''}'),
            onTap: () => _edit(g),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  _edit(g);
                } else if (v == 'delete') {
                  await _delete(g.id);
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
              Icon(Icons.monitor_weight, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text(loc.tr('growth.empty_title'), style: theme.textTheme.titleMedium),
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
      MaterialPageRoute(builder: (_) => GrowthFormScreen(babyId: babyId)),
    );
    if (ok == true) _refresh();
  }

  Future<void> _edit(GrowthLogApiModel g) async {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GrowthFormScreen(
          babyId: babyId,
        ),
      ),
    );
    _refresh();
  }

  Future<void> _delete(String id) async {
    try {
      await GrowthService().delete(id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('common.deleted'))));
      _refresh();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).tr('common.delete_failed', {'error': '$e'}))));
    }
  }
}


