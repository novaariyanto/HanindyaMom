import 'package:flutter/material.dart';
import 'package:hanindyamom/models/vaccine.dart';

class VaccineScreen extends StatelessWidget {
  const VaccineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vaccines = VaccineScheduleIDAI.list();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Vaksin IDAI')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: vaccines.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final v = vaccines[index];
          return Card(
            child: ListTile(
              leading: const Icon(Icons.vaccines, color: Colors.blue),
              title: Text(v.name, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
              subtitle: Text('Usia disarankan: ${v.recommendedMonth} bulan\n${v.description}'),
              isThreeLine: true,
              trailing: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Reminder untuk ${v.name} disetel (mock)')),
                  );
                },
                child: const Text('Ingatkan'),
              ),
            ),
          );
        },
      ),
    );
  }
}
