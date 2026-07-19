import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_asset_image.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/login_cubit.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.successMessage});

  final String? successMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SnackbarUtils.showSuccessSnackBar(context, widget.successMessage!);
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<LoginCubit>().login(
          email: _emailController.text,
          password: _passwordController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginError) {
          SnackbarUtils.showErrorSnackBar(context, state.message);
        } else if (state is LoginSuccess) {
          AppRouter.goToHome(context);
        }
      },
      child: AuthScaffold(
        header: const AppAssetImage(
          assetPath: AppAssets.logo,
          height: 140,
          width: 140,
          fit: BoxFit.contain,
          placeholderIcon: Icons.hexagon_outlined,
          placeholderLabel: 'logo.png',
        ),
        title: 'تسجيل الدخول',
        subtitle: 'مرحباً بك مجدداً',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'البريد الإلكتروني',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'كلمة المرور',
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: Validators.password,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: TextButton(
                  onPressed: () => AppRouter.goToForgotPassword(context),
                  child: Text(
                    'نسيت كلمة المرور؟',
                    style: AppTextStyles.skipButton(),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              BlocBuilder<LoginCubit, LoginState>(
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'تسجيل الدخول',
                    isLoading: state is LoginLoading,
                    onPressed: _submit,
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب؟',
                    style: AppTextStyles.onboardingSubtitle(),
                  ),
                  TextButton(
                    onPressed: () => AppRouter.goToRegister(context),
                    child: Text(
                      'إنشاء حساب',
                      style: AppTextStyles.skipButton(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
