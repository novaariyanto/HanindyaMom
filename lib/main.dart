import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hanindyamom/theme/app_theme.dart';
import 'package:hanindyamom/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/repositories/timeline_repository.dart';
import 'package:hanindyamom/providers/selected_baby_provider.dart';
import 'package:hanindyamom/screens/feeding/feeding_list_screen.dart';
import 'package:hanindyamom/screens/diaper/diaper_list_screen.dart';
import 'package:hanindyamom/screens/sleep/sleep_list_screen.dart';
import 'package:hanindyamom/screens/growth/growth_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const HanindyaMomApp());
}

class HanindyaMomApp extends StatelessWidget {
  const HanindyaMomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final repo = TimelineRepository();
          repo.seedMock();
          return repo;
        }),
        ChangeNotifierProvider(create: (_) => SelectedBabyProvider()),
      ],
      child: MaterialApp(
        title: 'HanindyaMom',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/feeding_list': (context) => const FeedingListRouteGuard(),
          '/diaper_list': (context) => const DiaperListRouteGuard(),
          '/sleep_list': (context) => const SleepListRouteGuard(),
          '/growth_list': (context) => const GrowthListRouteGuard(),
        },
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('id', 'ID'),
          Locale('en', 'US'),
        ],
      ),
    );
  }
}

// Route guard sederhana: pastikan ada babyId
class FeedingListRouteGuard extends StatelessWidget {
  const FeedingListRouteGuard({super.key});
  @override
  Widget build(BuildContext context) {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) {
      return const Scaffold(body: Center(child: Text('Pilih bayi terlebih dahulu')));
    }
    return const FeedingListScreen();
  }
}

class DiaperListRouteGuard extends StatelessWidget {
  const DiaperListRouteGuard({super.key});
  @override
  Widget build(BuildContext context) {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) {
      return const Scaffold(body: Center(child: Text('Pilih bayi terlebih dahulu')));
    }
    return const DiaperListScreen();
  }
}

class SleepListRouteGuard extends StatelessWidget {
  const SleepListRouteGuard({super.key});
  @override
  Widget build(BuildContext context) {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) {
      return const Scaffold(body: Center(child: Text('Pilih bayi terlebih dahulu')));
    }
    return const SleepListScreen();
  }
}

class GrowthListRouteGuard extends StatelessWidget {
  const GrowthListRouteGuard({super.key});
  @override
  Widget build(BuildContext context) {
    final babyId = context.read<SelectedBabyProvider>().babyId;
    if (babyId == null) {
      return const Scaffold(body: Center(child: Text('Pilih bayi terlebih dahulu')));
    }
    return const GrowthListScreen();
  }
}
