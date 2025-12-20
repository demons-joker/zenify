import 'package:flutter/material.dart';
import 'package:zenify/services/api.dart';
import 'package:zenify/services/user_session.dart';

class RecipeListPage extends StatefulWidget {
  final Recipe? initialRecipe;
  final Function(Recipe) onRecipeSelected;

  const RecipeListPage({
    required this.initialRecipe,
    required this.onRecipeSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _RecipeListState createState() => _RecipeListState();
}

class _RecipeListState extends State<RecipeListPage> {
  bool isLoading = true;
  int selectedIndex = -1;
  int hoverIndex = -1;
  List<Recipe> recipes = [];

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
  }

  Future<void> _updateCurrentRecipe(Recipe recipe) async {
    print('_updateCurrentRecipe:$recipe');
    try {
      await Api.updateCurrentUserRecipes(
          {'user_id': await UserSession.userId, 'recipe_id': recipe.id});
      widget.onRecipeSelected(recipe);
    } catch (e) {
      print('更新食谱失败: $e');
    }
  }

  Future<void> _fetchRecipes() async {
    try {
      setState(() => isLoading = true);
      final response =
          await Api.getRecipes(RecipesRequest(skip: 0, limit: 1000));
      print('获取食谱结果: $response');

      setState(() {
        recipes = response;
        print('widget.initialRecipe:${widget.initialRecipe}');
        print('widget.recipes:${response[0].name}');
        if (widget.initialRecipe != null) {
          selectedIndex =
              recipes.indexWhere((r) => r.id == widget.initialRecipe?.id);
          print('selectedIndex:$selectedIndex');
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('获取食谱List失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Container(
          alignment: Alignment.centerRight,
          child: const Text(
            '食谱列表',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222222),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return MouseRegion(
              onEnter: (_) => setState(() => hoverIndex = index),
              onExit: (_) => setState(() => hoverIndex = -1),
              child: GestureDetector(
                  onTap: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('确认选择'),
                        content: Text('确定要选择该食谱吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text('取消'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: Text('确认'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      setState(() => selectedIndex = index);
                      _updateCurrentRecipe(recipes[index]);
                    }
                  },
                  child: Card(
                    margin: EdgeInsets.all(8.0),
                    color: selectedIndex == index
                        ? Colors.blue[50]
                        : (hoverIndex == index ? Colors.grey[100] : null),
                    elevation: selectedIndex == index
                        ? 4.0
                        : (hoverIndex == index ? 3.0 : 2.0),
                    shape: RoundedRectangleBorder(
                      side: selectedIndex == index
                          ? BorderSide(color: Colors.blue, width: 2.0)
                          : (hoverIndex == index
                              ? BorderSide(
                                  color: Colors.grey[300] ?? Colors.grey,
                                  width: 1.0)
                              : BorderSide.none),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Stack(
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                recipes[index].name,
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                '用餐周期: ${recipes[index].durationDays}天',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                recipes[index].description,
                              ),
                              if (recipes[index].dietaryRules != null)
                                SizedBox(height: 8.0),
                              if (recipes[index].dietaryRules != null)
                                Text(
                                  '饮食规则: ${recipes[index].dietaryRules}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              SizedBox(height: 8.0),
                              Text(
                                recipes[index].isPreset ? '预设食谱' : '自定义食谱',
                                style: TextStyle(
                                  color: recipes[index].isPreset
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (selectedIndex == index)
                          Positioned(
                            right: 8.0,
                            bottom: 8.0,
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 24.0,
                            ),
                          ),
                      ],
                    ),
                  )));
        },
      ),
    );
  }
}
