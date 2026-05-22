import 'package:flutter/material.dart';
import 'package:bmi_tracker/app/theme/app_colors.dart';

class BmiCategoryBadge extends StatelessWidget {
  const BmiCategoryBadge({super.key, required this.category});

  final String category;

  @override
  Widget build(BuildContext context) {
    final Color color = _colorForCategory(category);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(
        category,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'underweight':
        return AppColors.underweightColor;
      case 'normal':
        return AppColors.normalColor;
      case 'overweight':
        return AppColors.overweightColor;
      case 'obese':
        return AppColors.obeseColor;
      default:
        return AppColors.primaryBlue;
    }
  }
}
