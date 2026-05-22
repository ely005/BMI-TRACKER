import 'package:flutter/material.dart';
import 'package:bmi_tracker/app/theme/app_colors.dart';
import 'package:bmi_tracker/core/widgets/custom_card.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_category_badge.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_input_form.dart';

class BmiResultCard extends StatelessWidget {
  const BmiResultCard({
    super.key,
    required this.bmiValue,
    required this.category,
    required this.message,
    this.height,
    this.weight,
    this.showProgressIndicator = true,
  });

  final double bmiValue;
  final String category;
  final String message;
  final double? height; // in cm
  final double? weight; // in kg
  final bool showProgressIndicator;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          // BMI value and category
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                bmiValue.toStringAsFixed(1),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              BmiCategoryBadge(category: category),
            ],
          ),
          const SizedBox(height: 16),
          // Optional progress indicator
          if (showProgressIndicator) ...[
            SizedBox(
              height: 4,
              child: LinearProgressIndicator(
                value: _calculateProgressValue(),
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _colorForCategory(category),
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Message
          Text(
            message,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          // Height and weight summary if available
          if (height != null && weight != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildMetricColumn(
                  context,
                  'Height',
                  '${height!.toStringAsFixed(0)} cm',
                ),
                const SizedBox(width: 24),
                _buildMetricColumn(
                  context,
                  'Weight',
                  '${weight!.toStringAsFixed(0)} kg',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricColumn(BuildContext context, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  double _calculateProgressValue() {
    // Map BMI value to a 0-1 range for visualization
    // Underweight: <18.5 -> 0-0.3
    // Normal: 18.5-24.9 -> 0.3-0.7
    // Overweight: 25-29.9 -> 0.7-0.9
    // Obese: >=30 -> 0.9-1.0
    if (bmiValue < 18.5) {
      return bmiValue / 18.5 * 0.3;
    } else if (bmiValue < 25) {
      return 0.3 + ((bmiValue - 18.5) / 6.4) * 0.4;
    } else if (bmiValue < 30) {
      return 0.7 + ((bmiValue - 25) / 4.9) * 0.2;
    } else {
      return 0.9 + ((bmiValue - 30) / 10) * 0.1; // Cap at 1.0 for very high BMI
    }
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
