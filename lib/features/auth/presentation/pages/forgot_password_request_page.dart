import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/forgot_password_cubit.dart';

class ForgotPasswordRequestPage extends StatefulWidget {
  const ForgotPasswordRequestPage({super.key});

  @override
  State<ForgotPasswordRequestPage> createState() =>
      _ForgotPasswordRequestPageState();
}

class _ForgotPasswordRequestPageState extends State<ForgotPasswordRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<ForgotPasswordCubit>().sendCode(
          email: _emailController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state is ForgotPasswordError) {
          SnackbarUtils.showErrorSnackBar(context, state.message);
        } else if (state is ForgotPasswordCodeSent) {
          AppRouter.goToForgotPasswordReset(context, email: state.email);
        }
      },
      child: AuthScaffold(
        title: 'نسيت كلمة المرور',
        subtitle: 'أدخل بريدك الإلكتروني لإرسال رمز التحقق',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'البريد الإلكتروني',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: Validators.email,
              ),
              const SizedBox(height: 24),
              BlocBuilder<ForgotPasswordCubit, ForgotPasswordState>(
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'إرسال رمز التحقق',
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
