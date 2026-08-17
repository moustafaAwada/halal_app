import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/rating_cubit.dart';

Future<void> showRatingModalBottomSheet(
  BuildContext context, {
  required int orderId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider(
      create: (_) => sl<RatingCubit>(),
      child: RatingModalBottomSheet(orderId: orderId),
    ),
  );
}

class RatingModalBottomSheet extends StatefulWidget {
  const RatingModalBottomSheet({
    super.key,
    required this.orderId,
  });

  final int orderId;

  @override
  State<RatingModalBottomSheet> createState() => _RatingModalBottomSheetState();
}

class _RatingModalBottomSheetState extends State<RatingModalBottomSheet> {
  int _orderRating = 5;
  int _deliveryRating = 5;
  final _orderCommentController = TextEditingController();
  final _deliveryCommentController = TextEditingController();

  @override
  void dispose() {
    _orderCommentController.dispose();
    _deliveryCommentController.dispose();
    super.dispose();
  }

  void _submit() {
    context.read<RatingCubit>().submitOrderAndDeliveryRating(
          orderId: widget.orderId,
          orderRating: _orderRating,
          orderComment: _orderCommentController.text,
          deliveryRating: _deliveryRating,
          deliveryComment: _deliveryCommentController.text,
        );
    SnackbarUtils.showSuccessSnackBar(context, 'تم إرسال التقييم بنجاح، شكراً لك!');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<RatingCubit, RatingState>(
        listener: (context, state) {
          if (state is RatingSuccess) {
            SnackbarUtils.showSuccessSnackBar(context, state.message);
            Navigator.of(context).pop();
          } else if (state is RatingError) {
            SnackbarUtils.showErrorSnackBar(context, state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is RatingLoading;

          return Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.inactiveDot,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'قيّم طلبك',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingTitle(
                          color: AppColors.primaryBlue,
                        ).copyWith(fontSize: 22),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'شاركنا رأيك في المطعم والمندوب',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.onboardingSubtitle(),
                      ),
                      const SizedBox(height: 24),
                      _RatingSection(
                        title: 'تقييم المطعم / الطلب',
                        rating: _orderRating,
                        commentController: _orderCommentController,
                        enabled: !isLoading,
                        onRatingChanged: (value) {
                          setState(() => _orderRating = value);
                        },
                      ),
                      const SizedBox(height: 20),
                      _RatingSection(
                        title: 'تقييم المندوب',
                        rating: _deliveryRating,
                        commentController: _deliveryCommentController,
                        enabled: !isLoading,
                        onRatingChanged: (value) {
                          setState(() => _deliveryRating = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        PrimaryButton(
                          label: 'إرسال التقييم',
                          onPressed: _submit,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RatingSection extends StatelessWidget {
  const _RatingSection({
    required this.title,
    required this.rating,
    required this.commentController,
    required this.onRatingChanged,
    required this.enabled,
  });

  final String title;
  final int rating;
  final TextEditingController commentController;
  final ValueChanged<int> onRatingChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.skipButton(color: Colors.black87)
                .copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final star = index + 1;
              return IconButton(
                onPressed: enabled ? () => onRatingChanged(star) : null,
                icon: Icon(
                  star <= rating ? Icons.star : Icons.star_border,
                  color: AppColors.badgeYellow,
                  size: 32,
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: commentController,
            enabled: enabled,
            textAlign: TextAlign.right,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'تعليق (اختياري)',
              filled: true,
              fillColor: AppColors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
