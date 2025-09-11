import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(title: const Text('Bantuan & Dukungan')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: const [
            Text('FAQ', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Q: Bagaimana cara menambahkan aktivitas?\nA: Tekan tombol + di halaman Timeline.'),
            SizedBox(height: 16),
            Text('Kontak Dukungan', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Email: support@hanindyamom.app'),
          ],
        ),
      ),
    );
  }
}


