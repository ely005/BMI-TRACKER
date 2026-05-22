import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/create_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/presentation/controllers/bmi_controller.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_input_form.dart';

class BmiFormPage extends StatelessWidget {
  const BmiFormPage({
    super.key,
    this.initialHeight,
    this.initialWeight,
    this.initialNotes,
  });

  final double? initialHeight;
  final double? initialWeight;
  final String? initialNotes;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final BmiController controller = context.watch<BmiController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add BMI Record'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceVariant.withOpacity(0.5),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  BmiInputForm(
                    initialHeight: initialHeight,
                    initialWeight: initialWeight,
                    initialNotes: initialNotes,
                    submitLabel: 'Save Record',
                    isSubmitting: controller.isSubmitting,
                    onSubmit:
                        (double height, double weight, String? notes) async {
                          final bool success = await context
                              .read<BmiController>()
                              .createRecord(
                                CreateBmiRequest(
                                  heightCm: height,
                                  weightKg: weight,
                                  notes: notes,
                                ),
                              );
                          if (!context.mounted) {
                            return;
                          }
                          if (success) {
                            context.pop();
                          }
                        },
                  ),
                  if (controller.errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      controller.errorMessage!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
