enum CategoryType { system, custom }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: (json['type'] as String) == 'SYSTEM' ? CategoryType.system : CategoryType.custom,
    );
  }

  bool get isCustom => type == CategoryType.custom;
}
