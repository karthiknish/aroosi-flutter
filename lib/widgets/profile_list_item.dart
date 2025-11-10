import 'package:flutter/material.dart';
import 'package:aroosi_flutter/widgets/shimmer.dart';

import 'package:aroosi_flutter/features/profiles/models.dart';
import 'package:aroosi_flutter/theme/theme_helpers.dart';

class ProfileListItem extends StatelessWidget {
  const ProfileListItem({
    super.key,
    required this.profile,
    this.onTap,
    this.onLongPress,
    this.trailing,
    this.compatibilityScore,
  });

  final ProfileSummary profile;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Widget? trailing;
  final int? compatibilityScore;

  static const _placeholderAsset = 'assets/images/placeholder.png';

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final subtitle = [
      if (profile.city != null && profile.city!.isNotEmpty) profile.city!,
      if (profile.age != null) '${profile.age}',
    ].join(' • ');

    final hasAvatar =
        profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty;
    final avatar = hasAvatar
        ? FadeInImage.assetNetwork(
            placeholder: _placeholderAsset,
            image: profile.avatarUrl!,
            fit: BoxFit.cover,
            imageErrorBuilder: (_, __, ___) =>
                Image.asset(_placeholderAsset, fit: BoxFit.cover),
          )
        : Image.asset(_placeholderAsset, fit: BoxFit.cover);

    final resolvedTrailing = trailing ??
        ((compatibilityScore ?? profile.compatibilityScore) > 0
            ? _CompatibilityChip(score: compatibilityScore ?? profile.compatibilityScore)
            : null);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: SizedBox(width: 48, height: 48, child: ClipOval(child: avatar)),
      title: Text(profile.displayName, style: theme.textTheme.bodyLarge),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: resolvedTrailing,
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class ProfileListSkeleton extends StatelessWidget {
  const ProfileListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeHelpers.getMaterialTheme(context).brightness == Brightness.dark
        ? Colors.grey.shade800
        : Colors.grey.shade300;
    final hilite = ThemeHelpers.getMaterialTheme(context).brightness == Brightness.dark
        ? Colors.grey.shade700
        : Colors.grey.shade200;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Shimmer(
        baseColor: base,
        highlightColor: hilite,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: base, shape: BoxShape.circle),
          ),
          title: Container(height: 14, width: 180, color: base),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Container(height: 12, width: 140, color: hilite),
          ),
        ),
      ),
    );
  }
}

class _CompatibilityChip extends StatelessWidget {
  const _CompatibilityChip({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = ThemeHelpers.getMaterialTheme(context);
    final color = score >= 75
        ? Colors.green
        : score >= 50
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        '$score% match',
        style: theme.textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
