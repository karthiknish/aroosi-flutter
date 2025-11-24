import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:aroosi_flutter/features/auth/auth_controller.dart';
import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/widgets/animations/motion.dart';
import 'package:aroosi_flutter/widgets/brand/aurora_background.dart';
import 'package:aroosi_flutter/theme/colors.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';

import 'package:aroosi_flutter/theme/theme_helpers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Defer navigation to next frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = ref.read(authControllerProvider);
      if (!mounted) return;
      context.go(auth.isAuthenticated ? '/dashboard' : '/startup');
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    return AppScaffold(
      title: 'Splash',
      usePadding: false,
      showNavBar: false,
      child: AuroraBackground(
        enableTexture: true,
        child: Center(
          child: FadeScaleIn(
            duration: AppMotionDurations.slow,
            beginScale: 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FlutterLogo(size: 96),
                const SizedBox(height: 16),
                Text(
                  'Aroosi',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
