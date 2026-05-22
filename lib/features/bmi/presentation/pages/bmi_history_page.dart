import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_tracker/app/routes/route_names.dart';
import 'package:bmi_tracker/core/widgets/empty_state_widget.dart';
import 'package:bmi_tracker/core/widgets/loading_widget.dart';
import 'package:bmi_tracker/core/widgets/section_header.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/presentation/controllers/bmi_controller.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_record_card.dart';

class BmiHistoryPage extends StatefulWidget {
  const BmiHistoryPage({super.key});

  @override
  State<BmiHistoryPage> createState() => _BmiHistoryPageState();
}

class _BmiHistoryPageState extends State<BmiHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BmiController>().fetchRecords();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<BmiController>().fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI History'),
        elevation: 0,
        // Optional: add a search icon if we want to implement search later
        actions: [
          IconButton(
            icon: const Icon(Icons.search_outlined),
            tooltip: 'Search',
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
        ],
      ),
      body: Consumer<BmiController>(
        builder: (BuildContext context, BmiController controller, _) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: controller.isLoading
                ? const LoadingWidget(message: 'Loading your BMI history...')
                : controller.errorMessage != null && controller.records.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.errorMessage!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: controller.fetchRecords,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : controller.records.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.monitor_weight_outlined,
                    title: 'No BMI records yet',
                    subtitle: 'Start by adding your first BMI record.',
                    buttonLabel: 'Add Record',
                    onButtonPressed: () => context.push(RouteNames.bmiForm),
                  )
                : _buildContent(context, controller),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, BmiController controller) {
    final ThemeData theme = Theme.of(context);
    final records = controller.records;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Section header
        SectionHeader(
          title: 'All Records',
          onSeeAll: null, // No "see all" needed on history page
        ),
        const SizedBox(height: 12),
        // Records list
        ...records.map(
          (record) => BmiRecordCard(
            record: record,
            onTap: () => context.push(RouteNames.bmiDetail, extra: record.id),
            onEdit: () => context.push(RouteNames.bmiForm, extra: record),
            onDelete: () => _onDeleteRecord(context, controller, record.id),
          ),
        ),
      ],
    );
  }

  Future<void> _onDeleteRecord(
    BuildContext context,
    BmiController controller,
    String recordId,
  ) async {
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
      await controller.deleteRecord(DeleteBmiRequest(id: recordId));
    }
  }
}
