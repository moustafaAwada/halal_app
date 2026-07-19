import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/pin_code_input.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordResetPage extends StatefulWidget {
  const ForgotPasswordResetPage({super.key, required this.email});

  final String email;

  @override
  State<ForgotPasswordResetPage> createState() =>
      _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState extends State<ForgotPasswordResetPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ForgotPasswordCubit>().resetPassword(
          email: _emailController.text,
          password: _passwordController.text,
          code: _codeController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordError) {
          SnackbarUtils.showErrorSnackBar(context, state.message);
        } else if (state is ForgotPasswordResetSuccess) {
          AppRouter.goToLogin(
            context,
            successMessage: 'تم تعيين كلمة المرور بنجاح',
          );
        }
      },
      child: AuthScaffold(
        title: 'تعيين كلمة المرور',
        subtitle: 'أدخل رمز التحقق وكلمة المرور الجديدة',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'البريد الإلكتروني',
                controller: _emailController,
                readOnly: true,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'كلمة المرور الجديدة',
                controller: _passwordController,
                obscureText: true,
                textInputAction: TextInputAction.next,
                validator: Validators.password,
              ),
              const SizedBox(height: 24),
              Text(
                'رمز التحقق',
                textAlign: TextAlign.right,
                style: AppTextStyles.onboardingSubtitle(),
              ),
              const SizedBox(height: 12),
              PinCodeInput(
                controller: _codeController,
                validator: Validators.pinCode,
              ),
              const SizedBox(height: 24),
              BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'تعيين كلمة المرور',
                    isLoading: state is ForgotPasswordLoading,
                    onPressed: _submit,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
