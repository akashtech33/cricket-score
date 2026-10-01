import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/cricket_data_service.dart';
import 'services/firestore_service.dart';
import 'providers/auth_provider.dart';
import 'providers/match_provider.dart';
import 'providers/score_provider.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/audience/audience_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF131D31),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase.initializeApp() notice (running in resilient mode): $e');
  }

  runApp(const CricPulseApp());
}

class CricPulseApp extends StatelessWidget {
  final Widget? homeOverride;

  const CricPulseApp({
    super.key,
    this.homeOverride,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<FirestoreService>(create: (_) => FirestoreService()),
        ChangeNotifierProvider<CricketDataService>(create: (_) => CricketDataService()),
        ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider2<FirestoreService, CricketDataService, MatchProvider>(
          create: (ctx) => MatchProvider(
            firestoreService: ctx.read<FirestoreService>(),
            dataService: ctx.read<CricketDataService>(),
          ),
          update: (_, firestore, data, prev) =>
              prev ?? MatchProvider(firestoreService: firestore, dataService: data),
        ),
        ChangeNotifierProxyProvider<FirestoreService, ScoreProvider>(
          create: (ctx) => ScoreProvider(
            firestoreService: ctx.read<FirestoreService>(),
          ),
          update: (_, firestore, prev) =>
              prev ?? ScoreProvider(firestoreService: firestore),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'CricPulse Live',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: homeOverride ??
                (auth.isAuthenticated
                    ? (auth.isAdmin ? const AdminDashboardScreen() : const AudienceHomeScreen())
                    : const LoginScreen()),
          );
        },
      ),
    );
  }
}
