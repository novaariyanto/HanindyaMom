import 'package:flutter/material.dart';
import 'package:hanindyamom/models/activity_tip.dart';
import 'package:hanindyamom/l10n/app_localizations.dart';

class ActivityTipsScreen extends StatelessWidget {
  final int ageMonths;
  const ActivityTipsScreen({super.key, required this.ageMonths});

  @override
  Widget build(BuildContext context) {
    final tips = ActivityTipsRepo.forAgeMonths(ageMonths);
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.tr('tips.title'))),
      body: tips.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  loc.tr('tips.empty_for_age'),
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tips.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final t = tips[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('${t.minMonth}-${t.maxMonth} bln', style: theme.textTheme.bodySmall?.copyWith(color: Colors.purple)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(t.title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(t.description),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
