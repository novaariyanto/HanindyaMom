import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(title: const Text('Syarat & Ketentuan')),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(
            'Syarat & Ketentuan\n\n'
            'Dengan menggunakan aplikasi HanindyaMom, Anda setuju untuk mematuhi '
            'aturan penggunaan yang berlaku. Anda bertanggung jawab atas aktivitas '
            'di akun Anda. Jangan menyalahgunakan layanan atau melanggar hukum yang berlaku.\n\n'
            'Kami dapat memperbarui ketentuan ini sewaktu-waktu.',
          ),
        ),
      ),
    );
  }
}


