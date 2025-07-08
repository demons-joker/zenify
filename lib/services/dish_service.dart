import '../models/dish.dart';

class DishService {
  // 单例模式
  static final DishService _instance = DishService._internal();

  factory DishService() {
    return _instance;
  }

  DishService._internal();

  // 预定义的菜品数据集
  final List<Dish> _dishes = [
    // 肉类
    Dish(
      id: 'm1',
      name: '红烧肉',
      category: '肉类',
      tag: '猪肉',
      price: 38.0,
      description: '经典红烧肉，肥而不腻，入口即化',
      rating: 4.8,
      isPopular: true,
      ingredients: ['五花肉', '酱油', '白糖', '料酒', '姜', '葱'],
    ),
    Dish(
      id: 'm2',
      name: '水煮牛肉',
      category: '肉类',
      tag: '牛肉',
      price: 48.0,
      description: '麻辣鲜香的水煮牛肉，牛肉鲜嫩多汁',
      rating: 4.7,
      ingredients: ['牛肉', '豆芽', '辣椒', '花椒', '蒜', '姜', '葱'],
    ),
    Dish(
      id: 'm3',
      name: '宫保鸡丁',
      category: '肉类',
      tag: '鸡肉',
      price: 32.0,
      description: '经典川菜，鸡肉嫩滑，花生香脆',
      rating: 4.6,
      isPopular: true,
      ingredients: ['鸡胸肉', '花生', '干辣椒', '葱', '姜', '蒜', '酱油', '醋'],
    ),
    Dish(
      id: 'm4',
      name: '孜然羊肉',
      category: '肉类',
      tag: '羊肉',
      price: 52.0,
      description: '香辣可口的孜然羊肉，肉质鲜嫩',
      rating: 4.5,
      ingredients: ['羊肉', '孜然粉', '辣椒粉', '洋葱', '蒜', '生抽'],
    ),
    Dish(
      id: 'm5',
      name: '北京烤鸭',
      category: '肉类',
      tag: '鸭肉',
      price: 88.0,
      description: '皮脆肉嫩，香气四溢的传统名菜',
      rating: 4.9,
      isPopular: true,
      ingredients: ['整只鸭', '葱', '黄瓜', '甜面酱', '薄饼'],
    ),
    Dish(
      id: 'm6',
      name: '清蒸鱼',
      category: '肉类',
      tag: '鱼肉',
      price: 68.0,
      description: '鲜美可口的清蒸鱼，肉质细嫩',
      rating: 4.7,
      ingredients: ['鲜鱼', '姜', '葱', '蒜', '酱油', '料酒'],
    ),
    Dish(
      id: 'm7',
      name: '油焖大虾',
      category: '肉类',
      tag: '虾',
      price: 78.0,
      description: '色泽红亮，虾肉鲜嫩，味道浓郁',
      rating: 4.8,
      isPopular: true,
      ingredients: ['大虾', '葱', '姜', '蒜', '料酒', '酱油', '糖'],
    ),
    Dish(
      id: 'm8',
      name: '香辣蟹',
      category: '肉类',
      tag: '蟹',
      price: 98.0,
      description: '麻辣鲜香的香辣蟹，蟹肉鲜美',
      rating: 4.6,
      ingredients: ['螃蟹', '干辣椒', '花椒', '姜', '蒜', '葱', '料酒'],
    ),

    // 蔬菜
    Dish(
      id: 'v1',
      name: '清炒油麦菜',
      category: '蔬菜',
      tag: '叶菜类',
      price: 18.0,
      description: '清脆爽口的油麦菜，营养丰富',
      rating: 4.3,
      ingredients: ['油麦菜', '蒜', '盐', '食用油', '鸡精'],
    ),
    Dish(
      id: 'v2',
      name: '蒜蓉空心菜',
      category: '蔬菜',
      tag: '叶菜类',
      price: 16.0,
      description: '蒜香浓郁，口感清脆的空心菜',
      rating: 4.4,
      isPopular: true,
      ingredients: ['空心菜', '蒜', '盐', '食用油', '鸡精'],
    ),
    Dish(
      id: 'v3',
      name: '胡萝卜炒肉',
      category: '蔬菜',
      tag: '根茎类',
      price: 26.0,
      description: '胡萝卜甜脆，搭配肉丝鲜香可口',
      rating: 4.5,
      ingredients: ['胡萝卜', '猪肉', '蒜', '盐', '酱油', '食用油'],
    ),
    Dish(
      id: 'v4',
      name: '凉拌莲藕',
      category: '蔬菜',
      tag: '根茎类',
      price: 22.0,
      description: '清脆爽口的凉拌莲藕，开胃爽口',
      rating: 4.2,
      ingredients: ['莲藕', '醋', '糖', '盐', '香油', '辣椒油'],
    ),
    Dish(
      id: 'v5',
      name: '炒丝瓜',
      category: '蔬菜',
      tag: '瓜果类',
      price: 20.0,
      description: '清淡爽口的炒丝瓜，营养健康',
      rating: 4.1,
      ingredients: ['丝瓜', '蒜', '盐', '食用油', '鸡精'],
    ),
    Dish(
      id: 'v6',
      name: '蒜蓉茄子',
      category: '蔬菜',
      tag: '瓜果类',
      price: 24.0,
      description: '蒜香浓郁，茄子软糯的经典菜品',
      rating: 4.6,
      isPopular: true,
      ingredients: ['茄子', '蒜', '盐', '酱油', '食用油', '糖'],
    ),
    Dish(
      id: 'v7',
      name: '香菇青菜',
      category: '蔬菜',
      tag: '菌菇类',
      price: 22.0,
      description: '香菇鲜香，青菜清脆的完美搭配',
      rating: 4.3,
      ingredients: ['香菇', '青菜', '蒜', '盐', '食用油', '鸡精'],
    ),
    Dish(
      id: 'v8',
      name: '麻婆豆腐',
      category: '蔬菜',
      tag: '豆类',
      price: 28.0,
      description: '麻辣鲜香的经典川菜，豆腐嫩滑',
      rating: 4.7,
      isPopular: true,
      ingredients: ['豆腐', '肉末', '豆瓣酱', '花椒', '辣椒', '葱', '姜', '蒜'],
    ),
    Dish(
      id: 'v9',
      name: '土豆丝',
      category: '蔬菜',
      tag: '薯类',
      price: 18.0,
      description: '酸辣可口的土豆丝，开胃下饭',
      rating: 4.4,
      ingredients: ['土豆', '醋', '辣椒', '盐', '食用油', '蒜'],
    ),

    // 碳水
    Dish(
      id: 'c1',
      name: '蛋炒饭',
      category: '碳水',
      tag: '米饭',
      price: 16.0,
      description: '香喷喷的蛋炒饭，粒粒分明',
      rating: 4.5,
      isPopular: true,
      ingredients: ['米饭', '鸡蛋', '葱', '盐', '食用油', '酱油'],
    ),
    Dish(
      id: 'c2',
      name: '扬州炒饭',
      category: '碳水',
      tag: '米饭',
      price: 22.0,
      description: '经典扬州炒饭，配料丰富，色香味俱全',
      rating: 4.6,
      ingredients: ['米饭', '鸡蛋', '火腿', '虾仁', '豌豆', '胡萝卜', '葱', '盐', '食用油'],
    ),
    Dish(
      id: 'c3',
      name: '担担面',
      category: '碳水',
      tag: '面食',
      price: 26.0,
      description: '麻辣鲜香的担担面，面条劲道',
      rating: 4.7,
      isPopular: true,
      ingredients: ['面条', '肉末', '花生', '芝麻酱', '辣椒油', '花椒', '葱', '蒜'],
    ),
    Dish(
      id: 'c4',
      name: '葱油拌面',
      category: '碳水',
      tag: '面食',
      price: 20.0,
      description: '葱香浓郁，简单美味的拌面',
      rating: 4.4,
      ingredients: ['面条', '葱', '食用油', '盐', '酱油', '香油'],
    ),
    Dish(
      id: 'c5',
      name: '肉夹馍',
      category: '碳水',
      tag: '馒头',
      price: 12.0,
      description: '陕西特色小吃，肉香四溢，馍香软糯',
      rating: 4.8,
      isPopular: true,
      ingredients: ['白吉馍', '五花肉', '葱', '姜', '八角', '桂皮', '酱油'],
    ),
    Dish(
      id: 'c6',
      name: '三明治',
      category: '碳水',
      tag: '面包',
      price: 15.0,
      description: '营养丰富的三明治，口感丰富',
      rating: 4.3,
      ingredients: ['吐司', '火腿', '生菜', '番茄', '黄瓜', '鸡蛋', '沙拉酱'],
    ),
    Dish(
      id: 'c7',
      name: '香酥土豆饼',
      category: '碳水',
      tag: '土豆',
      price: 18.0,
      description: '外酥里嫩的土豆饼，香气四溢',
      rating: 4.5,
      ingredients: ['土豆', '面粉', '鸡蛋', '葱', '盐', '食用油'],
    ),
    Dish(
      id: 'c8',
      name: '烤红薯',
      category: '碳水',
      tag: '红薯',
      price: 8.0,
      description: '香甜软糯的烤红薯，健康美味',
      rating: 4.6,
      isPopular: true,
      ingredients: ['红薯'],
    ),
    Dish(
      id: 'c9',
      name: '烤玉米',
      category: '碳水',
      tag: '玉米',
      price: 10.0,
      description: '香甜可口的烤玉米，营养丰富',
      rating: 4.4,
      ingredients: ['玉米', '黄油', '盐'],
    ),
  ];

  // 获取所有菜品
  List<Dish> getAllDishes() {
    return List.from(_dishes);
  }

  // 根据类别获取菜品
  List<Dish> getDishesByCategory(String category) {
    return _dishes.where((dish) => dish.category == category).toList();
  }

  // 根据类别和标签获取菜品
  List<Dish> getDishesByCategoryAndTag(String category, String tag) {
    return _dishes
        .where((dish) => dish.category == category && dish.tag == tag)
        .toList();
  }

  // 获取热门菜品
  List<Dish> getPopularDishes() {
    return _dishes.where((dish) => dish.isPopular).toList();
  }

  // 根据ID获取菜品
  Dish? getDishById(String id) {
    try {
      return _dishes.firstWhere((dish) => dish.id == id);
    } catch (e) {
      return null;
    }
  }

  // 搜索菜品
  List<Dish> searchDishes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _dishes
        .where((dish) =>
            dish.name.toLowerCase().contains(lowercaseQuery) ||
            dish.description.toLowerCase().contains(lowercaseQuery) ||
            dish.tag.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // 模拟从API获取数据的方法
  // 将来可以修改此方法以从实际API获取数据
  Future<List<Dish>> fetchDishes(String category) async {
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 300));
    return getDishesByCategory(category);
  }
}
