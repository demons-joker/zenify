import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../widgets/bottom_input_section.dart';
import '../../widgets/custom_image_view.dart';
import '../../widgets/custom_progress_app_bar.dart';

class ThirdQuestionScreen extends StatefulWidget {
  const ThirdQuestionScreen({super.key});

  @override
  State<ThirdQuestionScreen> createState() => _ThirdQuestionScreenState();
}

class _ThirdQuestionScreenState extends State<ThirdQuestionScreen> {
  final TextEditingController _addMoreController = TextEditingController();
  String? selectedOption;
  String? mainGoal;

  @override
  void initState() {
    super.initState();
    _loadCachedData();
  }

  Future<void> _loadCachedData() async {
    try {
      final cachedData = await UserDataCache.getUserProfile();
      if (cachedData.isNotEmpty) {
        setState(() {
          mainGoal = cachedData['main_goal'];
          if (cachedData['chronic_disease'] != null) {
            selectedOption = cachedData['chronic_disease'];
          }
        });
        print('已加载缓存数据: $cachedData');
      }
    } catch (e) {
      print('加载缓存数据失败: $e');
    }
  }

  // 第三个页面专门处理慢性病，如果不是慢性病路径则不显示内容
  bool get isChronicDiseaseRoute => mainGoal == 'Chronic Disease';

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
            currentStep: 3,
            totalSteps: 10,
            progressValue: 0.3,
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
              _buildChronicDiseaseOptions(context),
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
              selectedOption = value;
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
                    "🏥 What kind of disease is it? Could you elaborate on it?",
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

  Widget _buildChronicDiseaseOptions(BuildContext context) {
    final List<String> diseases = [
      'Diabetes',
      'Hypertension',
      'Heart Disease',
      'Arthritis',
      'Asthma',
      'COPD',
      'Osteoporosis',
      'Depression',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.h,
        childAspectRatio: 2.5,
      ),
      itemCount: diseases.length,
      itemBuilder: (context, index) {
        return _buildDiseaseOption(context, diseases[index]);
      },
    );
  }

  Widget _buildDiseaseOption(BuildContext context, String diseaseText) {
    bool isSelected = selectedOption == diseaseText;

    return GestureDetector(
      onTap: () => _onDiseaseSelected(diseaseText),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 8.h,
          horizontal: diseaseText == 'Osteoporosis' || diseaseText == 'Depression'
              ? 14.h
              : diseaseText == 'Hypertension' || diseaseText == 'Arthritis'
                  ? 20.h
                  : 24.h,
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
            diseaseText,
            style: TextStyleHelper.instance.title18SemiBoldPingFangSC.copyWith(
                height: 1.44,
                color: isSelected ? Color(0xFFFFFFFF) : Color(0xFF30322D)),
          ),
        ),
      ),
    );
  }



  void _onDiseaseSelected(String disease) {
    setState(() {
      selectedOption = disease;
      _addMoreController.clear();
    });
  }



  Future<void> _saveData() async {
    try {
      // 保存慢性病信息
      await UserDataCache.saveUserProfile(
        chronicDisease: selectedOption,
      );
      print('慢性病数据已保存到缓存: $selectedOption');
    } catch (e) {
      print('保存数据到缓存失败: $e');
      rethrow;
    }
  }

  void _onContinuePressed(BuildContext context) async {
    if (selectedOption != null && selectedOption!.isNotEmpty) {
      // 保存数据
      await _saveData();

      // 清空输入框
      _addMoreController.clear();

      // Show success message and navigate
      if (!mounted) return;
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Information saved! Let\'s continue with the setup.'),
            backgroundColor: appTheme.colorFF52D1,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Navigate to next screen (偏好选择页面)
      if (mounted && context.mounted) {
        Navigator.of(context).pushNamed(AppRoutes.preferenceSelectionScreen);
      }
    } else {
      if (!mounted) return;

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select an option to continue'),
            backgroundColor: appTheme.redCustom,
          ),
        );
      }
    }
  }
}