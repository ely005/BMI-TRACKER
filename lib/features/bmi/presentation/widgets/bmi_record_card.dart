import 'package:flutter/material.dart';
import 'package:bmi_tracker/core/widgets/custom_card.dart';
import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_category_badge.dart';

class BmiRecordCard extends StatelessWidget {
  const BmiRecordCard({
    super.key,
    required this.record,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  final BmiRecordEntity record;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final String dateLabel = record.createdAt == null
        ? 'No date'
        : '${record.createdAt!.year}-${record.createdAt!.month.toString().padLeft(2, '0')}-${record.createdAt!.day.toString().padLeft(2, '0')}';

    return CustomCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content row with BMI and category badge
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                // BMI value
                Text(
                  record.bmiValue.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 12),
                // Category badge
                BmiCategoryBadge(category: record.category),
                const Spacer(),
                // Edit and delete icons
                if (onEdit != null || onDelete != null) ...[
                  if (onEdit != null) ...[
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      tooltip: 'Edit',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                  if (onDelete != null) ...[
                    IconButton(
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline, size: 20),
                      tooltip: 'Delete',
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          // Details section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Height and weight
                Row(
                  children: [
                    _buildDetailIcon(context, Icons.height, 'Height'),
                    const SizedBox(width: 8),
                    Text(
                      '${record.heightCm.toStringAsFixed(0)} cm',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 24),
                    _buildDetailIcon(context, Icons.line_weight, 'Weight'),
                    const SizedBox(width: 8),
                    Text(
                      '${record.weightKg.toStringAsFixed(0)} kg',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Date and notes preview
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  Row(
                    children: [
                      _buildDetailIcon(context, Icons.calendar_today, 'Date'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDetailIcon(context, Icons.note_alt, 'Notes'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          record.notes!.length > 50
                              ? '${record.notes!.substring(0, 50)}...'
                              : record.notes!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  Row(
                    children: [
                      _buildDetailIcon(context, Icons.calendar_today, 'Date'),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          dateLabel,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailIcon(BuildContext context, IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
