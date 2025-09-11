import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(title: const Text('Kebijakan Privasi')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Kebijakan Privasi HanindyaMom\n\n'
            'Kami menghormati privasi Anda. Data yang dikumpulkan digunakan untuk '
            'menyediakan layanan dan meningkatkan pengalaman aplikasi. '
            'Kami tidak membagikan data pribadi tanpa persetujuan Anda, kecuali '
            'diperlukan oleh hukum.\n\n'
            'Dengan menggunakan aplikasi ini, Anda menyetujui pengumpulan dan penggunaan '
            'informasi sesuai kebijakan ini.',
          ),
        ),
      ),
    );
  }
}


