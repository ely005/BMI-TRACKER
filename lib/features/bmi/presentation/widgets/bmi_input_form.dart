import 'package:flutter/material.dart';
import 'package:bmi_tracker/core/validators/bmi_validator.dart';
import 'package:bmi_tracker/core/widgets/custom_button.dart';
import 'package:bmi_tracker/core/widgets/custom_text_field.dart';
import 'package:bmi_tracker/core/helpers/bmi_helper.dart';
import 'package:bmi_tracker/features/bmi/presentation/widgets/bmi_result_card.dart';

class BmiInputForm extends StatefulWidget {
  const BmiInputForm({
    super.key,
    this.initialHeight,
    this.initialWeight,
    this.initialNotes,
    required this.submitLabel,
    required this.onSubmit,
    this.isSubmitting = false,
  });

  final double? initialHeight;
  final double? initialWeight;
  final String? initialNotes;
  final String submitLabel;
  final Future<void> Function(double height, double weight, String? notes)
  onSubmit;
  final bool isSubmitting;

  @override
  State<BmiInputForm> createState() => _BmiInputFormState();
}

class _BmiInputFormState extends State<BmiInputForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _heightController = TextEditingController(
      text: widget.initialHeight?.toStringAsFixed(1) ?? '',
    );
    _weightController = TextEditingController(
      text: widget.initialWeight?.toStringAsFixed(1) ?? '',
    );
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final double height = double.parse(_heightController.text.trim());
    final double weight = double.parse(_weightController.text.trim());
    final String? notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    await widget.onSubmit(height, weight, notes);
  }

  double? _getHeight() {
    if (_heightController.text.trim().isEmpty) return null;
    return double.tryParse(_heightController.text.trim());
  }

  double? _getWeight() {
    if (_weightController.text.trim().isEmpty) return null;
    return double.tryParse(_weightController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final double? height = _getHeight();
    final double? weight = _getWeight();
    final bool canCalculate =
        height != null && weight != null && height > 0 && weight > 0;
    final double? bmi = canCalculate
        ? BmiHelper.calculateBmi(weight!, height!)
        : null;
    final String? category = bmi != null ? BmiHelper.getBmiCategory(bmi) : null;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _heightController,
            label: 'Height (cm)',
            hint: 'Enter your height',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.height_rounded),
            validator: BMIValidator.validateHeight,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _weightController,
            label: 'Weight (kg)',
            hint: 'Enter your weight',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: const Icon(Icons.monitor_weight_outlined),
            validator: BMIValidator.validateWeight,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _notesController,
            label: 'Notes (optional)',
            hint: 'How did you feel today?',
            prefixIcon: const Icon(Icons.notes_rounded),
          ),
          const SizedBox(height: 24),
          // Live BMI preview
          if (canCalculate) ...[
            BmiResultCard(
              bmiValue: bmi!,
              category: category!,
              message: BmiHelper.getBmiMessage(bmi!),
              height: height,
              weight: weight,
              showProgressIndicator: false, // We'll show a simpler indicator
            ),
            const SizedBox(height: 24),
          ],
          CustomButton(
            label: widget.submitLabel,
            isLoading: widget.isSubmitting,
            icon: Icons.save_outlined,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
