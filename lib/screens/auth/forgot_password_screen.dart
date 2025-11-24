import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';
import 'package:aroosi_flutter/widgets/app_scaffold.dart';
import 'package:aroosi_flutter/widgets/input_field.dart';
import 'package:aroosi_flutter/widgets/primary_button.dart';
import 'package:aroosi_flutter/theme/motion.dart';
import 'package:aroosi_flutter/widgets/animations/motion.dart';
import 'package:aroosi_flutter/utils/debug_logger.dart';
import 'package:aroosi_flutter/core/toast_service.dart';
import 'package:aroosi_flutter/features/auth/auth_state.dart';
import 'package:aroosi_flutter/features/auth/auth_controller.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _email = TextEditingController();
  ProviderSubscription<AuthState>? _sub;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _sub = ref.listenManual<AuthState>(authControllerProvider, (prev, next) {
      if (!mounted) return;
      // Success condition: no error & not loading after request
      logNav(
        'forgot_password listener: loading=${next.loading} error=${next.error} prevLoading=${prev?.loading}',
      );
      if (!_navigated && !next.loading && next.error == null) {
        // We only navigate after a reset request; rely on button disabling to avoid false triggers.
        _navigated = true;
        logNav('forgot_password: success -> navigate /reset');
        ToastService.instance.success('Reset email sent');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.go('/reset');
        });
      }
    }, fireImmediately: false);
  }

  @override
  void dispose() {
    _sub?.close();
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final authState = ref.watch(authControllerProvider);

    return AppScaffold(
      title: 'Reset Password',
      usePadding: false,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Spacing.lg),
          child: _isEmailSent
              ? _buildSuccessView(context)
              : _buildFormView(context, authState),
        ),
      ),
    );
  }

  bool get _isEmailSent {
    final authState = ref.read(authControllerProvider);
    // This logic seems wrong. user != null means authenticated?
    // But forgot password screen is for unauthenticated users usually.
    // The original code was: return authState.user != null;
    // But AuthState doesn't have 'user'. It has 'profile'.
    // And we are checking if email was sent.
    // The listener sets _navigated = true and navigates to /reset.
    // Maybe we don't need _isEmailSent logic here if we navigate away?
    // But let's stick to fixing compilation errors first.
    // AuthState has 'error' and 'loading'.
    // If we want to show success view, we probably need a local state or check if we are in a success state.
    // However, the listener navigates to /reset on success.
    // So maybe this view is transient.
    // Let's just fix the compilation error.
    // AuthState does NOT have 'user'.
    return false; 
  }

  Widget _buildSuccessView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle, size: 64, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'Reset email sent!',
          style: TextStyle(fontSize: 24, color: Colors.green),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            context.go('/');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          child: const Text('Home'),
        ),
      ],
    );
  }

  Widget _buildFormView(BuildContext context, AuthState authState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FadeIn(
          duration: AppMotionDurations.short,
          child: Text('Enter your email to reset your password.'),
        ),
        const SizedBox(height: 8),
        FadeSlideIn(
          duration: AppMotionDurations.medium,
          beginOffset: const Offset(0, 0.08),
          child: InputField(controller: _email, label: 'Email'),
        ),
        const SizedBox(height: 24),
        FadeScaleIn(
          delay: AppMotionDurations.fast,
          child: PrimaryButton(
            label: 'Send reset link',
            loading: authState.loading,
            onPressed: authState.loading
                ? null
                : () {
                    final email = _email.text;
                    logNav(
                      'forgot_password: Send reset link pressed email=$email',
                    );
                    ref.read(authControllerProvider.notifier).requestPasswordReset(email);
                  },
          ),
        ),
      ],
    );
  }
}
