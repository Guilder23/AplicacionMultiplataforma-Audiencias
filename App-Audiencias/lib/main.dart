import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'providers/audiencia_provider.dart';
import 'screens/splash_screen.dart';
import 'services/local_storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  runApp(const AudienciasApp());
}

class AudienciasApp extends StatelessWidget {
  const AudienciasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create:
          (_) =>
              AudienciaProvider(LocalStorageService.instance)..loadAudiencias(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sistema de Audiencias',
        theme: AppTheme.light,
        home: const SplashScreen(),
      ),
    );
  }
}
