import 'package:flutter/material.dart';
import 'package:hanindyamom/models/baby.dart';
import 'package:hanindyamom/models/growth.dart';
import 'package:hanindyamom/models/milestone.dart';
import 'package:hanindyamom/models/nutrition.dart';
import 'package:hanindyamom/screens/baby/baby_form_screen.dart';
import 'package:hanindyamom/screens/growth/growth_screen.dart';
import 'package:hanindyamom/screens/milestone/milestone_screen.dart';
import 'package:hanindyamom/screens/nutrition/nutrition_form_screen.dart';
import 'package:hanindyamom/screens/tips/activity_tips_screen.dart';
import 'package:hanindyamom/screens/vaccine/vaccine_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock data - dalam implementasi nyata akan dari database/API
  List<Baby> babies = [
    Baby(
      id: '1',
      name: 'Alya Zahra',
      birthDate: DateTime(2022, 12, 15),
      photoPath: null,
      weight: 12.0,
      height: 86.0,
      gender: 'female',
    ),
  ];

  // Mock growth records
  List<GrowthRecord> growthRecords = [
    GrowthRecord(id: 'g1', babyId: '1', date: DateTime.now().subtract(const Duration(days: 60)), weightKg: 11.0, heightCm: 84),
    GrowthRecord(id: 'g2', babyId: '1', date: DateTime.now().subtract(const Duration(days: 30)), weightKg: 11.5, heightCm: 85),
    GrowthRecord(id: 'g3', babyId: '1', date: DateTime.now(), weightKg: 12.0, heightCm: 86),
  ];

  // Mock milestones
  late List<Milestone> milestones;

  // Mock nutrition
  List<NutritionEntry> nutritionEntries = [];

  @override
  void initState() {
    super.initState();
    milestones = MilestoneTemplates.generateForBaby('1');
    // Tandai beberapa tercapai
    milestones = milestones
        .map((m) => (m.month <= 24) ? m.copyWith(achieved: true, achievedAt: DateTime.now()) : m)
        .toList();
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
      body: babies.isEmpty ? _buildEmptyState() : _buildDashboard(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const BabyFormScreen(),
            ),
          );
          
          if (result != null && result is Baby) {
            setState(() {
              babies.add(result);
            });
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboard() {
    final theme = Theme.of(context);
    final baby = babies.first;

    // WHO status dari record terakhir atau dari field baby
    final latest = growthRecords.isNotEmpty
        ? growthRecords.last
        : (baby.weight != null && baby.height != null
            ? GrowthRecord(
                id: 'latest',
                babyId: baby.id,
                date: DateTime.now(),
                weightKg: baby.weight!,
                heightCm: baby.height!,
              )
            : null);

    final whoStatus = (latest != null)
        ? GrowthUtils.classifyByBmi(weightKg: latest.weightKg, heightCm: latest.heightCm)
        : null;

    final totalMilestone = milestones.length;
    final achievedMilestone = milestones.where((m) => m.achieved).length;
    final milestoneProgress = totalMilestone == 0 ? 0.0 : achievedMilestone / totalMilestone;

    final recs = NutritionRecommendations.forAgeMonths(baby.ageInMonths);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header profil singkat
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                child: const Icon(Icons.baby_changing_station, color: Colors.pink),
              ),
              title: Text(baby.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              subtitle: Text('${baby.ageString}${baby.gender != null ? ' • ${baby.gender == 'male' ? 'Laki-laki' : 'Perempuan'}' : ''}'),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => BabyFormScreen(baby: baby)),
                  );
                  if (result != null && result is Baby) {
                    setState(() {
                      babies[0] = result;
                    });
                  }
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
                final result = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BabyFormScreen(),
                  ),
                );
                
                if (result != null && result is Baby) {
                  setState(() {
                    babies.add(result);
                  });
                }
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
