import 'package:flutter/cupertino.dart';

import 'package:aroosi_flutter/theme/theme.dart';
import 'package:aroosi_flutter/widgets/email_verification_banner.dart';
import 'package:aroosi_flutter/widgets/brand/aurora_background.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool usePadding;
  final bool showNavBar;

  const AppScaffold({
    super.key,
    required this.title,
    required this.child,
    this.leading,
    this.actions,
    this.floatingActionButton,
    this.usePadding = true,
    this.showNavBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return AuroraBackground(
      enableTexture: true,
      child: CupertinoPageScaffold(
        backgroundColor: AppColors.background,
        navigationBar: showNavBar
            ? CupertinoNavigationBar(
                backgroundColor: AppColors.background.withValues(alpha: 0.9),
                border: null,
                middle: _CupertinoAppBarTitle(title: title),
                leading: leading,
                trailing: actions != null && actions!.isNotEmpty
                    ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
                    : null,
              )
            : null,
        child: Stack(
          children: [
            SafeArea(
              top: false,
              child: Padding(
                padding: usePadding
                    ? const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        Spacing.lg,
                        Spacing.lg,
                        Spacing.lg + 8,
                      )
                    : EdgeInsets.zero,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (usePadding) const EmailVerificationBanner(),
                    if (usePadding) const SizedBox(height: Spacing.lg),
                    Expanded(child: child),
                  ],
                ),
              ),
            ),
            if (floatingActionButton != null)
              Positioned(
                bottom: 16,
                right: 16,
                child: floatingActionButton!,
              ),
          ],
        ),
      ),
    );
  }
}

class _CupertinoAppBarTitle extends StatelessWidget {
  const _CupertinoAppBarTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.h3.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Curated by Aroosi',
          style: AppTypography.caption.copyWith(
            color: AppColors.muted,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
