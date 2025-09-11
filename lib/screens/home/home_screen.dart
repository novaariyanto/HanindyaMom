import 'package:flutter/material.dart';
import 'package:hanindyamom/models/baby.dart';
import 'package:hanindyamom/models/growth.dart';
import 'package:hanindyamom/models/milestone.dart';
import 'package:hanindyamom/models/nutrition.dart';
import 'package:hanindyamom/models/api_models.dart';
import 'package:hanindyamom/services/baby_service.dart';
import 'package:hanindyamom/services/growth_service.dart';
import 'package:hanindyamom/services/milestones_service.dart';
import 'package:hanindyamom/screens/baby/baby_form_screen.dart';
import 'package:hanindyamom/screens/growth/growth_screen.dart';
import 'package:hanindyamom/screens/milestone/milestone_screen.dart';
import 'package:hanindyamom/screens/nutrition/nutrition_form_screen.dart';
import 'package:hanindyamom/screens/tips/activity_tips_screen.dart';
import 'package:hanindyamom/screens/vaccine/vaccine_screen.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Data API
  List<BabyApiModel> babiesApi = [];
  GrowthLogApiModel? _latestGrowth;
  bool _loading = true;
  String? _error;
  String? _selectedBabyId;

  // Milestones dari API
  List<Milestone> _milestones = [];

  // Mock nutrition
  List<NutritionEntry> nutritionEntries = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBabies();
    });
  }

  Future<void> _fetchBabies() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await BabyService().list();
      babiesApi = list;
      // Tentukan pilihan anak aktif: gunakan pilihan user jika ada; jika tidak ada, gunakan anak terakhir sebagai default
      if (babiesApi.isNotEmpty) {
        final provider = context.read<SelectedBabyProvider>();
        if (provider.babyId != null && babiesApi.any((b) => b.id == provider.babyId)) {
          _selectedBabyId = provider.babyId;
        } else {
          _selectedBabyId = babiesApi.last.id; // default: anak terakhir ditambahkan
          provider.setBaby(_selectedBabyId);
        }
        _fetchLatestGrowth(_selectedBabyId!);
        _fetchMilestones(_selectedBabyId!);
      }
      _loading = false;
      setState(() {});
    } catch (e) {
      setState(() {
        _error = '$e';
        _loading = false;
      });
    }
  }

  Future<void> _fetchLatestGrowth(String babyId) async {
    try {
      final list = await GrowthService().list(babyId);
      if (list.isNotEmpty) {
        list.sort((a, b) => a.date.compareTo(b.date));
        _latestGrowth = list.last;
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _fetchMilestones(String babyId) async {
    try {
      // gunakan service milestones API
      final list = await MilestonesService().list(babyId);
      setState(() => _milestones = list);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('HanindyaMom'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fitur notifikasi belum tersedia')),
              );
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : (babiesApi.isEmpty ? _buildEmptyState() : _buildDashboard())),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BabyFormScreen(),
            ),
          );
          _fetchBabies();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboard() {
    final theme = Theme.of(context);
    // Tentukan bayi aktif dari state
    final apiBaby = (babiesApi.firstWhere(
      (b) => b.id == _selectedBabyId,
      orElse: () => babiesApi.last,
    ));
    final baby = Baby(
      id: apiBaby.id,
      name: apiBaby.name,
      birthDate: DateTime.parse(apiBaby.birthDate),
    );

    // WHO status dari growth API (jika tersedia)
    GrowthRecord? latest;
    if (_latestGrowth != null) {
      latest = GrowthRecord(
        id: _latestGrowth!.id,
        babyId: _latestGrowth!.babyId,
        date: DateTime.tryParse(_latestGrowth!.date) ?? DateTime.now(),
        weightKg: _latestGrowth!.weight,
        heightCm: _latestGrowth!.height,
      );
    }

    final whoStatus = (latest != null)
        ? GrowthUtils.classifyByBmi(weightKg: latest.weightKg, heightCm: latest.heightCm)
        : null;

    final totalMilestone = _milestones.length;
    final achievedMilestone = _milestones.where((m) => m.achieved).length;
    final milestoneProgress = totalMilestone == 0 ? 0.0 : achievedMilestone / totalMilestone;

    final recs = NutritionRecommendations.forAgeMonths(baby.ageInMonths);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selector anak + Header profil singkat
          _buildBabySelector(),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                child: const Icon(Icons.baby_changing_station, color: Colors.pink),
              ),
              title: Text(baby.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text(baby.ageString),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => BabyFormScreen(baby: baby)),
                  );
                  _fetchBabies();
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // WHO Status Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.pink.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.monitor_weight, color: Colors.pink),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status WHO (Terakhir)', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          latest != null
                              ? '${latest.weightKg.toStringAsFixed(1)} kg • ${latest.heightCm.toStringAsFixed(0)} cm'
                              : 'Belum ada data',
                        ),
                        if (whoStatus != null)
                          Text(
                            GrowthUtils.statusText(whoStatus),
                            style: TextStyle(
                              color: whoStatus == WhoStatus.normal
                                  ? Colors.green
                                  : whoStatus == WhoStatus.underweight
                                      ? Colors.orange
                                      : Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const GrowthScreen()),
                      );
                    },
                    child: const Text('Detail'),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Milestone progress
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.amber),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Milestone Progress', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(value: milestoneProgress, backgroundColor: Colors.grey.shade200),
                            const SizedBox(height: 8),
                            Text('$achievedMilestone / $totalMilestone tercapai'),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const MilestoneScreen()),
                          );
                        },
                        child: const Text('Lihat'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Nutrition recommendations & quick add
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.restaurant_menu, color: Colors.green),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Rekomendasi Nutrisi', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      TextButton(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => NutritionFormScreen(babyId: baby.id)),
                          );
                        },
                        child: const Text('Catat Menu'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...recs.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green, size: 16),
                            const SizedBox(width: 6),
                            Expanded(child: Text(r)),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Shortcuts: Vaccine & Activity Tips
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const VaccineScreen()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: const [
                          Icon(Icons.vaccines, color: Colors.blue),
                          SizedBox(height: 8),
                          Text('Jadwal Vaksin', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => ActivityTipsScreen(ageMonths: baby.ageInMonths)),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: const [
                          Icon(Icons.lightbulb, color: Colors.purple),
                          SizedBox(height: 8),
                          Text('Activity Tips', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBabySelector() {
    if (babiesApi.length <= 1) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: babiesApi.map((b) {
          final selected = b.id == _selectedBabyId;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(b.name),
              selected: selected,
              onSelected: (val) {
                if (!val) return;
                setState(() {
                  _selectedBabyId = b.id;
                });
                context.read<SelectedBabyProvider>().setBaby(b.id);
                _fetchLatestGrowth(b.id);
                _fetchMilestones(b.id);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                Icons.baby_changing_station,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum ada profil bayi',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tambahkan profil bayi pertama Anda untuk mulai memantau perkembangannya',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onBackground.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BabyFormScreen(),
                  ),
                );
                _fetchBabies();
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Bayi'),
            ),
          ],
        ),
      ),
    );
  }
}
