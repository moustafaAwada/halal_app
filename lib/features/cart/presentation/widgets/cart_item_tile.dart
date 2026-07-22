import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/cart_item.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    this.isBusy = false,
  });

  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 84,
              height: 84,
              child: item.menu.image.isEmpty
                  ? Container(color: AppColors.inactiveDot)
                  : CachedNetworkImage(
                      imageUrl: item.menu.image,
                      fit: BoxFit.cover,
                      placeholder: (_, _) =>
                          Container(color: AppColors.inactiveDot),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.inactiveDot,
                        child: const Icon(Icons.fastfood_outlined),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.menu.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.skipButton(color: Colors.black87),
                ),
                if (item.size != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.size!.name,
                    style: AppTextStyles.onboardingSubtitle(
                      color: Colors.black54,
                    ).copyWith(fontSize: 12),
                  ),
                ],
                if (item.addons.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.addons.map((addon) => addon.name).join('، '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.onboardingSubtitle(
                      color: Colors.black54,
                    ).copyWith(fontSize: 12),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  Formatters.formatPrice(item.lineTotal),
                  style: AppTextStyles.skipButton(color: AppColors.primaryBlue),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: isBusy ? null : onDecrease,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        '${item.quantity}',
                        style: AppTextStyles.skipButton(color: Colors.black87),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: isBusy ? null : onIncrease,
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: isBusy ? null : onRemove,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.inactiveDot),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: AppColors.primaryBlue),
      ),
    );
  }
}
