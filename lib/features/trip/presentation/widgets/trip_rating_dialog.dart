import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/primary_button.dart';

/// Dialog for rating a completed trip.
Future<Map<String, dynamic>?> showTripRatingDialog(
  BuildContext context, {
  int defaultRatedUserId = 0,
}) {
  return showDialog<Map<String, dynamic>>(
    context: context,
    barrierDismissible: false,
    builder: (_) => TripRatingDialog(defaultRatedUserId: defaultRatedUserId),
  );
}

class TripRatingDialog extends StatefulWidget {
  const TripRatingDialog({
    super.key,
    this.defaultRatedUserId = 0,
  });

  final int defaultRatedUserId;

  @override
  State<TripRatingDialog> createState() => _TripRatingDialogState();
}

class _TripRatingDialogState extends State<TripRatingDialog> {
  int _rating = 5;
  final _commentController = TextEditingController();
  final _ratedUserIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _ratedUserIdController.text = widget.defaultRatedUserId.toString();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _ratedUserIdController.dispose();
    super.dispose();
  }

  void _submit() {
    final ratedUserId = int.tryParse(_ratedUserIdController.text.trim()) ?? 0;
    Navigator.of(context).pop({
      'ratedUserId': ratedUserId,
      'ratingValue': _rating,
      'comment': _commentController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        'تقييم الرحلة',
        style: AppTextStyles.onboardingTitle(color: AppColors.primaryBlue)
            .copyWith(fontSize: 20),
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'كيف كانت تجربتك؟',
              style: AppTextStyles.onboardingSubtitle(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating ? Icons.star : Icons.star_border,
                    color: AppColors.badgeYellow,
                    size: 32,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _ratedUserIdController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                labelText: 'معرف السائق',
                filled: true,
                fillColor: AppColors.searchBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              textAlign: TextAlign.right,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'تعليق (اختياري)',
                filled: true,
                fillColor: AppColors.searchBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('لاحقاً', style: AppTextStyles.skipButton()),
        ),
        SizedBox(
          width: 140,
          child: PrimaryButton(label: 'إرسال', onPressed: _submit),
        ),
      ],
    );
  }
}
