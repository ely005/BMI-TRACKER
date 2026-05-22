import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_tracker/app/routes/route_names.dart';
import 'package:bmi_tracker/core/config/env_config.dart';
import 'package:bmi_tracker/core/helpers/bmi_helper.dart';
import 'package:bmi_tracker/core/widgets/empty_state_widget.dart';
import 'package:bmi_tracker/core/widgets/loading_widget.dart';
import 'package:bmi_tracker/core/widgets/section_header.dart';
import 'package:bmi_tracker/features/auth/presentation/controllers/auth_controller.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/presentation/controllers/bmi_controller.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_record_card.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_result_card.dart';

class BmiDashboardPage extends StatefulWidget {
  const BmiDashboardPage({super.key});

  @override
  State<BmiDashboardPage> createState() => _BmiDashboardPageState();
}

class _BmiDashboardPageState extends State<BmiDashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BmiController>().fetchRecords();
    });
  }

  Future<void> _onLogout() async {
    await context.read<AuthController>().logout();
    if (!mounted) {
      return;
    }
    if (!mounted) return;
    context.go(RouteNames.login);
  }

  Future<void> _onRefresh() async {
    await context.read<BmiController>().fetchRecords();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Tracker'),
        actions: <Widget>[
          IconButton(
            onPressed: _onLogout,
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer<BmiController>(
        builder: (BuildContext context, BmiController controller, _) {
          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: controller.isLoading
                ? const LoadingWidget(message: 'Loading your BMI data...')
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
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.error,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.bmiForm),
        label: const Text('Add BMI'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildContent(BuildContext context, BmiController controller) {
    final ThemeData theme = Theme.of(context);
    final records = controller.records;
    final latest = records.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Greeting section
        _buildGreetingSection(context),
        const SizedBox(height: 24),
        // Latest BMI card
        BmiResultCard(
          bmiValue: latest.bmiValue,
          category: latest.category,
          message: BmiHelper.getBmiMessage(latest.bmiValue),
          height: latest.heightCm,
          weight: latest.weightKg,
        ),
        const SizedBox(height: 24),
        // Recent records section
        SectionHeader(
          title: 'Recent Records',
          onSeeAll: () => context.push(RouteNames.bmiHistory),
        ),
        const SizedBox(height: 12),
        // Records list
        ...records
            .take(5)
            .map(
              (record) => BmiRecordCard(
                record: record,
                onTap: () =>
                    context.push(RouteNames.bmiDetail, extra: record.id),
                onEdit: () => context.push(RouteNames.bmiForm, extra: record),
                onDelete: () => _onDeleteRecord(context, controller, record.id),
              ),
            ),
        // Show "See all" button if there are more than 5 records
        if (records.length > 5) ...[
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.push(RouteNames.bmiHistory),
              child: const Text('See All Records'),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGreetingSection(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Consumer<AuthController>(
      builder: (context, authController, _) {
        final String userName = authController.userName ?? 'there';
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Hi, $userName',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (EnvConfig.useMockData) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Mock data mode',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Here is your latest BMI overview.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      },
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
