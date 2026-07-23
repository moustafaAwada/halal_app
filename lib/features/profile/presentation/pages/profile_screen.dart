import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../auth/domain/usecases/logout_usecase.dart';
import '../../../home/presentation/widgets/home_shimmer.dart';
import '../../domain/entities/user_profile.dart';
import '../cubit/profile_cubit.dart';
import '../widgets/profile_form.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_shimmer.dart';
import '../widgets/profile_stats_row.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final cubit = context.read<ProfileCubit>();
      if (cubit.state is ProfileInitial || cubit.state is ProfileError) {
        cubit.fetchProfile();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _populateForm(UserProfile profile) {
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _addressController.text = profile.address;
    _cityController.text = profile.city;
  }

  void _startEditing(UserProfile profile) {
    _populateForm(profile);
    setState(() => _isEditing = true);
  }

  void _cancelEditing(UserProfile profile) {
    _populateForm(profile);
    FocusScope.of(context).unfocus();
    setState(() => _isEditing = false);
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    context.read<ProfileCubit>().updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await _showLogoutConfirmationDialog();
    if (shouldLogout != true || !mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.25),
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: AppColors.primaryBlue,
              strokeWidth: 3,
            ),
          ),
        ),
      ),
    );

    final result = await sl<LogoutUseCase>()(const NoParams());

    if (!mounted) return;
    Navigator.of(context).pop();

    result.fold(
          (failure) => SnackbarUtils.showErrorSnackBar(context, failure.message),
          (_) => AppRouter.goToLogin(context, successMessage: 'تم تسجيل الخروج بنجاح'),
    );
  }

  Future<bool?> _showLogoutConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 30,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red.shade400,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'تسجيل الخروج',
                  style: AppTextStyles.onboardingTitle(
                    color: Colors.black87,
                  ).copyWith(fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.skipButton(color: Colors.black54).copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(dialogContext).pop(false),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'إلغاء',
                            style: AppTextStyles.primaryButton(
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: FilledButton(
                          onPressed: () => Navigator.of(dialogContext).pop(true),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade400,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            'تسجيل الخروج',
                            style: AppTextStyles.primaryButton(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.searchBackground,
        body: BlocConsumer<ProfileCubit, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdateSuccess) {
              SnackbarUtils.showSuccessSnackBar(context, state.message);
              _populateForm(state.profile);
              setState(() => _isEditing = false);
            } else if (state is ProfileActionError) {
              SnackbarUtils.showErrorSnackBar(context, state.message);
            } else if (state is ProfileLoaded && !_isEditing) {
              _populateForm(state.profile);
            }
          },
          buildWhen: (previous, current) =>
          current is! ProfileUpdateSuccess && current is! ProfileActionError,
          builder: (context, state) {
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) => [
                SliverAppBar(
                  expandedHeight: 96.0,
                  floating: true,
                  pinned: true,
                  centerTitle: false,
                  backgroundColor: AppColors.searchBackground,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  shadowColor: Colors.black.withOpacity(0.06),
                  shape: innerBoxIsScrolled
                      ? const Border(
                    bottom: BorderSide(color: Color(0x14000000), width: 1),
                  )
                      : null,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    title: Text(
                      'حسابي',
                      style: AppTextStyles.onboardingTitle(
                        color: Colors.black87,
                      ).copyWith(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
              body: switch (state) {
                ProfileInitial() || ProfileLoading() => const ProfileShimmer(),
                ProfileError(:final message) => HomeErrorView(
                  message: message,
                  onRetry: () => context.read<ProfileCubit>().retry(),
                ),
                ProfileLoaded(:final profile, :final isUpdating) => _ProfileContent(
                  profile: profile,
                  isUpdating: isUpdating,
                  isEditing: _isEditing,
                  formKey: _formKey,
                  nameController: _nameController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  addressController: _addressController,
                  cityController: _cityController,
                  onEdit: () => _startEditing(profile),
                  onCancelEdit: () => _cancelEditing(profile),
                  onSave: _saveProfile,
                  onLogout: _handleLogout,
                  onRefresh: () => context.read<ProfileCubit>().fetchProfile(),
                ),
                _ => const SizedBox.shrink(),
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({
    required this.profile,
    required this.isUpdating,
    required this.isEditing,
    required this.formKey,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.addressController,
    required this.cityController,
    required this.onEdit,
    required this.onCancelEdit,
    required this.onSave,
    required this.onLogout,
    required this.onRefresh,
  });

  final UserProfile profile;
  final bool isUpdating;
  final bool isEditing;
  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final VoidCallback onEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onSave;
  final VoidCallback onLogout;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primaryBlue,
      onRefresh: onRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header card sits directly on the page background.
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                  child: ProfileHeaderCard(profile: profile),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ProfileStatsRow(
                    ordersCount: profile.ordersCount,
                    favoritesCount: profile.favoritesCount,
                  ),
                ),
                const SizedBox(height: 24),


                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Smooth transition between viewing and editing
                      AnimatedCrossFade(
                        firstChild: _buildDisplayMode(context),
                        secondChild: ProfileForm(
                          formKey: formKey,
                          nameController: nameController,
                          emailController: emailController,
                          phoneController: phoneController,
                          addressController: addressController,
                          cityController: cityController,
                          onSave: onSave,
                          onCancel: onCancelEdit,
                          isUpdating: isUpdating,
                        ),
                        crossFadeState: isEditing
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        duration: const Duration(milliseconds: 260),
                        sizeCurve: Curves.easeOutCubic,
                      ),
                      const SizedBox(height: 20),
                      _buildLogoutButton(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisplayMode(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ProfileInfoCard(profile: profile),
        const SizedBox(height: 16),
        SizedBox(
          height: 54,
          child: FilledButton.icon(
            onPressed: isUpdating ? null : onEdit,
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: Text(
              'تعديل البيانات',
              style: AppTextStyles.primaryButton(),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: AppColors.white,
              elevation: 0,
              shadowColor: AppColors.primaryBlue.withOpacity(0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ).copyWith(
              elevation: const WidgetStatePropertyAll(0),
              overlayColor: WidgetStatePropertyAll(
                Colors.white.withOpacity(0.08),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Material(
      color: Colors.red.shade50.withOpacity(0.6),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onLogout,
        splashColor: Colors.red.shade100,
        highlightColor: Colors.red.shade50,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.shade100, width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded, color: Colors.red, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'تسجيل الخروج',
                  style: AppTextStyles.skipButton(color: Colors.red.shade600).copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.red.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}