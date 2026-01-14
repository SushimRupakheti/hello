import 'package:hive/hive.dart';
import 'package:lost_n_found/core/constants/hive_table_constant.dart';
import 'package:lost_n_found/features/batch/domain/entities/batch_entity.dart';
import 'package:uuid/uuid.dart';

part 'batch_hive_model.g.dart'; // dart run build_runner build -d

@HiveType(typeId: HiveTableConstant.batchTypeId)
class BatchHiveModel extends HiveObject {
  @HiveField(0)
  final String? batchId;

  @HiveField(1)
  final String batchName;

  @HiveField(2)
  final String? status;

  BatchHiveModel({String? batchId, required this.batchName, String? status})
    : batchId = batchId ?? Uuid().v4(),
      status = status ?? 'active';

  BatchEntity toEntity() {
    return BatchEntity(batchId: batchId, batchName: batchName, status: status);
  }

  // Convert Batch Entity to Model
  factory BatchHiveModel.fromEntity(BatchEntity entity) {
    return BatchHiveModel(batchName: entity.batchName);
  }

  // Convert List of Models to List of Batch Entities
  static List<BatchEntity> toEntityList(List<BatchHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
