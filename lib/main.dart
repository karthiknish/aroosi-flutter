
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'utils/globalkey_error_handler.dart';
import 'core/offline_service.dart';
import 'core/offline_queue_interceptor.dart';
import 'core/api_client.dart';
// Theme is configured inside App via buildAppTheme()

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize EasyLocalization
  await EasyLocalization.ensureInitialized();

  // Load saved language preference
  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('selected_language');
  
  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');

  // Initialize Firebase using the same options as aroosi-mobile.
  final platform = defaultTargetPlatform;
  final isMobile =
      !kIsWeb &&
      (platform == TargetPlatform.iOS || platform == TargetPlatform.android);
  if (isMobile) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize Firebase Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    
    // Pass non-fatal errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // Initialize offline service
  await OfflineService().initialize();
  
  // Set up offline queue interceptor
  final offlineInterceptor = OfflineQueueInterceptor();
  ApiClient.dio.interceptors.add(offlineInterceptor);
  
  // Listen for connectivity changes and process queue when online
  OfflineService().connectivityStream.listen((isOnline) {
    if (isOnline) {
      offlineInterceptor.processQueue();
    }
  });

  // Initialize GlobalKey error handler
  GlobalKeyErrorHandler().init();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('fa', 'AF'), // Farsi (Dari)
        Locale('ps', 'AF'), // Pashto
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      startLocale: savedLanguage != null ? Locale(savedLanguage) : null,
      child: const ProviderScope(child: App()),
    ),
  );
}
