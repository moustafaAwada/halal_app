import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/auth_scaffold.dart';
import '../../../../core/widgets/primary_button.dart';
import '../cubit/register_cubit.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<RegisterCubit>().register(
          fullName: _fullNameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          phone: _phoneController.text,
          address: _addressController.text,
          city: _cityController.text,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterError) {
          SnackbarUtils.showErrorSnackBar(context, state.message);
        } else if (state is RegisterSuccess) {
          AppRouter.goToLogin(context, successMessage: 'تم إنشاء الحساب بنجاح');
        }
      },
      child: AuthScaffold(
        title: 'إنشاء حساب',
        subtitle: 'أدخل بياناتك للتسجيل',
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'الاسم الكامل',
                controller: _fullNameController,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.requiredField(v, 'الاسم الكامل'),
              ),
              const SizedBox(height: 16),
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
                textInputAction: TextInputAction.next,
                validator: Validators.password,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'رقم الهاتف',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.requiredField(v, 'رقم الهاتف'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'العنوان',
                controller: _addressController,
                textInputAction: TextInputAction.next,
                validator: (v) => Validators.requiredField(v, 'العنوان'),
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: 'المدينة',
                controller: _cityController,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _submit(),
                validator: (v) => Validators.requiredField(v, 'المدينة'),
              ),
              const SizedBox(height: 24),
              BlocBuilder<RegisterCubit, RegisterState>(
                builder: (context, state) {
                  return PrimaryButton(
                    label: 'إنشاء حساب',
                    isLoading: state is RegisterLoading,
                    onPressed: _submit,
                  );
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'لديك حساب؟ تسجيل الدخول',
                  style: AppTextStyles.skipButton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
