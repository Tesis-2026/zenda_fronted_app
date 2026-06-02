enum CategoryType { system, custom }

class CategoryModel {
  final String id;
  final String name;
  final CategoryType type;

  /// Stable semantic icon key from the backend (e.g. 'food', 'transport').
  /// null for custom categories — the UI renders a single default icon.
  final String? icon;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: (json['type'] as String) == 'SYSTEM' ? CategoryType.system : CategoryType.custom,
      icon: json['icon'] as String?,
    );
  }

  bool get isCustom => type == CategoryType.custom;
}
