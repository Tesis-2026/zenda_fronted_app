import 'api_client.dart';
import '../models/category.dart';

class CategoryApiService {
  Future<List<CategoryModel>> getAll() async {
    final list = await ApiClient.getList('/categories');
    return list
        .cast<Map<String, dynamic>>()
        .map(CategoryModel.fromJson)
        .toList();
  }

  Future<CategoryModel> create(String name) async {
    final json = await ApiClient.post(
      '/categories',
      {'name': name},
    );
    return CategoryModel.fromJson(json);
  }

  Future<CategoryModel> rename(String id, String name) async {
    final json = await ApiClient.put('/categories/$id', {'name': name});
    return CategoryModel.fromJson(json);
  }

  Future<void> delete(String id) async {
    await ApiClient.delete('/categories/$id');
  }
}
