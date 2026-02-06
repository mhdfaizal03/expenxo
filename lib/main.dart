import 'package:expenxo/firebase_options.dart';
import 'package:expenxo/services/auth_service.dart';
import 'package:expenxo/services/firestore_service.dart';
import 'package:expenxo/utils/constands/colors.dart';
import 'package:expenxo/providers/preferences_provider.dart';
import 'package:expenxo/providers/ai_provider.dart';
import 'package:expenxo/services/notification_service.dart';
import 'package:expenxo/view/auth/splash_screen.dart';
import 'package:expenxo/services/sms_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final NotificationService _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cancel any pending inactivity notification when app starts/resumes
    _notificationService.cancelNotification(888);
    // Initialize SMS Listening (will request permissions)
    SmsService().init();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App provided to background - Schedule inactivity reminder
      _notificationService.scheduleNotification(
        id: 888,
        title: "We miss you!",
        body:
            "You haven't checked your budget in a while. Come back to stay on track!",
        scheduledDate: DateTime.now().add(const Duration(days: 1)),
      );
    } else if (state == AppLifecycleState.resumed) {
      // App came to foreground - Cancel reminder
      _notificationService.cancelNotification(888);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProvider(create: (_) => PreferencesProvider()),
        ChangeNotifierProxyProvider<FirestoreService, AIProvider>(
          create: (context) =>
              AIProvider(Provider.of<FirestoreService>(context, listen: false)),
          update: (context, firestore, previous) =>
              previous ?? AIProvider(firestore),
        ),
      ],
      child: Consumer<PreferencesProvider>(
        builder: (context, prefs, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Expenxo',
            themeMode: prefs.themeMode,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: AppColors.scaffoldLight,
              cardColor: AppColors.cardLight,
              dividerColor: AppColors.dividerLight,
              primaryColor: AppColors.mainColor,
              colorScheme: ColorScheme.light(
                primary: AppColors.mainColor,
                secondary: AppColors.secondaryColor,
                surface: AppColors.cardLight,
                error: AppColors.error,
              ),
              iconTheme: const IconThemeData(color: AppColors.iconLight),
              textTheme: GoogleFonts.poppinsTextTheme().apply(
                bodyColor: AppColors.textPrimaryLight,
                displayColor: AppColors.textPrimaryLight,
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.scaffoldLight,
                elevation: 0,
                iconTheme: IconThemeData(color: AppColors.iconLight),
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimaryLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.scaffoldDark,
              cardColor: AppColors.cardDark,
              dividerColor: AppColors.dividerDark,
              primaryColor: AppColors.mainColor,
              colorScheme: ColorScheme.dark(
                primary: AppColors.mainColor,
                secondary: AppColors.secondaryColor,
                surface: AppColors.cardDark,
                error: AppColors.error,
              ),
              iconTheme: const IconThemeData(color: AppColors.iconDark),
              textTheme:
                  GoogleFonts.poppinsTextTheme(
                    ThemeData.dark().textTheme,
                  ).apply(
                    bodyColor: AppColors.textPrimaryDark,
                    displayColor: AppColors.textPrimaryDark,
                  ),
              appBarTheme: const AppBarTheme(
                backgroundColor: AppColors.scaffoldDark,
                elevation: 0,
                iconTheme: IconThemeData(color: AppColors.iconDark),
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
