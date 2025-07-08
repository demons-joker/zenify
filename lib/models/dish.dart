class Dish {
  final String id;
  final String name;
  final String category; // 肉类、蔬菜、碳水
  final String tag; // 子分类标签
  final String imageUrl; // 菜品图片URL
  final double price;
  final String description;
  final double rating; // 评分
  final bool isPopular;
  final List<String> ingredients; // 食材列表

  Dish({
    required this.id,
    required this.name,
    required this.category,
    required this.tag,
    this.imageUrl = '',
    required this.price,
    this.description = '',
    this.rating = 0.0,
    this.isPopular = false,
    this.ingredients = const [], // 默认为空列表
  });

  // 从JSON创建Dish对象
  factory Dish.fromJson(Map<String, dynamic> json) {
    return Dish(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      tag: json['tag'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      isPopular: json['isPopular'] ?? false,
      ingredients: List<String>.from(json['ingredients'] ?? []),
    );
  }

  // 将Dish对象转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'tag': tag,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'rating': rating,
      'isPopular': isPopular,
      'ingredients': ingredients,
    };
  }
}
