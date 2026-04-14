import 'package:flutter/material.dart';
import 'package:jimpitan_digital/core/constants/app_colors.dart';
import 'package:jimpitan_digital/core/constants/route_names.dart';
import 'package:go_router/go_router.dart';

class JimpitanAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String role;
  final Color roleColor;
  final List<Widget>? actions;

  const JimpitanAppBar({
    super.key,
    required this.title,
    required this.role,
    required this.roleColor,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: roleColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
      actions: [
        ...(actions ?? []),
        IconButton(
          icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondary),
          tooltip: 'Keluar',
          onPressed: () => context.go(RouteNames.login),
        ),
      ],
    );
  }
}
