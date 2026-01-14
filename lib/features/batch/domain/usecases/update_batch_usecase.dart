import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/core/error/failures.dart';
import 'package:lost_n_found/core/usecases/app_usecase.dart';
import 'package:lost_n_found/features/batch/data/repositories/batch_repositories.dart';
import 'package:lost_n_found/features/batch/domain/entities/batch_entity.dart';
import 'package:lost_n_found/features/batch/domain/repositories/batch_repository.dart';

class UpdateBatchUsecaseParams extends Equatable {
  final String batchName;
  final String batchId;
  final String? status;

  const UpdateBatchUsecaseParams({
    required this.batchName,
    required this.batchId,
    this.status,
  });

  @override
  List<Object?> get props => [batchName, batchId, status];
}

final updateBatchUsecaseProvider = Provider<UpdateBatchUsecase>((ref) {
  final batchRepository = ref.read(batchRepositoryProvider);
  return UpdateBatchUsecase(batchRepository: batchRepository);
});

class UpdateBatchUsecase
    implements UsecaseWithParams<bool, UpdateBatchUsecaseParams> {
  final IBatchRepository _batchRepository;

  UpdateBatchUsecase({required IBatchRepository batchRepository})
    : _batchRepository = batchRepository;

  @override
  Future<Either<Failure, bool>> call(UpdateBatchUsecaseParams params) {
    BatchEntity batchEntity = BatchEntity(
      batchName: params.batchName.toLowerCase(),
      batchId: params.batchId,
      status: params.status,
    );

    return _batchRepository.updateBatch(batchEntity);
  }
}
