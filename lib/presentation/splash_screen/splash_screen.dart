import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_image_view.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFDF8F5),
                  appTheme.gray_50_02,
                ],
                stops: [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildMainContentStack(context),
                    _buildBottomSection(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMainContentStack(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 572.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 12.h),
              child: CustomImageView(
                imagePath: ImageConstant.img34x1,
                height: 32.h,
                width: 96.h,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 468.h,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: CustomImageView(
                      imagePath: ImageConstant.img24x2,
                      height: 296.h,
                      width: double.infinity,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 468.h,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: CustomImageView(
                            imagePath: ImageConstant.img24x3,
                            height: 314.h,
                            width: double.infinity,
                          ),
                        ),
                        CustomImageView(
                          imagePath: ImageConstant.img24x4,
                          height: 314.h,
                          width: double.infinity,
                        ),
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            margin: EdgeInsets.only(top: 26.h),
                            width: 242.h,
                            height: 276.h,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: 230.h,
                                    height: 218.h,
                                    decoration: BoxDecoration(
                                      color: appTheme.lime_A400,
                                      borderRadius:
                                          BorderRadius.circular(108.h),
                                      border: Border.all(
                                        width: 2.h,
                                        color: appTheme.lime_A400,
                                      ),
                                    ),
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 226.h,
                                      height: 226.h,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(112.h),
                                      ),
                                      child: CustomImageView(
                                        imagePath: ImageConstant.imgBlack900,
                                        height: 226.h,
                                        width: 226.h,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                        left: 4.h,
                                        right: 6.h,
                                        top: 2.h,
                                      ),
                                      child: CustomImageView(
                                        imagePath: ImageConstant.imgLogo3,
                                        height: 48.h,
                                        width: 228.h,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 14.h,
        left: 24.h,
        right: 22.h,
      ),
      padding: EdgeInsets.symmetric(horizontal: 22.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: appTheme.color1CC8FD,
        borderRadius: BorderRadius.circular(76.h),
        border: Border.all(
          color: appTheme.white_A700,
          width: 1.h,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLetStartButton(context),
          SizedBox(height: 10.h),
          Text(
            "Don't have an account?",
            style: TextStyleHelper.instance.title16RegularSegoeUISymbol,
          ),
          SizedBox(height: 8.h),
          GestureDetector(
            onTap: () => _onTapRegisterNow(context),
            child: Text(
              "Register now",
              style: TextStyleHelper.instance.title16RegularSegoeUISymbol
                  .copyWith(color: appTheme.light_green_A700),
            ),
          ),
          SizedBox(height: 54.h),
        ],
      ),
    );
  }

  Widget _buildLetStartButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.h),
      decoration: BoxDecoration(
        color: appTheme.color1CC8FD,
        borderRadius: BorderRadius.circular(70.h),
        border: Border.all(
          color: appTheme.white_A700,
          width: 1.h,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: appTheme.lime_A400,
          borderRadius: BorderRadius.circular(64.h),
          border: Border.all(
            width: 2.h,
            color: appTheme.lime_A400,
          ),
          boxShadow: [
            BoxShadow(
              color: appTheme.blue_gray_400_19,
              offset: Offset(6, 6),
              blurRadius: 15.h,
            ),
          ],
        ),
        child: Material(
          color: appTheme.transparentCustom,
          child: InkWell(
            borderRadius: BorderRadius.circular(64.h),
            onTap: () => _onTapLetsStart(context),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 48.h,
                vertical: 48.h,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: appTheme.color190000,
                          offset: Offset(1, 1),
                          blurRadius: 4.h,
                        ),
                      ],
                    ),
                    child: Text(
                      "Let's start",
                      style:
                          TextStyleHelper.instance.headline27SemiBoldPingFangSC,
                    ),
                  ),
                  SizedBox(width: 8.h),
                  CustomImageView(
                    imagePath: ImageConstant.imgMargin,
                    height: 20.h,
                    width: 24.h,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onTapLetsStart(BuildContext context) {
    Navigator.of(context).pushNamed(AppRoutes.onboardingScreen);
  }

  void _onTapRegisterNow(BuildContext context) {
    // Registration functionality can be implemented here
    // For now, navigating to onboarding screen
    Navigator.of(context).pushNamed(AppRoutes.onboardingScreen);
  }
}
