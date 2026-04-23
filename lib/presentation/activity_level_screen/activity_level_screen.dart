import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../utils/questionnaire_progress_helper.dart';
import '../../widgets/custom_progress_app_bar.dart';
import '../../widgets/custom_image_view.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  String? selectedActivityLevel;
  String? mainGoal;
  String? chronicDisease;
  String? preference;
  String? foodSource;
  String? foodDislikes;
  String? eatingStyle;
  String? eatingRoutine;
  List<String> selectedAllergies = [];
  bool isFromChronicDisease = false;
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
    // 如果有过敏数据，说明经过了过敏页面
    if (selectedAllergies.isNotEmpty) {
      return baseStep + 3;
    }
    return baseStep;
  }

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
          foodSource = cachedData['food_source'];
          foodDislikes = cachedData['food_dislikes'];
          eatingStyle = cachedData['eating_style'];
          eatingRoutine = cachedData['eating_routine'];
          selectedActivityLevel = cachedData['activity_level'];
          final dynamic allergiesRaw = cachedData['allergies'];
          if (allergiesRaw is List) {
            selectedAllergies = List<String>.from(allergiesRaw);
          } else if (allergiesRaw is String && allergiesRaw.trim().isNotEmpty) {
            selectedAllergies = [allergiesRaw];
          } else {
            selectedAllergies = [];
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
        await QuestionnaireProgressHelper.calculateProgress('activityLevel');
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
            currentStep: progressInfo?.currentStep ?? 9,
            totalSteps: progressInfo?.totalSteps ?? 10,
            progressValue: progressInfo?.progressValue ?? 0.9,
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
              _buildActivityLevelOptions(context),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomContinueButton(context),
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
                    "Which of the following best describes your activity level?",
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

  Widget _buildActivityLevelOptions(BuildContext context) {
    final List<Map<String, String>> activityLevels = [
      {
        'emoji': '🧎‍♀',
        'title': 'Sedentary / Mostly sitting',
        'description': 'Little to no exercise',
      },
      {
        'emoji': '🚶‍♂',
        'title': 'Daily commuting',
        'description': 'Light physical activity',
      },
      {
        'emoji': '🏃‍♀',
        'title': 'Occasional exercise',
        'description': '1-3 times per week',
      },
      {
        'emoji': '🤸‍♀️',
        'title': 'Regular light exercise',
        'description': '3-5 times per week',
      },
      {
        'emoji': '🚴‍♂',
        'title': 'Regular high-intensity exercise',
        'description': '6+ times per week',
      },
    ];

    return Column(
      spacing: 12.h,
      children: activityLevels.map((level) {
        return _buildActivityLevelCard(
          context,
          level['emoji']!,
          level['title']!,
          level['description']!,
        );
      }).toList(),
    );
  }

  Widget _buildActivityLevelCard(
    BuildContext context,
    String emoji,
    String title,
    String description,
  ) {
    bool isSelected = selectedActivityLevel == title;

    return GestureDetector(
      onTap: () => _onActivityLevelSelected(title),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(164, 1.0),
            end: Alignment(164, -1.0),
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
            topRight: Radius.circular(0.h),
            topLeft: Radius.circular(20.h),
            bottomLeft: Radius.circular(20.h),
            bottomRight: Radius.circular(20.h),
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(0, 4.h),
              blurRadius: 13.9.h,
            ),
          ],
        ),
        child: Row(
          children: [
            // Emoji图标
            Text(
              emoji,
              style: TextStyle(
                fontSize: 25.h,
              ),
            ),
            SizedBox(width: 16.h),
            // 文字内容
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyleHelper.instance.title18SemiBoldPingFangSC
                        .copyWith(
                      color: isSelected ? Color(0xFFFFFFFF) : Color(0xFF30332D),
                      height: 1.29,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyleHelper.instance.title18MediumPingFangSC
                          .copyWith(
                        color: isSelected
                            ? Color(0xFFFFFFFF).withValues(alpha: 0.9)
                            : appTheme.gray_500,
                        height: 1.3,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContinueButton(BuildContext context) {
    bool canContinue =
        selectedActivityLevel != null && selectedActivityLevel!.isNotEmpty;

    return Container(
      height: 100.h,
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        color: Color(0xFFFCFCFC),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF888888),
            offset: Offset(0, -4.h),
            blurRadius: 18.h,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: canContinue ? () => _onContinuePressed(context) : null,
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: canContinue
                ? LinearGradient(
                    begin: Alignment(-0.97, -0.24),
                    end: Alignment(0.97, 0.24),
                    colors: [
                      Color(0xFFD0F077),
                      Color(0xFFC8FD00),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      appTheme.gray_400,
                      appTheme.gray_400,
                    ],
                  ),
            borderRadius: BorderRadius.circular(12.h),
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
              "Continue",
              style:
                  TextStyleHelper.instance.title18SemiBoldPingFangSC.copyWith(
                color: canContinue ? Color(0xFFFFFFFF) : Color(0xFFABABAB),
                height: 1.44,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveActivityLevelData() async {
    try {
      await UserDataCache.saveUserProfile(
        activityLevel: selectedActivityLevel,
      );
      print('活动水平数据已保存到缓存: $selectedActivityLevel');
    } catch (e) {
      print('保存活动水平数据到缓存失败: $e');
      rethrow;
    }
  }

  void _onActivityLevelSelected(String activityLevel) {
    setState(() {
      selectedActivityLevel = activityLevel;
    });
  }

  void _onContinuePressed(BuildContext context) async {
    if (selectedActivityLevel == null || selectedActivityLevel!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select your activity level to continue'),
          backgroundColor: appTheme.redCustom,
        ),
      );
      return;
    }

    // 保存数据
    await _saveActivityLevelData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great! Your activity level has been saved.'),
        backgroundColor: appTheme.colorFF52D1,
        duration: Duration(seconds: 2),
      ),
    );

    // 导航到注册完成页面
    if (mounted) {
      Navigator.of(context).pushNamed(AppRoutes.registrationCompleteScreen);
    }
  }
}
