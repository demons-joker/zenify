import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../utils/questionnaire_progress_helper.dart';
import '../../widgets/bottom_input_section.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_progress_app_bar.dart';

class PreferenceSelectionScreen extends StatefulWidget {
  const PreferenceSelectionScreen({super.key});

  @override
  State<PreferenceSelectionScreen> createState() => _PreferenceSelectionScreenState();
}

class _PreferenceSelectionScreenState extends State<PreferenceSelectionScreen> {
  final TextEditingController _addMoreController = TextEditingController();
  String? selectedPreference;
  String? mainGoal;
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
          isFromChronicDisease = mainGoal == 'Chronic Disease' && 
                                cachedData['chronic_disease'] != null;
        });
        print('已加载缓存数据: $cachedData');
      }
    } catch (e) {
      print('加载缓存数据失败: $e');
    }
  }

  Future<void> _updateProgress() async {
    final progress = await QuestionnaireProgressHelper.calculateProgress('preference');
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
          child: progressInfo != null ? CustomProgressAppBar(
            leadingIcon: ImageConstant.imgVector,
            onLeadingPressed: () => Navigator.of(context).pop(),
            currentStep: progressInfo!.currentStep,
            totalSteps: progressInfo!.totalSteps,
            progressValue: progressInfo!.progressValue,
            backgroundColor: Color(0x9EFFFFFF),
            progressBackgroundColor: Color(0xFFF7F4F3),
            progressColor: Color(0xFF52D1C6),
            stepTextColor: Color(0xFFABABAB),
            iconBackgroundColor: Color(0xFFF8F8F8),
            showShadow: true,
            height: 80.h,
          ) : CustomProgressAppBar(
            leadingIcon: ImageConstant.imgVector,
            onLeadingPressed: () => Navigator.of(context).pop(),
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
              _buildPreferenceOptions(context),
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
              selectedPreference = value;
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
                    "Which do you prefer? 🥰",
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

  Widget _buildPreferenceOptions(BuildContext context) {
    final List<String> preferences = [
      'Quick weight loss',
      'build better habits',
    ];

    return Column(
      children: preferences.map((preference) {
        bool isSelected = selectedPreference == preference;
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: GestureDetector(
            onTap: () => _onPreferenceSelected(preference),
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
                  preference,
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

  void _onPreferenceSelected(String preference) {
    setState(() {
      selectedPreference = preference;
      _addMoreController.clear();
    });
  }

  Future<void> _savePreferenceData() async {
    try {
      await UserDataCache.saveUserProfile(
        preference: selectedPreference,
      );
      print('偏好数据已保存到缓存: $selectedPreference');
    } catch (e) {
      print('保存偏好数据到缓存失败: $e');
      rethrow;
    }
  }

  void _onContinuePressed(BuildContext context) async {
    if (selectedPreference != null && selectedPreference!.isNotEmpty) {
      // 保存数据
      await _savePreferenceData();

      // 清空输入框
      _addMoreController.clear();

      // Show success message and navigate
      if (!mounted) return;
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Preference saved! Let\'s continue with the setup.'),
            backgroundColor: appTheme.colorFF52D1,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to next screen
      if (mounted && context.mounted) {
        Navigator.of(context).pushNamed(AppRoutes.foodSourceSelectionScreen);
      }
    } else {
      if (!mounted) return;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a preference to continue'),
            backgroundColor: appTheme.redCustom,
          ),
        );
      }
    }
  }
}