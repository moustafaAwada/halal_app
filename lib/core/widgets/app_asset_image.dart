import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Displays a local asset with a styled fallback until final art is provided.
class AppAssetImage extends StatelessWidget {
  const AppAssetImage({
    super.key,
    required this.assetPath,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
    this.placeholderIcon,
    this.placeholderLabel,
  });

  final String assetPath;
  final double? height;
  final double? width;
  final BoxFit fit;
  final Alignment alignment;
  final IconData? placeholderIcon;
  final String? placeholderLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: fit,
      alignment: alignment,
      errorBuilder: (_, _, _) => _Placeholder(
        height: height,
        width: width,
        icon: placeholderIcon ?? Icons.image_outlined,
        label: placeholderLabel,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({
    required this.height,
    required this.width,
    required this.icon,
    this.label,
  });

  final double? height;
  final double? width;
  final IconData icon;
  final String? label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.inactiveDot.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.inactiveDot),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 48, color: AppColors.subtitleGrey),
          if (label != null) ...[
            const SizedBox(height: 8),
            Text(
              label!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.subtitleGrey,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
