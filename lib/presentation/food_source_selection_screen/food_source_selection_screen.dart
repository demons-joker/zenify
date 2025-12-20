import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../utils/questionnaire_progress_helper.dart';
import '../../widgets/bottom_input_section.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_progress_app_bar.dart';

class FoodSourceSelectionScreen extends StatefulWidget {
  const FoodSourceSelectionScreen({super.key});

  @override
  State<FoodSourceSelectionScreen> createState() => _FoodSourceSelectionScreenState();
}

class _FoodSourceSelectionScreenState extends State<FoodSourceSelectionScreen> {
  final TextEditingController _addMoreController = TextEditingController();
  String? selectedFoodSource;
  String? mainGoal;
  String? chronicDisease;
  String? preference;
  bool isFromChronicDisease = false;
  ProgressInfo? progressInfo;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _updateProgress();
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedData = await UserDataCache.getUserProfile();
      if (cachedData.isNotEmpty) {
        setState(() {
          mainGoal = cachedData['main_goal'];
          chronicDisease = cachedData['chronic_disease'];
          preference = cachedData['preference'];
          isFromChronicDisease = mainGoal == 'Chronic Disease' && 
                                chronicDisease != null;
        });
        print('已加载缓存数据: $cachedData');
      }
    } catch (e) {
      print('加载缓存数据失败: $e');
    }
  }

  Future<void> _updateProgress() async {
    final progress = await QuestionnaireProgressHelper.calculateProgress('foodSource');
    setState(() {
      progressInfo = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0x9EFFFFFF),
            borderRadius: BorderRadius.circular(18.h),
            boxShadow: [
              BoxShadow(
                color: Color(0xFF888888),
                offset: Offset(0, 4.h),
                blurRadius: 18.h,
              ),
            ],
          ),
          child: CustomProgressAppBar(
            leadingIcon: ImageConstant.imgVector,
            onLeadingPressed: () => Navigator.of(context).pop(),
            currentStep: progressInfo?.currentStep ?? 4,
            totalSteps: progressInfo?.totalSteps ?? 10,
            progressValue: progressInfo?.progressValue ?? 0.4,
            backgroundColor: Color(0x9EFFFFFF),
            progressBackgroundColor: Color(0xFFF7F4F3),
            progressColor: Color(0xFF52D1C6),
            stepTextColor: Color(0xFFABABAB),
            iconBackgroundColor: Color(0xFFF8F8F8),
            showShadow: true,
            height: 80.h,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(
            top: 6.h,
            right: 14.h,
            left: 14.h,
            bottom: 120.h, // 为底部按钮留出空间
          ),
          child: Column(
            spacing: 32.h,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeaderSection(context),
              _buildFoodSourceOptions(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomInputSection(
        controller: _addMoreController,
        placeholder: 'Add more',
        onPressed: () => _onContinuePressed(context),
        onChanged: (value) {
          setState(() {
            if (value.isNotEmpty) {
              selectedFoodSource = value;
            }
          });
        },
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 192.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 8.h),
              child: CustomImageView(
                imagePath: ImageConstant.imgBlack900,
                height: 174.h,
                width: 174.h,
                fit: BoxFit.contain,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.0, -1.0),
                end: Alignment(0.0, 1.0),
                colors: [Color(0xFFFDF8F5), Color(0xFFF2F5F6)],
              ),
              border: Border.all(color: appTheme.white_A700, width: 2.h),
              borderRadius: BorderRadius.circular(20.h),
            ),
            padding: EdgeInsets.symmetric(horizontal: 6.h, vertical: 8.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 2.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.h),
                  child: Text(
                    "Where does most of your food come from?",
                    style: TextStyleHelper.instance.title20SemiBoldPingFangSC
                        .copyWith(color: appTheme.gray_900, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodSourceOptions(BuildContext context) {
    final List<String> foodSources = [
      'Mostly home-cooked',
      'Mostly takeout or restaurants',
      'About half and half',
      '🤷 It varies',
    ];

    return Column(
      children: foodSources.map((foodSource) {
        bool isSelected = selectedFoodSource == foodSource;
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: GestureDetector(
            onTap: () => _onFoodSourceSelected(foodSource),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: 16.h,
                horizontal: 24.h,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.97, -0.24),
                  end: Alignment(0.97, 0.24),
                  colors: isSelected
                      ? [
                          Color(0xFFD0F077),
                          Color(0xFFC8FD00),
                        ]
                      : [
                          Color(0xFFFDF8F5),
                          Color(0xFFF2F5F6),
                        ],
                ),
                border: Border.all(
                  color: Color(0xFFFFFFFF),
                  width: 2.h,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.h),
                  topRight: Radius.circular(0),
                  bottomLeft: Radius.circular(20.h),
                  bottomRight: Radius.circular(20.h),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF888888),
                    offset: Offset(0, 4.h),
                    blurRadius: 13.h,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  foodSource,
                  style: TextStyleHelper.instance.title18SemiBoldPingFangSC.copyWith(
                      height: 1.44,
                      color: isSelected ? Color(0xFFFFFFFF) : Color(0xFF30322D)),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _onFoodSourceSelected(String foodSource) {
    setState(() {
      selectedFoodSource = foodSource;
      _addMoreController.clear();
    });
  }

  Future<void> _saveFoodSourceData() async {
    try {
      await UserDataCache.saveUserProfile(
        foodSource: selectedFoodSource,
      );
      print('食物来源数据已保存到缓存: $selectedFoodSource');
    } catch (e) {
      print('保存食物来源数据到缓存失败: $e');
      rethrow;
    }
  }

  void _onContinuePressed(BuildContext context) async {
    if (selectedFoodSource != null && selectedFoodSource!.isNotEmpty) {
      // 保存数据
      await _saveFoodSourceData();

      // 清空输入框
      _addMoreController.clear();

      // Show success message and navigate
      if (!mounted) return;
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Food source saved! Let\'s continue with the setup.'),
            backgroundColor: appTheme.colorFF52D1,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to next screen
      if (mounted && context.mounted) {
        Navigator.of(context).pushNamed(AppRoutes.foodDislikeScreen);
      }
    } else {
      if (!mounted) return;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a food source to continue'),
            backgroundColor: appTheme.redCustom,
          ),
        );
      }
    }
  }
}