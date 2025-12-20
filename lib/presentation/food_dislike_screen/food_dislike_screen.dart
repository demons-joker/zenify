import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../utils/questionnaire_progress_helper.dart';
import '../../widgets/custom_gradient_text_field.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_progress_app_bar.dart';

class FoodDislikeScreen extends StatefulWidget {
  const FoodDislikeScreen({super.key});

  @override
  State<FoodDislikeScreen> createState() => _FoodDislikeScreenState();
}

class _FoodDislikeScreenState extends State<FoodDislikeScreen> {
  final TextEditingController _dislikeController = TextEditingController();
  String? mainGoal;
  String? chronicDisease;
  String? preference;
  String? foodSource;
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
          foodSource = cachedData['food_source'];
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
    final progress = await QuestionnaireProgressHelper.calculateProgress('foodDislike');
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
            currentStep: progressInfo?.currentStep ?? 5,
            totalSteps: progressInfo?.totalSteps ?? 10,
            progressValue: progressInfo?.progressValue ?? 0.5,
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
              _buildDislikeInputSection(context),
              // _buildSkipButton(context),
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
                    "What foods do you dislike?",
                    style: TextStyleHelper.instance.title20SemiBoldPingFangSC
                        .copyWith(color: appTheme.gray_900, height: 1.4),
                  ),
                ),
                SizedBox(height: 8.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.h),
                  child: Text(
                    "Optional: Tell us what you don't like to eat",
                    style: TextStyleHelper.instance.body12SemiBoldPingFangSC
                        .copyWith(color: appTheme.gray_500, height: 1.4),
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

  Widget _buildDislikeInputSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.0, -1.0),
          end: Alignment(0.0, 1.0),
          colors: [Color(0xFFFDF8F5), Color(0xFFF2F5F6)],
        ),
        border: Border.all(color: appTheme.white_A700, width: 2.h),
        borderRadius: BorderRadius.circular(20.h),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF888888),
            offset: Offset(0, 4.h),
            blurRadius: 13.h,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "List foods you dislike (separate with commas)",
            style: TextStyleHelper.instance.body12SemiBoldPingFangSC
                .copyWith(color: appTheme.blue_gray_900_01, height: 1.4),
          ),
          SizedBox(height: 16.h),
          CustomGradientTextField(
            controller: _dislikeController,
            placeholder: "e.g., mushrooms, cilantro, spicy food",
            keyboardType: TextInputType.text,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomContinueButton(BuildContext context) {
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
        onTap: () => _onContinuePressed(context),
        child: Container(
          width: double.infinity,
          height: 56.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-0.97, -0.24),
              end: Alignment(0.97, 0.24),
              colors: [
                Color(0xFFD0F077),
                Color(0xFFC8FD00),
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
              "Skip for now",
              style: TextStyleHelper.instance.title18SemiBoldPingFangSC
                  .copyWith(color: Color(0xFFFFFFFF), height: 1.44),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDislikeData() async {
    try {
      final dislikeText = _dislikeController.text.trim();
      await UserDataCache.saveUserProfile(
        foodDislikes: dislikeText.isEmpty ? null : dislikeText,
      );
      print('不喜欢的食物数据已保存到缓存: ${dislikeText.isEmpty ? "无" : dislikeText}');
    } catch (e) {
      print('保存不喜欢的食物数据到缓存失败: $e');
      rethrow;
    }
  }

  void _onSkipPressed(BuildContext context) async {
    // 清空输入框并保存空数据
    _dislikeController.clear();
    await _saveDislikeData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Skipped! You can always update your preferences later.'),
        backgroundColor: appTheme.colorFF52D1,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to next screen
    if (mounted) {
      Navigator.of(context).pushNamed(AppRoutes.eatingStyleScreen);
    }
  }

  void _onContinuePressed(BuildContext context) async {
    // 保存数据（允许为空）
    final dislikeText = _dislikeController.text.trim();
    await _saveDislikeData();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(dislikeText.isEmpty
            ? 'No preferences saved. Let\'s continue!'
            : 'Thanks! We\'ll remember your preferences.'),
        backgroundColor: appTheme.colorFF52D1,
        duration: Duration(seconds: 2),
      ),
    );

    // Navigate to next screen
    if (mounted) {
      Navigator.of(context).pushNamed(AppRoutes.eatingStyleScreen);
    }
  }

  @override
  void dispose() {
    _dislikeController.dispose();
    super.dispose();
  }
}
