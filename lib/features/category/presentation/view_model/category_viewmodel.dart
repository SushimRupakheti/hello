import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lost_n_found/features/category/domain/usecases/create_category_usecase.dart';
import 'package:lost_n_found/features/category/domain/usecases/delete_category_usecase.dart';
import 'package:lost_n_found/features/category/domain/usecases/get_all_category_usecase.dart';
import 'package:lost_n_found/features/category/domain/usecases/get_category_by_id_usecase.dart';
import 'package:lost_n_found/features/category/domain/usecases/update_category_usecase.dart';
import 'package:lost_n_found/features/category/presentation/state/category_state.dart';

final categoryViewModelProvider =
    NotifierProvider<CategoryViewmodel, CategoryState>(CategoryViewmodel.new);

class CategoryViewmodel extends Notifier<CategoryState> {
  late final GetAllCategoryUsecase _getAllCategoryUsecase;
  late final GetCategoryByIdUsecase _getCategoryByIdUsecase;
  late final CreateCategoryUsecase _createCategoryUsecase;
  late final UpdateCategoryUsecase _updateCategoryUsecase;
  late final DeleteCategoryUsecase _deleteCategoryUsecase;

  @override
  CategoryState build() {
    // Initialize the usecases here using ref, which we will do later
    return const CategoryState();
  }

  Future<void> getAllCategories() async {
    state = state.copyWith(status: CategoryStatus.loading);

    final result = await _getAllCategoryUsecase();

    result.fold(
      (failure) => state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      ),
      (categories) => state = state.copyWith(
        status: CategoryStatus.loaded,
        categories: categories,
      ),
    );
  }

  Future<void> getCategoryById(String categoryId) async {
    state = state.copyWith(status: CategoryStatus.loading);

    final result = await _getCategoryByIdUsecase(
      GetCategoryByIdUsecaseParams(categoryId: categoryId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      ),
      (category) => state = state.copyWith(status: CategoryStatus.loaded),
    );
  }

  Future<void> createCategory({
    required String name,
    String? description,
  }) async {
    state = state.copyWith(status: CategoryStatus.loading);

    final result = await _createCategoryUsecase(
      CreateCategoryUsecaseParams(name: name, description: description),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: CategoryStatus.created);
        getAllCategories();
      },
    );
  }

  Future<void> updateCategory({
    required String categoryId,
    required String name,
    String? description,
    String? status,
  }) async {
    state = state.copyWith(status: CategoryStatus.loading);

    final result = await _updateCategoryUsecase(
      UpdateCategoryUsecaseParams(
        categoryId: categoryId,
        name: name,
        description: description,
        status: status,
      ),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: CategoryStatus.updated);
        getAllCategories();
      },
    );
  }

  Future<void> deleteCategory(String categoryId) async {
    state = state.copyWith(status: CategoryStatus.loading);

    final result = await _deleteCategoryUsecase(
      DeleteCategoryUsecaseParams(categoryId: categoryId),
    );

    result.fold(
      (failure) => state = state.copyWith(
        status: CategoryStatus.error,
        errorMessage: failure.message,
      ),
      (success) {
        state = state.copyWith(status: CategoryStatus.deleted);
        getAllCategories();
      },
    );
  }
}
