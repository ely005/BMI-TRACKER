import 'package:bmi_tracker/core/helpers/bmi_helper.dart';
import 'package:bmi_tracker/features/bmi/data/models/bmi_record_model.dart';
import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/repositories/bmi_data_source.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/create_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/update_bmi_request.dart';

class MockBmiService implements BmiDataSource {
  final List<BmiRecordModel> _mockRecords = [];

  MockBmiService() {
    _initializeMockData();
  }

  void _initializeMockData() {
    final now = DateTime.now();

    // 1. Normal BMI record
    _mockRecords.add(
      BmiRecordModel(
        id: 'mock-1',
        userId: 'mock-user-1',
        heightCm: 175,
        weightKg: 70,
        bmiValue: BmiHelper.calculateBmi(70, 175),
        category: BmiHelper.getBmiCategory(BmiHelper.calculateBmi(70, 175)),
        notes: 'Morning check - feeling healthy',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
    );

    // 2. Underweight BMI record
    _mockRecords.add(
      BmiRecordModel(
        id: 'mock-2',
        userId: 'mock-user-1',
        heightCm: 180,
        weightKg: 55,
        bmiValue: BmiHelper.calculateBmi(55, 180),
        category: BmiHelper.getBmiCategory(BmiHelper.calculateBmi(55, 180)),
        notes: 'Need to gain weight',
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
    );

    // 3. Overweight BMI record
    _mockRecords.add(
      BmiRecordModel(
        id: 'mock-3',
        userId: 'mock-user-1',
        heightCm: 170,
        weightKg: 78,
        bmiValue: BmiHelper.calculateBmi(78, 170),
        category: BmiHelper.getBmiCategory(BmiHelper.calculateBmi(78, 170)),
        notes: 'Working on fitness goals',
        createdAt: now.subtract(const Duration(days: 30)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
    );

    // 4. Obese BMI record
    _mockRecords.add(
      BmiRecordModel(
        id: 'mock-4',
        userId: 'mock-user-1',
        heightCm: 165,
        weightKg: 95,
        bmiValue: BmiHelper.calculateBmi(95, 165),
        category: BmiHelper.getBmiCategory(BmiHelper.calculateBmi(95, 165)),
        notes: 'Doctor consultation needed',
        createdAt: now.subtract(const Duration(days: 45)),
        updatedAt: now.subtract(const Duration(days: 45)),
      ),
    );

    // 5. Latest BMI record (most recent)
    _mockRecords.add(
      BmiRecordModel(
        id: 'mock-5',
        userId: 'mock-user-1',
        heightCm: 175,
        weightKg: 82,
        bmiValue: BmiHelper.calculateBmi(82, 175),
        category: BmiHelper.getBmiCategory(BmiHelper.calculateBmi(82, 175)),
        notes: 'Latest measurement',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
    );
  }

  @override
  Future<List<BmiRecordEntity>> getRecords() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockRecords);
  }

  @override
  Future<BmiRecordEntity> getRecordDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final record = _mockRecords.firstWhere(
      (r) => r.id == id,
      orElse: () => throw Exception('Record not found'),
    );
    return record;
  }

  @override
  Future<BmiRecordEntity> createRecord(CreateBmiRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final now = DateTime.now();
    final newRecord = BmiRecordModel(
      id: 'mock-${now.millisecondsSinceEpoch}',
      userId: 'mock-user-1',
      heightCm: request.heightCm,
      weightKg: request.weightKg,
      bmiValue: request.bmiValue,
      category: request.category,
      notes: request.notes,
      createdAt: now,
      updatedAt: now,
    );

    _mockRecords.insert(0, newRecord);
    return newRecord;
  }

  @override
  Future<BmiRecordEntity> updateRecord(UpdateBmiRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockRecords.indexWhere((r) => r.id == request.id);
    if (index == -1) {
      throw Exception('Record not found');
    }

    final updatedRecord = BmiRecordModel(
      id: request.id,
      userId: _mockRecords[index].userId,
      heightCm: request.heightCm,
      weightKg: request.weightKg,
      bmiValue: request.bmiValue,
      category: request.category,
      notes: request.notes,
      createdAt: _mockRecords[index].createdAt,
      updatedAt: DateTime.now(),
    );

    _mockRecords[index] = updatedRecord;
    return updatedRecord;
  }

  @override
  Future<void> deleteRecord(DeleteBmiRequest request) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _mockRecords.indexWhere((r) => r.id == request.id);
    if (index == -1) {
      throw Exception('Record not found');
    }
    _mockRecords.removeAt(index);
  }
}
