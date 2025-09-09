import 'package:flutter/material.dart';
import 'package:hanindyamom/models/milestone.dart';

class MilestoneScreen extends StatefulWidget {
  const MilestoneScreen({super.key});

  @override
  State<MilestoneScreen> createState() => _MilestoneScreenState();
}

class _MilestoneScreenState extends State<MilestoneScreen> {
  // Mock generate untuk babyId '1'
  late List<Milestone> milestones;

  @override
  void initState() {
    super.initState();
    milestones = MilestoneTemplates.generateForBaby('1');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final total = milestones.length;
    final achieved = milestones.where((m) => m.achieved).length;
    final progress = total == 0 ? 0.0 : achieved / total;

    return Scaffold(
      appBar: AppBar(title: const Text('Milestone Tracker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
      ),
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
              onChanged: (val) {
                setState(() {
                  final idx = milestones.indexWhere((x) => x.id == m.id);
                  milestones[idx] = milestones[idx].copyWith(
                    achieved: val ?? false,
                    achievedAt: val == true ? DateTime.now() : null,
                  );
                });
              },
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
