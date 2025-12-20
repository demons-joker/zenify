import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../utils/questionnaire_progress_helper.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_progress_app_bar.dart';

class EatingStyleScreen extends StatefulWidget {
  const EatingStyleScreen({super.key});

  @override
  State<EatingStyleScreen> createState() => _EatingStyleScreenState();
}

class _EatingStyleScreenState extends State<EatingStyleScreen> {
  String? selectedEatingStyle;
  String? mainGoal;
  String? chronicDisease;
  String? preference;
  String? foodSource;
  String? foodDislikes;
  bool isFromChronicDisease = false;
  ProgressInfo? progressInfo;

  // 根据用户路径计算当前步骤
  int get currentStep {
    int baseStep = isFromChronicDisease ? 6 : 5;
    // 如果有不喜欢的食物数据，说明经过了食物不喜欢的页面
    if (foodDislikes != null) {
      return baseStep + 1;
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
          selectedEatingStyle = cachedData['eating_style'];
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
    final progress = await QuestionnaireProgressHelper.calculateProgress('eatingStyle');
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
            currentStep: progressInfo?.currentStep ?? 6,
            totalSteps: progressInfo?.totalSteps ?? 10,
            progressValue: progressInfo?.progressValue ?? 0.6,
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
              _buildEatingStyleOptions(context),
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
                    "Which eating style is closest to your usual meals?",
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

  Widget _buildEatingStyleOptions(BuildContext context) {
    final List<Map<String, String>> eatingStyles = [
      {
        'title': 'Meat-heavy',
        'image': 'assets/images/eating_styles/meat_heavy-1c0812.png',
      },
      {
        'title': 'Balanced',
        'image': 'assets/images/eating_styles/balanced-54c079.png',
      },
      {
        'title': 'Carb-heavy',
        'image': 'assets/images/eating_styles/carb_heavy-7ff457.png',
      },
    ];

    return Column(
      children: [
        // 第一行：前两个选项
        Row(
          children: [
            Expanded(
              child: _buildEatingStyleCard(
                context,
                eatingStyles[0]['title']!,
                eatingStyles[0]['image']!,
              ),
            ),
            SizedBox(width: 10.h),
            Expanded(
              child: _buildEatingStyleCard(
                context,
                eatingStyles[1]['title']!,
                eatingStyles[1]['image']!,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        // 第二行：第三个选项
        _buildEatingStyleCard(
          context,
          eatingStyles[2]['title']!,
          eatingStyles[2]['image']!,
          isFullWidth: true,
        ),
      ],
    );
  }

  Widget _buildEatingStyleCard(
    BuildContext context,
    String title,
    String imagePath, {
    bool isFullWidth = false,
  }) {
    bool isSelected = selectedEatingStyle == title;
    
    return GestureDetector(
      onTap: () => _onEatingStyleSelected(title),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        height: isFullWidth ? 200.h : 198.h,
        decoration: BoxDecoration(
          color: Color(0xFF0F0F0F),
          borderRadius: BorderRadius.circular(20.h),
          boxShadow: [
            BoxShadow(
              color: Color(0x33000000),
              offset: Offset(2, 2.h),
              blurRadius: 8.7.h,
            ),
          ],
          border: isSelected 
              ? Border.all(color: Color(0xFF52D1C6), width: 3.h)
              : null,
        ),
        child: Stack(
          children: [
            // 背景图片
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.h),
                child: CustomImageView(
                  imagePath: imagePath,
                  fit: BoxFit.cover,
                  height: double.infinity,
                  width: double.infinity,
                ),
              ),
            ),
            // 渐变遮罩
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.h),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.3),
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),
            // 标题
            Positioned(
              bottom: 20.h,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  title,
                  style: TextStyleHelper.instance.title18SemiBoldPingFangSC.copyWith(
                    color: Color(0xFFFFFFFF),
                    height: 1.44,
                  ),
                ),
              ),
            ),
            // 选中标记
            if (isSelected)
              Positioned(
                top: 10.h,
                right: 10.h,
                child: Container(
                  width: 24.h,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Color(0xFF52D1C6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16.h,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomContinueButton(BuildContext context) {
    bool canContinue = selectedEatingStyle != null && selectedEatingStyle!.isNotEmpty;
    
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
              style: TextStyleHelper.instance.title18SemiBoldPingFangSC.copyWith(
                color: canContinue ? Color(0xFFFFFFFF) : Color(0xFFABABAB),
                height: 1.44,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveEatingStyleData() async {
    try {
      await UserDataCache.saveUserProfile(
        eatingStyle: selectedEatingStyle,
      );
      print('饮食风格数据已保存到缓存: $selectedEatingStyle');
    } catch (e) {
      print('保存饮食风格数据到缓存失败: $e');
      rethrow;
    }
  }

  void _onEatingStyleSelected(String eatingStyle) {
    setState(() {
      selectedEatingStyle = eatingStyle;
    });
  }

  void _onContinuePressed(BuildContext context) async {
    if (selectedEatingStyle == null || selectedEatingStyle!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an eating style to continue'),
          backgroundColor: appTheme.redCustom,
        ),
      );
      return;
    }

    // 保存数据
    await _saveEatingStyleData();

    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Great choice! Your eating style has been saved.'),
        backgroundColor: appTheme.colorFF52D1,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to eating routine screen
    if (mounted) {
      Navigator.of(context).pushNamed(AppRoutes.eatingRoutineScreen);
    }
  }
}