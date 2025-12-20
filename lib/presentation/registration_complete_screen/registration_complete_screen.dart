import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../services/user_data_cache.dart';
import '../../widgets/custom_image_view.dart';

class RegistrationCompleteScreen extends StatefulWidget {
  const RegistrationCompleteScreen({super.key});

  @override
  State<RegistrationCompleteScreen> createState() => _RegistrationCompleteScreenState();
}

class _RegistrationCompleteScreenState extends State<RegistrationCompleteScreen> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFCFC),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Color(0xFF30332D),
            size: 24.h,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.h),
          child: Column(
            children: [
              SizedBox(height: 32.h),
              _buildCelebrationSection(context),
              SizedBox(height: 32.h),
              _buildTitleSection(context),
              SizedBox(height: 20.h),
              _buildDescriptionSection(context),
              SizedBox(height: 60.h),
              _buildCheersButton(context),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCelebrationSection(BuildContext context) {
    return SizedBox(
      height: 200.h,
      child: CustomImageView(
        imagePath: ImageConstant.imgBlack900,
        height: 174.h,
        width: 174.h,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    return Text(
      "You're All Set,\nFriend!",
      style: TextStyle(
        fontSize: 33.fSize,
        fontWeight: FontWeight.w600,
        fontFamily: 'PingFang SC',
        color: Color(0xFF30332D),
        height: 0.67,
        letterSpacing: -0.24,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      child: Text(
        "Your personalized nutrition journey is about to begin. Get ready to discover delicious, healthy meals tailored just for you!",
        style: TextStyle(
          fontSize: 14.fSize,
          fontWeight: FontWeight.w400,
          fontFamily: 'PingFang SC',
          color: Color(0xFFABAFA7),
          height: 1.57,
          letterSpacing: -0.57,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCheersButton(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : () => _onCheersPressed(context),
      child: Container(
        width: 200.h,
        height: 60.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-13, 1.0),
            end: Alignment(-13, -1.0),
            colors: [
              Color(0xFFD0F077),
              Color(0xFFC8FD00),
            ],
          ),
          borderRadius: BorderRadius.circular(30.h),
          border: Border.all(
            color: Color(0xFFC8FD00),
            width: 1.3.h,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              offset: Offset(0, 4.h),
              blurRadius: 4.h,
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20.h,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.h,
                  ),
                )
              : Text(
                  "Cheers!",
                  style: TextStyle(
                    fontSize: 22.fSize,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'PingFang SC',
                    color: Color(0xFF162716),
                    height: 1.4,
                  ),
                ),
        ),
      ),
    );
  }

  Future<void> _markRegistrationComplete() async {
    try {
      await UserDataCache.markOnboardingComplete();
      print('注册流程已完成');
    } catch (e) {
      print('标记注册流程完成失败: $e');
    }
  }

  void _onCheersPressed(BuildContext context) async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      // 标记注册流程完成
      await _markRegistrationComplete();

      if (!mounted) return;

      // 显示成功消息
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome! Your personalized journey begins now!'),
          backgroundColor: appTheme.colorFF52D1,
          duration: Duration(seconds: 2),
        ),
      );

      // 短暂延迟后导航到主页
      await Future.delayed(Duration(milliseconds: 500));

      if (!mounted) return;

      // 导航到主页，替换当前路由栈
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.mainPage,
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Something went wrong. Please try again.'),
          backgroundColor: appTheme.redCustom,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}