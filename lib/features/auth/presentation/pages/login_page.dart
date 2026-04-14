import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/core/constants/app_strings.dart';
import 'package:jimpitan_digital/core/constants/route_names.dart';
import 'package:jimpitan_digital/shared/enums/user_role.dart';
import 'package:jimpitan_digital/features/auth/presentation/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;

  void _loginAs(UserRole role) {
    ref.read(authProvider.notifier).loginAs(role);
    switch (role) {
      case UserRole.petugas:
        context.go(RouteNames.petugasDashboard);
        break;
      case UserRole.warga:
        context.go(RouteNames.wargaDashboard);
        break;
      case UserRole.bendahara:
        context.go(RouteNames.bendaharaDashboard);
        break;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              _buildHeader(),
              const SizedBox(height: 48),
              _buildForm(),
              const SizedBox(height: 32),
              _buildDevRolePicker(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.account_balance_wallet_rounded,
            color: Colors.white,
            size: 44,
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          AppStrings.appName,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          AppStrings.tagline,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildForm() {
    final inputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    );
    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    );
    final enabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppStrings.email,
            prefixIcon: const Icon(Icons.email_outlined),
            filled: true,
            fillColor: AppColors.surface,
            border: inputBorder,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: AppStrings.password,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscure
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            filled: true,
            fillColor: AppColors.surface,
            border: inputBorder,
            enabledBorder: enabledBorder,
            focusedBorder: focusedBorder,
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            child: const Text(
              AppStrings.forgotPassword,
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: const Text(
              AppStrings.login,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDevRolePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Mode Demo — Pilih Role',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const Expanded(child: Divider()),
        ]),
        const SizedBox(height: 16),
        Row(
          children: [
            _roleBtn(
              UserRole.petugas,
              Icons.directions_walk_rounded,
              AppColors.petugasColor,
              'Ahmad\n(RT01)',
            ),
            const SizedBox(width: 8),
            _roleBtn(
              UserRole.warga,
              Icons.home_rounded,
              AppColors.wargaColor,
              'Budi\n(Warga)',
            ),
            const SizedBox(width: 8),
            _roleBtn(
              UserRole.bendahara,
              Icons.bar_chart_rounded,
              AppColors.bendaharaColor,
              'Hendra\n(Bendahara)',
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleBtn(UserRole role, IconData icon, Color color, String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () => _loginAs(role),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withValues(alpha: 0.4)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
