import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_tracker/app/routes/route_names.dart';
import 'package:bmi_tracker/core/helpers/bmi_helper.dart';
import 'package:bmi_tracker/core/widgets/loading_widget.dart';
import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/presentation/controllers/bmi_controller.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_category_badge.dart';
import 'package:bmi_tracker/core/widgets/custom_button.dart';

class BmiDetailPage extends StatefulWidget {
  const BmiDetailPage({super.key, this.recordId});

  final String? recordId;

  @override
  State<BmiDetailPage> createState() => _BmiDetailPageState();
}

class _BmiDetailPageState extends State<BmiDetailPage> {
  @override
  void initState() {
    super.initState();
    final String? id = widget.recordId;
    if (id != null && id.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BmiController>().fetchRecordDetail(id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BmiController controller = context.watch<BmiController>();
    final record = controller.selectedRecord;

    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Details'),
        elevation: 0,
        // Add edit button if we have a record and editing is supported
        actions: [
          if (record != null) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit Record',
              onPressed: () {
                // Navigate to edit form with existing record data
                context.push(RouteNames.bmiForm, extra: record);
              },
            ),
          ],
        ],
      ),
      body: controller.isLoading
          ? const LoadingWidget(message: 'Loading record details...')
          : controller.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage!,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Retry fetching the record
                        if (widget.recordId != null) {
                          context.read<BmiController>().fetchRecordDetail(
                            widget.recordId!,
                          );
                        }
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : record == null
          ? const Center(
              child: Text(
                'Record not found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : _buildRecordDetails(context, theme, record),
    );
  }

  Widget _buildRecordDetails(
    BuildContext context,
    ThemeData theme,
    BmiRecordEntity record,
  ) {
    final String createdAtText = record.createdAt == null
        ? 'N/A'
        : '${record.createdAt!.year}-${record.createdAt!.month.toString().padLeft(2, '0')}-${record.createdAt!.day.toString().padLeft(2, '0')}';
    final String updatedAtText = record.updatedAt == null
        ? 'N/A'
        : '${record.updatedAt!.year}-${record.updatedAt!.month.toString().padLeft(2, '0')}-${record.updatedAt!.day.toString().padLeft(2, '0')}';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main BMI result section
          Center(
            child: Column(
              children: [
                Text(
                  record.bmiValue.toStringAsFixed(1),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                BmiCategoryBadge(category: record.category),
                const SizedBox(height: 16),
                Text(
                  BmiHelper.getBmiMessage(record.bmiValue),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Details section
          Text(
            'Record Details',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.height_outlined,
            'Height',
            '${record.heightCm.toStringAsFixed(0)} cm',
            theme,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.line_weight_outlined,
            'Weight',
            '${record.weightKg.toStringAsFixed(0)} kg',
            theme,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_today_outlined,
            'Date',
            createdAtText,
            theme,
          ),
          const SizedBox(height: 12),
          if (record.updatedAt != null) ...[
            _buildDetailRow(
              Icons.update_outlined,
              'Last Updated',
              updatedAtText,
              theme,
            ),
            const SizedBox(height: 12),
          ],
          if (record.notes != null && record.notes!.isNotEmpty) ...[
            const Divider(height: 32),
            Text(
              'Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(record.notes!, style: theme.textTheme.bodyMedium),
            ),
          ],
          const SizedBox(height: 32),
          // Action buttons
          if (record.id != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Navigate to edit form
                  context.push(RouteNames.bmiForm, extra: record);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Record'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _onDeletePressed(context),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete Record'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(color: theme.colorScheme.error),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDeletePressed(BuildContext context) async {
    final bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Record'),
          content: const Text(
            'Are you sure you want to delete this BMI record? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true && mounted) {
      final BmiController controller = context.read<BmiController>();
      await controller.deleteRecord(DeleteBmiRequest(id: widget.recordId!));
      if (!mounted) return;
      context.pop(); // Go back to previous screen
    }
  }
}
