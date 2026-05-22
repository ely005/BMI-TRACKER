import 'package:flutter/material.dart';
import 'package:bmi_tracker/features/bmi/domain/entities/bmi_record_entity.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/create_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/delete_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/requests/update_bmi_request.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/create_bmi_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/delete_bmi_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/get_bmi_record_detail_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/get_bmi_records_usecase.dart';
import 'package:bmi_tracker/features/bmi/domain/usecases/update_bmi_usecase.dart';

class BmiController extends ChangeNotifier {
  BmiController({
    required GetBmiRecordsUseCase getBmiRecordsUseCase,
    required GetBmiRecordDetailUseCase getBmiRecordDetailUseCase,
    required CreateBmiUseCase createBmiUseCase,
    required UpdateBmiUseCase updateBmiUseCase,
    required DeleteBmiUseCase deleteBmiUseCase,
  }) : _getBmiRecordsUseCase = getBmiRecordsUseCase,
       _getBmiRecordDetailUseCase = getBmiRecordDetailUseCase,
       _createBmiUseCase = createBmiUseCase,
       _updateBmiUseCase = updateBmiUseCase,
       _deleteBmiUseCase = deleteBmiUseCase;

  final GetBmiRecordsUseCase _getBmiRecordsUseCase;
  final GetBmiRecordDetailUseCase _getBmiRecordDetailUseCase;
  final CreateBmiUseCase _createBmiUseCase;
  final UpdateBmiUseCase _updateBmiUseCase;
  final DeleteBmiUseCase _deleteBmiUseCase;

  List<BmiRecordEntity> records = <BmiRecordEntity>[];
  BmiRecordEntity? selectedRecord;
  bool isLoading = false;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> fetchRecords() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      records = await _getBmiRecordsUseCase();
    } catch (e) {
      errorMessage = _readableError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecordDetail(String id) async {
    if (id.trim().isEmpty) {
      errorMessage = 'Record id is required';
      notifyListeners();
      return;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      selectedRecord = await _getBmiRecordDetailUseCase(id);
    } catch (e) {
      errorMessage = _readableError(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRecord(CreateBmiRequest request) async {
    final String? validationError = request.validate();
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final BmiRecordEntity created = await _createBmiUseCase(request);
      records = <BmiRecordEntity>[created, ...records];
      selectedRecord = created;
      return true;
    } catch (e) {
      errorMessage = _readableError(e);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> updateRecord(UpdateBmiRequest request) async {
    final String? validationError = request.validate();
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final BmiRecordEntity updated = await _updateBmiUseCase(request);
      records = records
          .map((BmiRecordEntity item) => item.id == updated.id ? updated : item)
          .toList();
      if (selectedRecord?.id == updated.id) {
        selectedRecord = updated;
      }
      return true;
    } catch (e) {
      errorMessage = _readableError(e);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRecord(DeleteBmiRequest request) async {
    final String? validationError = request.validate();
    if (validationError != null) {
      errorMessage = validationError;
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _deleteBmiUseCase(request);
      records = records
          .where((BmiRecordEntity item) => item.id != request.id)
          .toList();
      if (selectedRecord?.id == request.id) {
        selectedRecord = null;
      }
      return true;
    } catch (e) {
      errorMessage = _readableError(e);
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  void clearSelectedRecord() {
    selectedRecord = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  String _readableError(Object error) {
    final String message = error.toString();
    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }
    return message;
  }
}
