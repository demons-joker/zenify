import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../utils/questionnaire_progress_helper.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_gradient_text_field.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_progress_app_bar.dart';

class UserProfileSetupScreen extends StatefulWidget {
  const UserProfileSetupScreen({super.key});

  @override
  State<UserProfileSetupScreen> createState() => _UserProfileSetupScreenState();
}

class _UserProfileSetupScreenState extends State<UserProfileSetupScreen> {
  final TextEditingController ageController = TextEditingController(text: "");
  final TextEditingController weightController =
      TextEditingController(text: "");
  final TextEditingController heightController =
      TextEditingController(text: "");
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedGender = "Female"; // Default selection for better UX
  String selectedWeight = ""; // Default weight
  String selectedHeight = ""; // Default height
  String selectedAge = ""; // Default age
  
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
          selectedGender = cachedData['gender'] ?? selectedGender;
          selectedWeight = cachedData['weight'] ?? selectedWeight;
          selectedHeight = cachedData['height'] ?? selectedHeight;
          selectedAge = cachedData['age'] ?? selectedAge;
          ageController.text = selectedAge;
          weightController.text = selectedWeight;
          heightController.text = selectedHeight;
        });
        print('已加载缓存数据: $cachedData');
      }
    } catch (e) {
      print('加载缓存数据失败: $e');
    }
  }

  Future<void> _updateProgress() async {
    final progress = await QuestionnaireProgressHelper.calculateProgress('userProfile');
    setState(() {
      progressInfo = progress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appTheme.gray_50_02,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.h),
        child: progressInfo != null ? CustomProgressAppBar(
          leadingIcon: ImageConstant.imgVector,
          onLeadingPressed: () => Navigator.pop(context),
          currentStep: progressInfo!.currentStep,
          totalSteps: progressInfo!.totalSteps,
          progressValue: progressInfo!.progressValue,
        ) : CustomProgressAppBar(
          leadingIcon: ImageConstant.imgVector,
          onLeadingPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 14.h,
              right: 14.h,
              top: 8.h,
              bottom: 120.h, // 为底部按钮留出空间
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMascotSection(context),
                SizedBox(height: 100.h), // 减少间距
                _buildGenderSection(context),
                SizedBox(height: 24.h), // 减少间距
                _buildWeightHeightSection(context),
                SizedBox(height: 16.h), // 减少间距
                _buildAgeSection(context),
                SizedBox(height: 20.h), // 减少底部间距
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildContinueButton(context),
    );
  }

  Widget _buildMascotSection(BuildContext context) {
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
              child: Hero(
                tag: 'mascotHero',
                child: CustomImageView(
                  imagePath: ImageConstant.figmaMascot,
                  height: 174.h,
                  width: 174.h,
                  fit: BoxFit.contain,
                ),
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
                    "First, let's cover the basics, What's your gender and age?",
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

  Widget _buildGenderSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.h),
          child: Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.img1,
                height: 28.h,
                width: 28.h,
              ),
              Text(
                "GENDER",
                style: TextStyleHelper.instance.title18MediumPingFangSC
                    .copyWith(height: 1.44),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        _buildGenderTabs(context),
      ],
    );
  }

  Widget _buildGenderTabs(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.0, -1.0),
          end: Alignment(0.0, 1.0),
          colors: [Color(0xFFFDF8F5), Color(0xFFF2F5F6)],
        ),
        border: Border.all(color: appTheme.white_A700, width: 2.h),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.h),
          bottomLeft: Radius.circular(20.h),
          bottomRight: Radius.circular(20.h),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.h, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => _onGenderSelected("Male"),
            child: _buildGenderOption("Male", selectedGender == "Male"),
          ),
          GestureDetector(
            onTap: () => _onGenderSelected("Female"),
            child: _buildGenderOption("Female", selectedGender == "Female"),
          ),
          GestureDetector(
            onTap: () => _onGenderSelected("other"),
            child: _buildGenderOption("other", selectedGender == "other"),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String text, bool isSelected) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 16.h, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected
            ? Color(0xFFC8FD00).withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12.h),
      ),
      child: Text(
        text,
        style: TextStyleHelper.instance.title20PingFangSC.copyWith(
          color: isSelected ? Color(0xFF30322D) : appTheme.gray_400_01,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildWeightHeightSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 54,
          child: _buildWeightColumn(context),
        ),
        SizedBox(width: 15.h),
        Expanded(
          flex: 46,
          child: _buildHeightColumn(context),
        ),
      ],
    );
  }

  Widget _buildWeightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.h),
          child: Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgLime500,
                height: 28.h,
                width: 28.h,
              ),
              Text(
                "WEIGHT",
                style: TextStyleHelper.instance.title18MediumPingFangSC
                    .copyWith(height: 1.44),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.0],
              colors: [
                Color(0xFFFDF8F5),
                appTheme.gray_100_03,
              ],
            ),
            border: Border.all(
              color: appTheme.white_A700,
              width: 2.h,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.h),
              topRight: Radius.circular(0.h),
              bottomLeft: Radius.circular(20.h),
              bottomRight: Radius.circular(20.h),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your weight';
                    }
                    double? weight = double.tryParse(value);
                    if (weight == null || weight < 20 || weight > 200) {
                      return 'Please enter a valid weight (20-200 kg)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedWeight = value;
                    });
                  },
                  style: TextStyleHelper.instance.title20SemiBoldPingFangSC
                      .copyWith(height: 1.4),
                  decoration: InputDecoration(
                    hintStyle: TextStyleHelper
                        .instance.title20SemiBoldPingFangSC
                        .copyWith(height: 1.4),
                    contentPadding: EdgeInsets.only(
                      top: 12.h,
                      bottom: 12.h,
                      left: 30.h,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 24.h),
                child: Text(
                  'kg',
                  style: TextStyleHelper.instance.title20SemiBoldPingFangSC
                      .copyWith(
                    color: appTheme.gray_400_01,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeightColumn(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.h),
          child: Row(
            children: [
              CustomImageView(
                imagePath: ImageConstant.img1Lime500,
                height: 28.h,
                width: 28.h,
              ),
              Text(
                "HEIGHT",
                style: TextStyleHelper.instance.title18MediumPingFangSC
                    .copyWith(height: 1.44),
              ),
            ],
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 1.0],
              colors: [
                Color(0xFFFDF8F5),
                appTheme.gray_100_03,
              ],
            ),
            border: Border.all(
              color: appTheme.white_A700,
              width: 2.h,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.h),
              topRight: Radius.circular(0.h),
              bottomLeft: Radius.circular(20.h),
              bottomRight: Radius.circular(20.h),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: heightController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your height';
                    }
                    double? height = double.tryParse(value);
                    if (height == null || height < 100 || height > 250) {
                      return 'Please enter a valid height (100-250 cm)';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      selectedHeight = value;
                    });
                  },
                  style: TextStyleHelper.instance.title20SemiBoldPingFangSC
                      .copyWith(height: 1.4),
                  decoration: InputDecoration(
                    hintStyle: TextStyleHelper
                        .instance.title20SemiBoldPingFangSC
                        .copyWith(height: 1.4),
                    contentPadding: EdgeInsets.only(
                      top: 12.h,
                      bottom: 12.h,
                      left: 30.h,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 24.h),
                child: Text(
                  'cm',
                  style: TextStyleHelper.instance.title20SemiBoldPingFangSC
                      .copyWith(
                    color: appTheme.gray_400_01,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAgeSection(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.46,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AGE",
            style: TextStyleHelper.instance.title18MediumPingFangSC
                .copyWith(height: 1.44),
          ),
          SizedBox(height: 2.h),
          CustomGradientTextField(
            controller: ageController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              setState(() {
                selectedAge = value;
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your age';
              }
              int? age = int.tryParse(value);
              if (age == null || age < 1 || age > 120) {
                return 'Please enter a valid age (1-120)';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 38.h, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: Offset(0, -2.h),
            blurRadius: 10.h,
          ),
        ],
      ),
      child: CustomButton(
        text: "Continue",
        width: double.infinity,
        rightIcon: ImageConstant.imgMargin,
        onPressed: () => _onContinuePressed(context),
      ),
    );
  }

  void _onGenderSelected(String gender) {
    setState(() {
      selectedGender = gender;
    });
  }

  Future<void> _saveUserProfileData() async {
    try {
      // 保存到本地缓存
      await UserDataCache.saveUserProfile(
        gender: selectedGender,
        weight: selectedWeight,
        height: selectedHeight,
        age: selectedAge,
      );

      print('用户资料已保存到缓存');
    } catch (e) {
      print('保存用户资料到缓存失败: $e');
      rethrow;
    }
  }

  void _onContinuePressed(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Save data to database
      await _saveUserProfileData();

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Basic information saved! Let\'s continue with the setup.'),
          backgroundColor: appTheme.colorFF52D1,
          duration: Duration(seconds: 2),
        ),
      );

      // Navigate to next screen
      Navigator.of(context).pushNamed(AppRoutes.goalSelectionScreen);
    } else {
      // Show validation error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please complete all required fields'),
          backgroundColor: appTheme.redCustom,
        ),
      );
    }
  }
}
