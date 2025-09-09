import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hanindyamom/theme/app_theme.dart';
import 'package:hanindyamom/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:hanindyamom/repositories/timeline_repository.dart';

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
    return ChangeNotifierProvider(
      create: (_) {
        final repo = TimelineRepository();
        repo.seedMock();
        return repo;
      },
      child: MaterialApp(
        title: 'HanindyaMom',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
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
