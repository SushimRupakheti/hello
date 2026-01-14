import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/features/batch/domain/usecases/create_batch_usecase.dart';
import 'package:lost_n_found/features/batch/domain/usecases/delete_batch_usecase.dart';
import 'package:lost_n_found/features/batch/domain/usecases/get_all_batch_usecase.dart';
import 'package:lost_n_found/features/batch/domain/usecases/get_batch_by_id_usecase.dart';
import 'package:lost_n_found/features/batch/domain/usecases/update_batch_usecase.dart';
import 'package:lost_n_found/features/batch/presentation/state/batch_state.dart';

final batchViewModelProvider = NotifierProvider<BatchViewmodel, BatchState>(
  BatchViewmodel.new,
);

class BatchViewmodel extends Notifier<BatchState> {
  late final GetAllBatchUsecase _getAllBatchUsecase;
  late final CreateBatchUsecase _createBatchUsecase;
  late final UpdateBatchUsecase _updateBatchUsecase;
  late final DeleteBatchUsecase _deleteBatchUsecase;
  late final GetBatchByIdUsecase _getBatchByIdUsecase;

  @override
  BatchState build() {
    _getAllBatchUsecase = ref.read(getAllBatchUsecaseProvider);
    _createBatchUsecase = ref.read(createBatchUsecaseProvider);
    _updateBatchUsecase = ref.read(updateBatchUsecaseProvider);
    _deleteBatchUsecase = ref.read(deleteBatchUsecaseProvider);
    _getBatchByIdUsecase = ref.read(getBatchByIdUsecaseProvider);
    return const BatchState();
  }

  Future<void> getAllBatches() async {
    state = state.copyWith(status: BatchStatus.loading);

    await Future.delayed(Duration(seconds: 2));

    final result = await _getAllBatchUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: BatchStatus.error,
        errorMessage: failure.message,
      ),
      (batches) =>
          state = state.copyWith(status: BatchStatus.loaded, batches: batches),
    );
  }

  Future<void> getBatchById(String batchId) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _getBatchByIdUsecase(
      GetBatchByIdUsecaseParams(batchId: batchId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: BatchStatus.error,
        errorMessage: failure.message,
      ),
      (batch) => state = state.copyWith(status: BatchStatus.loaded),
    );
  }

  Future<void> createBatch(String batchName) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _createBatchUsecase(
      CreateBatchUsecaseParams(batchName: batchName),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: BatchStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: BatchStatus.created);
        getAllBatches();
      },
    );
  }

  Future<void> updateBatch({
    required String batchId,
    required String batchName,
    String? status,
  }) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _updateBatchUsecase(
      UpdateBatchUsecaseParams(
        batchId: batchId,
        batchName: batchName,
        status: status,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: BatchStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: BatchStatus.updated);
        getAllBatches();
      },
    );
  }

  Future<void> deleteBatch(String batchId) async {
    state = state.copyWith(status: BatchStatus.loading);

    final result = await _deleteBatchUsecase(
      DeleteBatchUsecaseParams(batchId: batchId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: BatchStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: BatchStatus.deleted);
        getAllBatches();
      },
    );
  }
}
