import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../utils/questionnaire_progress_helper.dart';
import '../../widgets/bottom_input_section.dart';
import '../../widgets/custom_progress_app_bar.dart';
import '../../widgets/custom_image_view.dart';

class AllergyScreen extends StatefulWidget {
  const AllergyScreen({super.key});

  @override
  State<AllergyScreen> createState() => _AllergyScreenState();
}

class _AllergyScreenState extends State<AllergyScreen> {
  Set<String> selectedAllergies = {};
  String? mainGoal;
  String? chronicDisease;
  String? preference;
  String? foodSource;
  String? foodDislikes;
  String? eatingStyle;
  String? eatingRoutine;
  bool isFromChronicDisease = false;
  TextEditingController _additionalAllergyController = TextEditingController();
  ProgressInfo? progressInfo;

  // 根据用户路径计算当前步骤
  int get currentStep {
    int baseStep = isFromChronicDisease ? 7 : 6;
    // 如果有饮食风格数据，说明经过了饮食风格页面
    if (eatingStyle != null) {
      return baseStep + 1;
    }
    // 如果有饮食规律数据，说明经过了饮食规律页面
    if (eatingRoutine != null) {
      return baseStep + 2;
    }
    return baseStep;
  }

  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _updateProgress();
  }

  @override
  void dispose() {
    _additionalAllergyController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedData = await UserDataCache.getUserProfile();
      if (cachedData.isNotEmpty) {
        setState(() {
          mainGoal = cachedData['main_goal'];
          chronicDisease = cachedData['chronic_disease'];
          preference = cachedData['preference'];
          foodSource = cachedData['food_source'];
          foodDislikes = cachedData['food_dislikes'];
          eatingStyle = cachedData['eating_style'];
          eatingRoutine = cachedData['eating_routine'];

          // 加载已选择的过敏食物
          final allergyString = cachedData['allergies'] as String?;
          if (allergyString != null && allergyString.isNotEmpty) {
            selectedAllergies =
                allergyString.split(',').map((e) => e.trim()).toSet();
          }

          isFromChronicDisease =
              mainGoal == 'Chronic Disease' && chronicDisease != null;
        });
        print('已加载缓存数据: $cachedData');
      }
    } catch (e) {
      print('加载缓存数据失败: $e');
    }
  }

  Future<void> _updateProgress() async {
    final progress =
        await QuestionnaireProgressHelper.calculateProgress('allergy');
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
            currentStep: progressInfo?.currentStep ?? 8,
            totalSteps: progressInfo?.totalSteps ?? 10,
            progressValue: progressInfo?.progressValue ?? 0.8,
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
              _buildMultipleChoiceText(context),
              _buildAllergyOptions(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomInputSection(
        controller: _additionalAllergyController,
        placeholder: 'Add more',
        buttonText: 'Skip',
        buttonTextStyle: TextStyle(
          color: Color(0xFF779600),
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        onPressed: () => _onContinuePressed(context),
        onChanged: (value) => _onInputChanged(value),
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
            child: Padding(
              padding: EdgeInsets.only(top: 8.h),
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
                    "What foods are you allergic to? 😫",
                    style: TextStyleHelper.instance.title20SemiBoldPingFangSC
                        .copyWith(color: appTheme.gray_900, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyOptions(BuildContext context) {
    final List<Map<String, String>> allergies = [
      {
        'title': 'Gluten allergy',
        'description': 'Wheat, barley, rye, etc.',
      },
      {
        'title': 'Nut allergy',
        'description': 'Peanuts, walnuts, almonds, etc',
      },
      {
        'title': 'Dairy allergy',
        'description': 'Milk, cheese, butter, etc.',
      },
      {
        'title': 'Seafood allergy',
        'description': 'Shrimp, crab, shellfish, etc.',
      },
      {
        'title': 'Egg allergy',
        'description': 'Eggs and egg products',
      },
    ];

    return Column(
      children: allergies.map((allergy) {
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildAllergyCard(
            context,
            allergy['title']!,
            allergy['description']!,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAllergyCard(
    BuildContext context,
    String title,
    String description,
  ) {
    bool isSelected = selectedAllergies.contains(title);

    return GestureDetector(
      onTap: () => _onAllergyToggled(title),
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    TextStyleHelper.instance.title18SemiBoldPingFangSC.copyWith(
                  height: 1.44,
                  color: isSelected ? Colors.white : Color(0xFF30322D),
                ),
              ),
              if (description.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text(
                  description,
                  style:
                      TextStyleHelper.instance.title18MediumPingFangSC.copyWith(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : appTheme.gray_500,
                    height: 1.3,
                    fontSize: 14.fSize,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceText(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.h),
      child: Text(
        "MULTIPLE CHOICE",
        style: TextStyleHelper.instance.title18MediumPingFangSC.copyWith(
          color: Color(0xFFD5D5D5),
          height: 1.4,
          fontSize: 18.fSize,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Future<void> _saveAllergyData() async {
    try {
      final allergyString = selectedAllergies.join(', ');
      await UserDataCache.saveUserProfile(
        allergies: allergyString,
      );
      print('过敏食物数据已保存到缓存: $allergyString');
    } catch (e) {
      print('保存过敏食物数据到缓存失败: $e');
      rethrow;
    }
  }

  void _onAllergyToggled(String allergy) {
    setState(() {
      if (selectedAllergies.contains(allergy)) {
        selectedAllergies.remove(allergy);
      } else {
        selectedAllergies.add(allergy);
      }
    });
  }

  void _onInputChanged(String value) {
    // 检查输入是否包含逗号，如果是，则分割并添加到选择列表
    if (value.contains(',') || value.endsWith('\n')) {
      final items = value
          .split(RegExp(r'[,，\n]'))
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty);
      for (final item in items) {
        if (!selectedAllergies.contains(item)) {
          setState(() {
            selectedAllergies.add(item);
          });
        }
      }
      _additionalAllergyController.clear();
    }
  }

  void _onContinuePressed(BuildContext context) async {
    // 保存数据（即使没有选择任何过敏食物）
    await _saveAllergyData();

    if (!mounted) return;

    if (selectedAllergies.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Great! Your allergies have been saved.'),
          backgroundColor: appTheme.colorFF52D1,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No allergies selected. You can update this later.'),
          backgroundColor: appTheme.blue_gray_100,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // 导航到活动水平页面
    if (mounted) {
      Navigator.of(context).pushNamed(AppRoutes.activityLevelScreen);
    }
  }
}
