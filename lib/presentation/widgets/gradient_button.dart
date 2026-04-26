// lib/presentation/widgets/gradient_button.dart
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class GradientButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback onTap;

  const GradientButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: loading
              ? null
              : const LinearGradient(
                  colors: [AppColors.violet, AppColors.violetLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          color: loading ? AppColors.violet.withOpacity(0.5) : null,
          borderRadius: BorderRadius.circular(14),
          boxShadow: loading
              ? null
              : [
                  BoxShadow(
                    color: AppColors.violet.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
        ),
      ),
    );
  }
}