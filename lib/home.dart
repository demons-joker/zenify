import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/services/user_session.dart';
import 'package:zenify/utils/iconfont.dart';
import 'menu_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> allRecipes = [];
  dynamic currentRecipe;
  List<dynamic> currentFoods = [];
  List<dynamic> historyFoods = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _fetchCurrentUserFoods();
  }

  Future<void> _fetchRecipes() async {
    try {
      setState(() => isLoading = true);
      final response = await Api.getCurrentUserRecipes(
          {'user_id': await UserSession.userId});
      setState(() {
        currentRecipe = response;
        print('object: $currentRecipe');
        _fetchUserTodayMealRecords(currentRecipe);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('获取食谱失败: $e');
    }
  }

  Future<void> _fetchCurrentUserFoods() async {
    try {
      final response =
          await Api.getCurrentUserFoods({'user_id': await UserSession.userId});
      setState(() {
        currentFoods = response;
        print('object: $currentFoods');
      });
    } catch (e) {
      print('获取食谱失败: $e');
    }
  }

  Future<void> _fetchUserTodayMealRecords(dynamic recipe) async {
    try {
      final response =
          await Api.getCurrentUserFoods({'user_id': await UserSession.userId});
      setState(() {
        historyFoods = response;
        print('historyFoods: $response');
      });
    } catch (e) {
      print('获取食谱失败: $e');
    }
  }

  void _switchRandomRecipe() {
    if (allRecipes.isNotEmpty) {
      final random = Random();
      final newRecipe = allRecipes[random.nextInt(allRecipes.length)];
      setState(() => currentRecipe = newRecipe);
      // _updateFoodsFromRecipe(newRecipe);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    // final mealsData = [
    //   {
    //     "meal_type": "breakfast",
    //     "foods": [
    //       {
    //         "id": 1,
    //         "plan_id": 1,
    //         "food_id": 1,
    //         "quantity": 135,
    //         "unit": "g",
    //         "calories": 227,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "breakfast",
    //         "food": {
    //           "name": "清炒菠菜",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E6%B8%85%E7%82%92%E8%8F%A0%E8%8F%9C.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=64be7dce3af08df24f41adb85d7e24de2e6e08b90f15db535a4a58c82af34532",
    //           "description": "一道以新鲜菠菜为主料，通过快速翻炒制成的简单健康菜肴，保留了菠菜的鲜嫩和营养。",
    //           "preparation_method":
    //               "1. 将新鲜菠菜择去老叶和根部，洗净后沥干水分。\n2. 热锅凉油，放入适量食用油（如花生油或菜籽油）。\n3. 油热后放入蒜末爆香（可选）。\n4. 放入菠菜，用大火快速翻炒1-2分钟，直到菠菜变软、颜色鲜绿。\n5. 加入适量食盐调味，继续翻炒均匀。\n6. 炒至菠菜完全熟透但不过于烂糊，即可关火装盘。",
    //           "category": "蔬菜",
    //           "subcategory": "叶菜类",
    //           "calories_per_100g": 23,
    //           "nutritional_info_json": {
    //             "protein": 2.8,
    //             "fat": 0.4,
    //             "carbohydrate": 3.6,
    //             "calories": 23,
    //             "fiber": 2.2,
    //             "vitamins": [
    //               {"name": "维生素A", "amount": 469},
    //               {"name": "维生素C", "amount": 28},
    //               {"name": "维生素K", "amount": 482.9},
    //               {"name": "叶酸", "amount": 194}
    //             ]
    //           },
    //           "id": 1
    //         }
    //       },
    //       {
    //         "id": 2,
    //         "plan_id": 1,
    //         "food_id": 2,
    //         "quantity": 128,
    //         "unit": "g",
    //         "calories": 437,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "breakfast",
    //         "food": {
    //           "name": "水煮鸡蛋",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E6%B0%B4%E7%85%AE%E9%B8%A1%E8%9B%8B.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=5cc6cd4efe91aeff75073a6a4bea6d4bc09d5a23bc235bc449aa4f6f5e2d5291",
    //           "description": "水煮鸡蛋是通过将鸡蛋带壳在沸水中加热煮熟制成的简单食品，通常作为高蛋白质来源食用。",
    //           "preparation_method":
    //               "1. 选择新鲜的鸡蛋并用清水冲洗干净。\n2. 将鸡蛋放入锅中，加入足够的冷水（水要完全覆盖鸡蛋）。\n3. 将锅放在炉灶上，中火加热至水沸腾。\n4. 水沸腾后，转小火继续煮8-10分钟以确保蛋清和蛋黄完全凝固。\n5. 关火后，将热水倒掉，可以用冷水冲洗鸡蛋以便更容易剥壳。\n6. 剥壳后即可食用，也可以根据个人口味添加少量盐。",
    //           "category": "蛋白质",
    //           "subcategory": "蛋",
    //           "calories_per_100g": 155,
    //           "nutritional_info_json": {
    //             "protein": 12.6,
    //             "fat": 9.5,
    //             "carbohydrate": 0.6,
    //             "calories": 155,
    //             "fiber": 0,
    //             "vitamins": [
    //               {"name": "维生素A", "amount": 140},
    //               {"name": "维生素D", "amount": 87},
    //               {"name": "维生素B2", "amount": 0.45},
    //               {"name": "维生素B12", "amount": 1.1}
    //             ]
    //           },
    //           "id": 2
    //         }
    //       },
    //       {
    //         "id": 3,
    //         "plan_id": 1,
    //         "food_id": 3,
    //         "quantity": 171,
    //         "unit": "g",
    //         "calories": 283,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "breakfast",
    //         "food": {
    //           "name": "全麦面包",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E5%85%A8%E9%BA%A6%E9%9D%A2%E5%8C%85.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=60cf857260c8b99d29c9975a53dba5690b8b945994bb60ed75d56766c464eff4",
    //           "description":
    //               "全麦面包是使用全麦面粉制作的一种面包，相比普通白面包含有更多的膳食纤维、维生素和矿物质，有助于提供更长时间的饱腹感。",
    //           "preparation_method":
    //               "1. 将全麦面粉、水、酵母、盐和少量糖混合成面团。\n2. 揉面约10-15分钟，直到面团光滑有弹性。\n3. 将面团放入碗中，盖上湿布，在温暖环境中发酵约1小时，直到体积翻倍。\n4. 发酵完成后，将面团排气并整形成面包形状，放入烤盘中。\n5. 再次发酵约30分钟。\n6. 预热烤箱至180°C，将发酵好的面团放入烤箱烘烤约30-35分钟，直到表面金黄且底部敲击有空心声。\n7. 烘烤完成后取出，放凉后切片即可食用。",
    //           "category": "碳水",
    //           "subcategory": "面包",
    //           "calories_per_100g": 247,
    //           "nutritional_info_json": {
    //             "protein": 9,
    //             "fat": 3,
    //             "carbohydrate": 49,
    //             "calories": 247,
    //             "fiber": 6,
    //             "vitamins": [
    //               {"name": "维生素B1（硫胺素）", "amount": 0.3},
    //               {"name": "维生素B2（核黄素）", "amount": 0.15},
    //               {"name": "维生素E", "amount": 0.8}
    //             ]
    //           },
    //           "id": 3
    //         }
    //       }
    //     ]
    //   },
    //   {
    //     "meal_type": "lunch",
    //     "foods": [
    //       {
    //         "id": 4,
    //         "plan_id": 1,
    //         "food_id": 4,
    //         "quantity": 217,
    //         "unit": "g",
    //         "calories": 375,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "lunch",
    //         "food": {
    //           "name": "西兰花炒胡萝卜",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E8%A5%BF%E5%85%B0%E8%8A%B1%E7%82%92%E8%83%A1%E8%90%9D%E5%8D%9C.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=808919f88b167346adeb5a7b8a92d4b7b29393ba1d6c793334c1b675df51d930",
    //           "description": "一道以西兰花和胡萝卜为主料，快速翻炒而成的健康清淡家常菜，保留了蔬菜的营养和脆嫩口感。",
    //           "preparation_method":
    //               "1. 准备西兰花一颗，切成小朵，胡萝卜一根，切成薄片。\n2. 将西兰花放入沸水中焯水1分钟，捞出沥干；胡萝卜片也可以稍微焯水以软化口感。\n3. 热锅加油，放入蒜末爆香。\n4. 先倒入胡萝卜片翻炒几下，再加入西兰花。\n5. 加入适量盐、少许生抽调味，快速翻炒均匀。\n6. 可根据喜好加入少量清水焖煮1-2分钟，最后翻炒收汁即可出锅。",
    //           "category": "蔬菜",
    //           "subcategory": "十字花科蔬菜与根茎类蔬菜",
    //           "calories_per_100g": 55,
    //           "nutritional_info_json": {
    //             "protein": 2.8,
    //             "fat": 3.2,
    //             "carbohydrate": 6.5,
    //             "calories": 55,
    //             "fiber": 3.4,
    //             "vitamins": [
    //               {"name": "维生素C", "amount": 75},
    //               {"name": "维生素A", "amount": 16},
    //               {"name": "维生素K", "amount": 98},
    //               {"name": "叶酸", "amount": 65}
    //             ]
    //           },
    //           "id": 4
    //         }
    //       },
    //       {
    //         "id": 5,
    //         "plan_id": 1,
    //         "food_id": 5,
    //         "quantity": 286,
    //         "unit": "g",
    //         "calories": 376,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "lunch",
    //         "food": {
    //           "name": "番茄生菜沙拉",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E7%95%AA%E8%8C%84%E7%94%9F%E8%8F%9C%E6%B2%99%E6%8B%89.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=b354dfd95c5b4b7dfc5196d2c5e23ff21e3581f0f9732f96dc68a68a143f4dfe",
    //           "description": "番茄生菜沙拉是一道清爽的凉菜，主要由新鲜番茄和生菜制成，常用于开胃或作为健康饮食的一部分。",
    //           "preparation_method":
    //               "1. 准备2个中等大小的番茄和适量新鲜生菜。\n2. 将番茄洗净后切成小块，生菜洗净沥干水分。\n3. 将切好的番茄和生菜放入大碗中。\n4. 根据个人口味加入少许盐、橄榄油或其他沙拉酱拌匀。\n5. 放入冰箱冷藏10-15分钟，即可享用。",
    //           "category": "蔬菜",
    //           "subcategory": "叶菜类",
    //           "calories_per_100g": 18,
    //           "nutritional_info_json": {
    //             "protein": 1.2,
    //             "fat": 0.3,
    //             "carbohydrate": 3,
    //             "calories": 18,
    //             "fiber": 1.5,
    //             "vitamins": [
    //               {"name": "维生素A", "amount": 45},
    //               {"name": "维生素C", "amount": 15},
    //               {"name": "维生素K", "amount": 10}
    //             ]
    //           },
    //           "id": 5
    //         }
    //       },
    //       {
    //         "id": 6,
    //         "plan_id": 1,
    //         "food_id": 6,
    //         "quantity": 292,
    //         "unit": "g",
    //         "calories": 162,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "lunch",
    //         "food": {
    //           "name": "香煎鸡胸肉",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E9%A6%99%E7%85%8E%E9%B8%A1%E8%83%B8%E8%82%89.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=92b284f645bce956c631b098ca4f761080c296cb83af5e6042ddf0984c4bbfa5",
    //           "description": "香煎鸡胸肉是一道低脂高蛋白的健康菜肴，采用鸡胸肉经过调味后煎制而成，口感鲜嫩多汁。",
    //           "preparation_method":
    //               "1. 准备一块鸡胸肉，用刀背轻轻拍打使其厚度均匀。\n2. 加入适量盐、黑胡椒、橄榄油和少许料酒腌制15分钟。\n3. 平底锅加热，放入少量橄榄油，将鸡胸肉放入锅中，用中火煎至一面金黄（约3-4分钟）。\n4. 翻面继续煎至另一面金黄，确保内部熟透。\n5. 关火后可静置2-3分钟再切片食用，保持肉质多汁。",
    //           "category": "蛋白质",
    //           "subcategory": "肉类",
    //           "calories_per_100g": 165,
    //           "nutritional_info_json": {
    //             "protein": 31,
    //             "fat": 3.6,
    //             "carbohydrate": 0,
    //             "calories": 165,
    //             "fiber": 0,
    //             "vitamins": [
    //               {"name": "维生素B6", "amount": 0.5},
    //               {"name": "维生素B12", "amount": 0.3}
    //             ]
    //           },
    //           "id": 6
    //         }
    //       },
    //       {
    //         "id": 7,
    //         "plan_id": 1,
    //         "food_id": 7,
    //         "quantity": 206,
    //         "unit": "g",
    //         "calories": 156,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "lunch",
    //         "food": {
    //           "name": "糙米饭",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E7%B3%99%E7%B1%B3%E9%A5%AD.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=714ff89f7597a5cf45e569c6255e0319529821844db29c0de3e1ac162b0b1dbd",
    //           "description": "糙米饭是由未精制的糙米经过蒸煮而成的一种主食，保留了米糠和胚芽，富含营养。",
    //           "preparation_method":
    //               "1. 取适量糙米（约1杯）放入锅中。\n2. 用清水冲洗2-3次，直到水变得较清澈。\n3. 将糙米和水按比例（约1:2）放入电饭锅或锅中。\n4. 浸泡30分钟（可选，有助于软化米粒）。\n5. 按照电饭锅程序煮熟，或在锅中用中小火煮至水分被吸收、米粒变软（大约需要40-50分钟）。\n6. 熄火后焖10分钟，让米饭更加松软可口。",
    //           "category": "碳水",
    //           "subcategory": "谷物类",
    //           "calories_per_100g": 111,
    //           "nutritional_info_json": {
    //             "protein": 2.6,
    //             "fat": 0.9,
    //             "carbohydrate": 23,
    //             "calories": 111,
    //             "fiber": 1.8,
    //             "vitamins": [
    //               {"name": "维生素B1", "amount": 0.4},
    //               {"name": "维生素B3", "amount": 1.6},
    //               {"name": "维生素E", "amount": 0.3}
    //             ]
    //           },
    //           "id": 7
    //         }
    //       }
    //     ]
    //   },
    //   {
    //     "meal_type": "dinner",
    //     "foods": [
    //       {
    //         "id": 8,
    //         "plan_id": 1,
    //         "food_id": 8,
    //         "quantity": 147,
    //         "unit": "g",
    //         "calories": 416,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "dinner",
    //         "food": {
    //           "name": "蒸芦笋",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E8%92%B8%E8%8A%A6%E7%AC%8B.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=76fc9f46b6b266f32d3fd7057436c5988f5fd11676d06ce17ac613a99e4b20fa",
    //           "description":
    //               "蒸芦笋是一道以新鲜芦笋为主料，通过蒸制方式制作的简单健康菜肴，保留了芦笋的天然风味和丰富的营养成分。",
    //           "preparation_method":
    //               "1. 选择新鲜嫩芦笋200克，洗净备用。\n2. 将芦笋切成适口长度，一般为5-8厘米。\n3. 锅中加水烧开，放入适量食盐，将芦笋放入蒸架上。\n4. 大火蒸5-8分钟，至芦笋变软但仍保持翠绿色。\n5. 取出后可淋上少许橄榄油和酱油调味，即可食用。",
    //           "category": "蔬菜",
    //           "subcategory": "茎叶类",
    //           "calories_per_100g": 27,
    //           "nutritional_info_json": {
    //             "protein": 2.9,
    //             "fat": 0.2,
    //             "carbohydrate": 3.9,
    //             "calories": 27,
    //             "fiber": 2.1,
    //             "vitamins": [
    //               {"name": "维生素A", "amount": 0.019},
    //               {"name": "维生素C", "amount": 5.6},
    //               {"name": "维生素E", "amount": 0.7},
    //               {"name": "维生素K", "amount": 41.6},
    //               {"name": "维生素B9 (叶酸)", "amount": 52}
    //             ]
    //           },
    //           "id": 8
    //         }
    //       },
    //       {
    //         "id": 9,
    //         "plan_id": 1,
    //         "food_id": 9,
    //         "quantity": 175,
    //         "unit": "g",
    //         "calories": 219,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "dinner",
    //         "food": {
    //           "name": "清蒸鲈鱼",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E6%B8%85%E8%92%B8%E9%B2%88%E9%B1%BC.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=b6857a81504a64958b6001a4acd7a06c5f7c3cffa3277c5aa98379b3f61a44c1",
    //           "description": "一道以新鲜鲈鱼为主料，通过蒸制方式制作而成的清淡健康菜肴，保留了鱼肉的鲜美和营养。",
    //           "preparation_method":
    //               "1. 选择新鲜鲈鱼一条（约500克），去鳞、去内脏后清洗干净，去除腥线；\n2. 在鱼身两面划几刀，用厨房纸吸干水分；\n3. 鱼身内外抹少许盐，鱼腹塞入姜片和葱段，鱼身表面也放一些姜葱；\n4. 鱼身两面各淋上1小勺料酒腌制10分钟去腥；\n5. 将鲈鱼放入蒸锅中，大火蒸8-10分钟（根据鱼的大小调整时间）；\n6. 蒸好后取出，倒掉盘中的腥水，撒上葱丝；\n7. 另起锅烧热油，趁热将油淋在鱼身上，激发香味；\n8. 最后淋上适量蒸鱼豉油即可。",
    //           "category": "蛋白质",
    //           "subcategory": "鱼类",
    //           "calories_per_100g": 105,
    //           "nutritional_info_json": {
    //             "protein": 18.5,
    //             "fat": 3.2,
    //             "carbohydrate": 0,
    //             "calories": 105,
    //             "fiber": 0,
    //             "vitamins": [
    //               {"name": "维生素B1", "amount": 0.02},
    //               {"name": "维生素B2", "amount": 0.12},
    //               {"name": "维生素D", "amount": 0.01}
    //             ]
    //           },
    //           "id": 9
    //         }
    //       },
    //       {
    //         "id": 10,
    //         "plan_id": 1,
    //         "food_id": 10,
    //         "quantity": 233,
    //         "unit": "g",
    //         "calories": 134,
    //         "notes": "差不多就行",
    //         "day_number": 1,
    //         "meal_type": "dinner",
    //         "food": {
    //           "name": "蒸红薯",
    //           "image_url":
    //               "https://oss-pai-wg4otmxrzffj7vy41l-cn-shanghai.oss-cn-shanghai.aliyuncs.com/xilanhua/foods/%E8%92%B8%E7%BA%A2%E8%96%AF.png?x-oss-signature-version=OSS4-HMAC-SHA256&x-oss-date=20250801T073212Z&x-oss-expires=3599&x-oss-credential=LTAI5tGChGvihkbEvBh26bbz%2F20250801%2Fcn-shanghai%2Foss%2Faliyun_v4_request&x-oss-signature=cc8f534bcceb75f9f3138372d4432095de1f77b22873bd46a8a7152931ecc66c",
    //           "description": "蒸红薯是通过蒸煮方式制作的红薯食品，保留了其天然的甜味和营养，是一种健康的食物选择。",
    //           "preparation_method":
    //               "1. 选择新鲜的红薯，用清水洗净表面的泥土。\n2. 将红薯放入蒸锅中，确保红薯之间留有空间以便蒸汽流通。\n3. 加水至蒸锅的适当位置，盖上锅盖。\n4. 用中火蒸煮约30-40分钟，直到红薯变软。\n5. 用筷子或叉子测试红薯是否熟透，熟透后即可取出食用。",
    //           "category": "碳水",
    //           "subcategory": "根茎类",
    //           "calories_per_100g": 90,
    //           "nutritional_info_json": {
    //             "protein": 1.6,
    //             "fat": 0.2,
    //             "carbohydrate": 20.1,
    //             "calories": 90,
    //             "fiber": 3,
    //             "vitamins": [
    //               {"name": "维生素A", "amount": 709},
    //               {"name": "维生素C", "amount": 2.4},
    //               {"name": "维生素B6", "amount": 0.2}
    //             ]
    //           },
    //           "id": 10
    //         }
    //       }
    //     ]
    //   }
    // ];
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTitleRow(),
          _buildWeekTabs(),
          _buildTodayText(),
          _buildRecipeButton(),
          ..._buildPlanMealCards(context),
          const SizedBox(height: 20),
          _buildDividerWithClock(),
          _buildProgressCard(),
          ..._buildHistoryMealCards(),
        ],
      ),
    );
  }

  // 1. 标题行 (保持不变)
  Widget _buildTitleRow() {
    return Container(
      height: 30,
      width: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black, width: 1)),
      ),
      child: Text(
        '饮食',
        style: TextStyle(
            color: Color(0xFF343434),
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  // 2. 星期Tabs (保持不变)
  Widget _buildWeekTabs() {
    final weekDays = ['日', '一', '二', '三', '四', '五', '六'];
    int selectedDay = DateTime.now().weekday % 7;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          height: 37,
          margin: EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(weekDays.length, (index) {
              final isSelected = index == selectedDay;
              return GestureDetector(
                onTap: () => setState(() => selectedDay = index),
                child: Container(
                  width: 30,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.black : Colors.transparent,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            weekDays[index],
                            style: TextStyle(
                              color:
                                  isSelected ? Colors.white : Color(0xFF4D4D4D),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  // 3. "今天吃什么？"文案 (保持不变)
  Widget _buildTodayText() {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 10, bottom: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '今天吃什么？',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF222222),
          ),
        ),
      ),
    );
  }

  // 4. 食谱按钮 (优化后)
  Widget _buildRecipeButton() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(left: 10),
        child: GestureDetector(
          onTap: _switchRandomRecipe,
          child: Container(
            width: 171,
            height: 37,
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Color(0xFFEA7B3C),
              borderRadius: BorderRadius.circular(18.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 12, right: 8),
                  child: Icon(Icons.restaurant, color: Colors.black, size: 20),
                ),
                Expanded(
                  child: Text(
                    currentRecipe != null
                        ? currentRecipe['name'] ?? '随机食谱'
                        : '暂无数据',
                    style: TextStyle(
                      color: Colors.black,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.autorenew, color: Colors.black, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. 动态生成餐点卡片列表
  List<Widget> _buildPlanMealCards(BuildContext context) {
    return currentFoods.map((meal) {
      return Column(
        children: [
          _buildCurrentMealsCard(context, meal['meal_type'], meal['foods']),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  // 6. 当前餐食Card (优化后)
  Widget _buildCurrentMealsCard(
      BuildContext context, String category, List<dynamic> foods) {
    if (foods.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Text('暂无食物数据'),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Stack(
        children: [
          // 主Card
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(top: 20),
            padding: EdgeInsets.only(top: 30, left: 20, right: 20, bottom: 0),
            decoration: BoxDecoration(
              color: Color(0xFFEAEAEA),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  offset: Offset(2, 2),
                  blurRadius: 2,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: _buildFoodItemsRow(context, foods),
          ),
          // 标题标签
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 100,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFEAEAEA),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(0, -5),
                    blurRadius: 2,
                    spreadRadius: -2,
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Center(
                child: Text(
                  '晚餐',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              icon: Icon(
                IconFont.genghuan,
                size: 45,
                color: Color.fromARGB(255, 243, 109, 14),
              ),
              onPressed: _switchRandomRecipe,
            ),
          ),
        ],
      ),
    );
  }

  // 构建食物项行 (优化后)
  Widget _buildFoodItemsRow(BuildContext context, List<dynamic> foods) {
    // 限制最多显示4个食物
    final displayFoods = foods.length > 4 ? foods.sublist(0, 4) : foods;
    print('displayFoods: $displayFoods');

    if (displayFoods.length <= 3) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: displayFoods
            .map((food) => Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5),
                    child: _buildFoodItem(context, food),
                  ),
                ))
            .toList(),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: displayFoods
                .sublist(0, 3)
                .map((food) => Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5),
                        child: _buildFoodItem(context, food),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 20),
          _buildFoodItem(context, displayFoods[3]),
        ],
      );
    }
  }

  // 食物项组件 (优化后)
  Widget _buildFoodItem(BuildContext context, dynamic food) {
    final realFood = food['food'];
    print('realFood: $realFood');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 188,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 食物图片
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 88,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: realFood['image_url'] != null
                        ? DecorationImage(
                            image: NetworkImage(realFood['image_url']),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: Colors.grey[300],
                  ),
                ),
              ),
              // 底部文字区域
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Container(
                  width: 120,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            realFood['name'] ?? '未知食物',
                            style: TextStyle(
                              color: Color(0xFFBFBFBF),
                              fontSize: 14,
                              height: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${food['quantity'] ?? '0'}g',
                            style: TextStyle(
                              color: Color(0xFFE5A454),
                              fontSize: 12,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${food['calories'] ?? '0'} kcal',
                            style: TextStyle(
                              color: Color(0xFF7C7C7C),
                              fontSize: 12,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // 刷新按钮
              Positioned(
                bottom: -10,
                left: 0,
                child: Material(
                  type: MaterialType.transparency,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MenuPage(
                            category: realFood['name'] ?? '食物',
                            recipeFoods: currentFoods,
                          ),
                        ),
                      );
                    },
                    splashColor: Colors.orange.withOpacity(0.6),
                    child: Container(
                      width: 46,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(23),
                          bottomRight: Radius.circular(23),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.autorenew,
                          size: 20,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 6. 分割线 (保持不变)
  Widget _buildDividerWithClock() {
    return Padding(
      padding: EdgeInsets.only(top: 30, bottom: 20),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 100),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(IconFont.duanshidaojishi, size: 18),
                SizedBox(width: 5),
                Text(
                  '6h后禁食',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(
              color: Colors.black,
              thickness: 1,
              indent: 10,
              endIndent: 10,
            ),
          ),
        ],
      ),
    );
  }

  // 7. 进度条Card (保持不变)
  Widget _buildProgressCard() {
    final progress = 0.5;
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildDataItem(Icon(IconFont.yisheruzhi), '摄入量', '600'),
          ]),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _ProgressPainter(
                    progress: 1.0,
                    color: Colors.grey,
                    strokeWidth: 5,
                  ),
                ),
              ),
              Container(
                width: 110,
                height: 110,
                child: CustomPaint(
                  painter: _ProgressPainter(
                    progress: progress,
                    color: Color(0xFFEA7B3C),
                    strokeWidth: 5,
                  ),
                ),
              ),
              _buildProgressIndicator(progress),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '还可以吃',
                    style: TextStyle(
                      color: Color(0xFFEA7B3C),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '600',
                    style: TextStyle(
                      color: Color(0xFFEA7B3C),
                      fontSize: 23,
                      height: 30 / 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'kcal',
                    style: TextStyle(
                      color: Color(0xFFEA7B3C),
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _buildDataItem(Icon(IconFont.a004jichudaixie), '代谢量', '1200'),
          ]),
        ],
      ),
    );
  }

  // 5. 动态生成餐点卡片列表
  List<Widget> _buildHistoryMealCards() {
    print('historyFoods: $historyFoods');
    return historyFoods.map((food) {
      return Column(
        children: [
          _buildMealsCard(food),
          const SizedBox(height: 20),
        ],
      );
    }).toList();
  }

  // 8. 餐食Card (保持不变)
  Widget _buildMealsCard(dynamic foodObject) {
    List<dynamic> foods = foodObject['foods'];
    final now = DateTime.now();
    final currentTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';

    String getMealType() {
      if (now.hour >= 5 && now.hour < 10) return '早餐';
      if (now.hour >= 11 && now.hour < 14) return '午餐';
      if (now.hour >= 17 && now.hour < 21) return '晚餐';
      return '加餐';
    }

    final meals = [
      {
        'name': '鸡胸肉',
        'type': '蛋白质',
        'calories': '200',
        "img":
            'https://photo.mac89.com/180710/JPG-180710_376/v7txUnfphM_small.jpg'
      },
      {
        'name': '西兰花',
        'type': '蔬菜',
        'calories': '50',
        "img":
            'https://pic.rmb.bdstatic.com/bjh/news/cf06cb5dd3d6649e23bffbff4052f58b.png'
      },
      {
        'name': '糙米饭',
        'type': '碳水化合物',
        'calories': '150',
        "img":
            'https://pic.rmb.bdstatic.com/bjh/250312/dump/3431b10c15fa1331dbdf58901e62248b.jpeg'
      },
    ];
    return Stack(children: [
      Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 40, right: 20, bottom: 20, left: 20),
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(10),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                '${getMealType()} $currentTime',
                style: TextStyle(
                  color: Color(0xFFDEDEDE),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...foods
                .map((meal) => Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: NetworkImage(
                                    meal['food']['image_url'] ?? ''),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal['food']['name']!,
                                    style: TextStyle(
                                      color: Color(0xFFDEDEDE),
                                      fontSize: 18,
                                      height: 20 / 18,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '${meal['quantity']}${meal['unit']}',
                                    style: TextStyle(
                                      color: Color(0xFF7C7C7C),
                                      fontSize: 16,
                                      height: 20 / 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            '${meal['calories']}kcal',
                            style: TextStyle(
                              color: Color(0xFF7C7C7C),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ],
        ),
      ),
      Positioned(
          top: 30,
          right: 120,
          child: Container(
            width: 80,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                '25min',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
      Positioned(
          top: 30,
          right: 20,
          child: Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Center(
              child: Text(
                '400kcal',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )),
    ]);
  }

  // 进度指示器 (保持不变)
  Widget _buildProgressIndicator(double progress) {
    final angle = 2 * 3.1416 * progress - 3.1416 / 2;
    final x = 87.5 + 80 * cos(angle);
    final y = 87.5 + 80 * sin(angle);

    return Positioned(
      left: x - 2.5,
      top: y - 2.5,
      child: Container(
        width: 5,
        height: 5,
        decoration: BoxDecoration(
          color: Color(0xFFEA7B3C),
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  // 数据项组件 (保持不变)
  Widget _buildDataItem(Icon icon, String label, String value) {
    return Column(
      children: [
        icon,
        SizedBox(height: 5),
        Text(label, style: TextStyle(fontSize: 12)),
        SizedBox(height: 2),
        Text(value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// 自定义进度条绘制 (保持不变)
class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  _ProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.1416 / 2,
      2 * 3.1416 * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
