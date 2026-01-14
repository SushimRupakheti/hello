import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/core/error/failures.dart';
import 'package:lost_n_found/core/services/connectivity/network_info.dart';
import 'package:lost_n_found/features/batch/data/datasources/batch_datasource.dart';
import 'package:lost_n_found/features/batch/data/datasources/local/batch_local_datasource.dart';
import 'package:lost_n_found/features/batch/data/datasources/remote/batch_remote_datasource.dart';
import 'package:lost_n_found/features/batch/data/models/batch_api_model.dart';
import 'package:lost_n_found/features/batch/data/models/batch_hive_model.dart';
import 'package:lost_n_found/features/batch/domain/entities/batch_entity.dart';
import 'package:lost_n_found/features/batch/domain/repositories/batch_repository.dart';

final batchRepositoryProvider = Provider<IBatchRepository>((ref) {
  final batchLocalDatasource = ref.read(batchLocalDataSourceProvider);
  final batchRemoteDataSource = ref.read(batchRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return BatchRepository(
    batchDatasource: batchLocalDatasource,
    batchRemoteDatasource: batchRemoteDataSource,
    networkInfo: networkInfo,
  );
});

class BatchRepository implements IBatchRepository {
  final IBatchDatasource _batchLocalDataSource;
  final IBatchRemoteDataSource _batchRemoteDataSource;
  final NetworkInfo _networkInfo;

  BatchRepository({
    required IBatchDatasource batchDatasource,
    required IBatchRemoteDataSource batchRemoteDatasource,
    required NetworkInfo networkInfo,
  }) : _batchLocalDataSource = batchDatasource,
       _batchRemoteDataSource = batchRemoteDatasource,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, bool>> createBatch(BatchEntity batch) async {
    try {
      final model = BatchHiveModel.fromEntity(batch);
      final result = await _batchLocalDataSource.createBatch(model);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: 'Failed to create batch'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteBatch(String batchId) async {
    try {
      final result = await _batchLocalDataSource.deleteBatch(batchId);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: 'Failed to delete batch.'),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BatchEntity>>> getAllBactches() async {
    //internet xa ki xain??
    if (await _networkInfo.isConnected) {
      try{
        //api model lai capture gareko
        final apiModels = await _batchRemoteDataSource.getAllBatches();
        //convert to entity
        final result = BatchApiModel.toEntityList(apiModels);
        return Right(result);
      }
      on DioException catch(e){
        return Left(ApiFailure(
          statusCode: e.response?. statusCode,
          message: e.response?.data['message']??'Failed to fetch batches'
        ));
      }
    } else {
      try {
        final models = await _batchLocalDataSource.getAllBatches();
        final entities = BatchHiveModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
    // try {
    //   final models = await _batchLocalDataSource.getAllBatches();
    //   final entities = BatchHiveModel.toEntityList(models);
    //   return Right(entities);
    // } catch (e) {
    //   return Left(LocalDatabaseFailure(message: e.toString()));
    // }
  }

  @override
  Future<Either<Failure, BatchEntity>> getBatchById(String batchId) async {
    try {
      final model = await _batchLocalDataSource.getBatchById(batchId);
      if (model != null) {
        return Right(model.toEntity());
      }
      return const Left(LocalDatabaseFailure(message: 'Batch not found'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateBatch(BatchEntity batch) async {
    try {
      final model = BatchHiveModel.fromEntity(batch);
      final result = await _batchLocalDataSource.updateBatch(model);
      if (result) {
        return const Right(true);
      }
      return const Left(
        LocalDatabaseFailure(message: "Failed to update batch"),
      );
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, List<BatchEntity>>> getAllBatches()  async {
    if (await _networkInfo.isConnected) {
      try{
        //api model lai capture gareko
        final apiModels = await _batchRemoteDataSource.getAllBatches();
        //convert to entity
        final result = BatchApiModel.toEntityList(apiModels);
        return Right(result);
      }
      on DioException catch(e){
        return Left(ApiFailure(
          statusCode: e.response?. statusCode,
          message: e.response?.data['message']??'Failed to fetch batches'
        ));
      }
    } else {
      try {
        final models = await _batchLocalDataSource.getAllBatches();
        final entities = BatchHiveModel.toEntityList(models);
        return Right(entities);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
}
