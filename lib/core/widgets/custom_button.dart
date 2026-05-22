import 'package:flutter/material.dart';
import 'package:bmi_tracker/app/theme/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outline = false,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outline;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isEffectivelyEnabled = enabled && !isLoading && onPressed != null;

    return SizedBox(
      width: double.infinity,
      child: outline
          ? OutlinedButton(
              onPressed: isEffectivelyEnabled ? onPressed : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: isEffectivelyEnabled
                    ? AppColors.primaryBlue
                    : AppColors.mutedGray,
                side: BorderSide(
                  color: isEffectivelyEnabled
                      ? AppColors.primaryBlue
                      : AppColors.borderLight,
                  width: 1.5,
                ),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.primaryBlue,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20),
                          const SizedBox(width: 12),
                        ],
                        Text(label),
                      ],
                    ),
            )
          : ElevatedButton(
              onPressed: isEffectivelyEnabled ? onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: isEffectivelyEnabled
                    ? AppColors.primaryBlue
                    : AppColors.mutedGray,
                foregroundColor: AppColors.textLight,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: isEffectivelyEnabled ? 2 : 0,
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.textLight,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20),
                          const SizedBox(width: 12),
                        ],
                        Text(label),
                      ],
                    ),
            ),
    );
  }
}
