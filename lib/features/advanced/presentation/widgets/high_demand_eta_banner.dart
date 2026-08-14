import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../cubit/eta_cubit.dart';

/// Orange warning banner when GET /eta reports high demand.
class HighDemandEtaBanner extends StatelessWidget {
  const HighDemandEtaBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EtaCubit, EtaState>(
      builder: (context, state) {
        if (state is! EtaLoaded || !state.info.isHighDemand) {
          return const SizedBox.shrink();
        }

        final info = state.info;
        final message = info.message.isNotEmpty
            ? info.message
            : 'هناك ضغط طلبات حالياً، قد يتأخر طلبك قليلاً';

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.orange.shade300),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade800,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: AppTextStyles.onboardingSubtitle(
                        color: Colors.orange.shade900,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    if (info.etaMinutes > 0) ...[
                      const SizedBox(height: 6),
                      Text(
                        'الوقت المتوقع: ${info.etaMinutes} دقيقة',
                        style: AppTextStyles.skipButton(
                          color: Colors.orange.shade900,
                        ).copyWith(fontSize: 13),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
