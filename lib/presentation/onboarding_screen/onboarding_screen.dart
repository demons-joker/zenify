import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_image_view.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return Scaffold(
          backgroundColor: appTheme.gray_50_01,
          body: Container(
            decoration: BoxDecoration(
              color: appTheme.gray_50_01,
              boxShadow: [
                BoxShadow(
                  color: appTheme.color3F0000,
                  offset: Offset(0, 4.h),
                  blurRadius: 4.h,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(top: 22.h),
                child: Column(
                  children: [
                    _buildNutribotIntroSection(context),
                    _buildUserTrustSection(context),
                    _buildCallToActionButton(context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutribotIntroSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.h),
      height: 226.h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 138.h,
              height: 130.h,
              margin: EdgeInsets.only(left: 84.h),
              decoration: BoxDecoration(
                color: appTheme.lime_A400,
                borderRadius: BorderRadius.circular(64.h),
                border: Border.all(
                  width: 2.h,
                  color: appTheme.transparentCustom,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: EdgeInsets.only(top: 4.h),
              child: CustomImageView(
                imagePath: ImageConstant.img,
                height: 210.h,
                width: 226.h,
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 10.h, vertical: 6.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.347, -0.938),
                  end: Alignment(-0.347, 0.938),
                  colors: [Color(0xFFFDF8F5), Color(0xFFF2F5F6)],
                ),
                borderRadius: BorderRadius.circular(20.h),
                border: Border.all(
                  width: 2.h,
                  color: appTheme.transparentCustom,
                ),
                boxShadow: [
                  BoxShadow(
                    color: appTheme.color88FF88,
                    offset: Offset(0, 4.h),
                    blurRadius: 16.h,
                  ),
                ],
              ),
              child: Text(
                "HI! I'm Nutribot,your personal nutrition guide.",
                style: TextStyleHelper.instance.title22SemiBoldPingFangSC
                    .copyWith(height: 1.36),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTrustSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: 444.h,
          height: 366.h,
          child: Stack(
            children: [
              _buildUserProfilesCard(),
              _buildProgressTrackingCard(),
              _buildFoodImagesCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfilesCard() {
    return Positioned(
      left: 16.h,
      top: 0,
      child: Container(
        width: 252.h,
        padding: EdgeInsets.symmetric(horizontal: 18.h, vertical: 4.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.163, -0.987),
            end: Alignment(-0.163, 0.987),
            colors: [Color(0xFFFDF8F5), Color(0xFFF2F5F6)],
          ),
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(width: 2.h, color: appTheme.white_A700),
          boxShadow: [
            BoxShadow(
              color: appTheme.color2D0000,
              offset: Offset(2.h, 4.h),
              blurRadius: 9.h,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12.h),
            Text(
              "A great many users trust us.",
              style: TextStyleHelper.instance.title18MediumPingFangSC
                  .copyWith(height: 1.39),
            ),
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 4.h),
              decoration: BoxDecoration(
                color: appTheme.gray_200_01,
                borderRadius: BorderRadius.circular(28.h),
                border: Border.all(width: 2.h, color: appTheme.white_A700),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgFrame2043683721,
                    height: 44.h,
                    width: 140.h,
                  ),
                  SizedBox(width: 2.h),
                  Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Text(
                      "+1K",
                      style: TextStyleHelper.instance.body13SemiBoldPingFangSC
                          .copyWith(height: 1.54),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTrackingCard() {
    return Positioned(
      left: 13.h,
      top: 107.h,
      child: Container(
        width: 384.h,
        height: 146.h,
        padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 6.h),
        decoration: BoxDecoration(
          color: appTheme.gray_900_01,
          borderRadius: BorderRadius.circular(20.h),
          boxShadow: [
            BoxShadow(
              color: appTheme.color2D0000,
              offset: Offset(2.h, 4.h),
              blurRadius: 9.h,
            ),
          ],
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                margin: EdgeInsets.only(top: 12.h, left: 8.h),
                child: Text(
                  " Upgrade from F level to A level ",
                  style: TextStyleHelper.instance.title18MediumPingFangSC
                      .copyWith(color: appTheme.gray_500_01, height: 1.06),
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: CustomImageView(
                imagePath: ImageConstant.imgFrame2043683797,
                height: 80.h,
                width: 268.h,
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                margin: EdgeInsets.only(bottom: 24.h),
                child: CustomButton(
                  text: "Health Level",
                  backgroundColor: appTheme.gray_800,
                  textColor: appTheme.lime_200,
                  borderRadius: 10,
                  padding: EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
                  textStyle: TextStyleHelper.instance.label8Regular,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin: EdgeInsets.only(right: 86.h),
                child: CustomImageView(
                  imagePath: ImageConstant.img1,
                  height: 38.h,
                  width: 38.h,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 10.h),
                child: CustomImageView(
                  imagePath: ImageConstant.imgLimeA400,
                  height: 24.h,
                  width: 24.h,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.only(bottom: 36.h, left: 8.h),
                child: Text(
                  "约为",
                  style: TextStyleHelper.instance.body14RegularPingFangSC
                      .copyWith(height: 1.43),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.only(left: 8.h),
                child: Text(
                  "80%",
                  style: TextStyleHelper.instance.headline28SemiBoldPingFangSC
                      .copyWith(height: 1.43),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                margin: EdgeInsets.only(bottom: 10.h, left: 78.h),
                child: Text(
                  "（USER）",
                  style: TextStyleHelper.instance.body12RegularPingFangSC
                      .copyWith(height: 1.42),
                ),
              ),
            ),
            Positioned(
              top: 135.h,
              right: 20.h,
              child: Container(
                width: 10.h,
                height: 10.h,
                decoration: BoxDecoration(
                  color: appTheme.gray_900_01,
                  borderRadius: BorderRadius.circular(4.h),
                  border: Border.all(width: 2.h, color: appTheme.white_A700_01),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodImagesCard() {
    return Positioned(
      left: 24.h,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.163, -0.987),
            end: Alignment(-0.163, 0.987),
            colors: [Color(0xFFFDF8F5), Color(0xFFF2F5F6)],
          ),
          borderRadius: BorderRadius.circular(20.h),
          border: Border.all(width: 2.h, color: appTheme.white_A700),
          boxShadow: [
            BoxShadow(
              color: appTheme.color2D0000,
              offset: Offset(2.h, 4.h),
              blurRadius: 9.h,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              margin: EdgeInsets.only(top: 16.h),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    width: 102.h,
                    height: 56.h,
                    padding: EdgeInsets.only(top: 6.h),
                    decoration: BoxDecoration(
                      color: appTheme.black_900_01,
                      borderRadius: BorderRadius.circular(28.h),
                      boxShadow: [
                        BoxShadow(
                          color: appTheme.color3F0000,
                          offset: Offset(0, 1.h),
                          blurRadius: 1.h,
                        ),
                      ],
                    ),
                    child: CustomImageView(
                      imagePath: ImageConstant.imgFrame2043683587,
                      height: 26.h,
                      width: 54.h,
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 8.h,
                    child: CustomImageView(
                      imagePath: ImageConstant.imgVector,
                      height: 58.h,
                      width: 56.h,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 242.h,
              height: 98.h,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      "A great many users trust us.",
                      style: TextStyleHelper.instance.title18MediumPingFangSC
                          .copyWith(height: 1.44),
                    ),
                  ),
                  Positioned(
                    bottom: 6.h,
                    right: 28.h,
                    child: CustomImageView(
                      imagePath: ImageConstant.imgImage681,
                      height: 66.h,
                      width: 66.h,
                      radius: BorderRadius.circular(8.h),
                    ),
                  ),
                  Positioned(
                    bottom: 2.h,
                    right: 75.h,
                    child: CustomImageView(
                      imagePath: ImageConstant.imgImage682,
                      height: 66.h,
                      width: 66.h,
                      radius: BorderRadius.circular(8.h),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 44.h,
                    child: CustomImageView(
                      imagePath: ImageConstant.imgImage68166x66,
                      height: 66.h,
                      width: 66.h,
                      radius: BorderRadius.circular(8.h),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallToActionButton(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(28.h, 58.h, 28.h, 24.h),
      child: CustomButton(
        text: " WHO ARE YOU？",
        backgroundColor: appTheme.lime_A400,
        textColor: appTheme.whiteCustom,
        width: double.infinity,
        borderRadius: 26,
        gradientBorder: LinearGradient(
          colors: [Color(0x0000C8FD), Color(0xFFC8FD00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: appTheme.color88FF88,
            offset: Offset(0, 4.h),
            blurRadius: 22.h,
          ),
        ],
        padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 12.h),
        textStyle: TextStyleHelper.instance.display43SemiBold,
        onPressed: () => _onWhoAreYouPressed(context),
      ),
    );
  }

  void _onWhoAreYouPressed(BuildContext context) {
    // Navigate to the next screen or handle the button press
    // Since there's no navigateTo property in JSON, this would typically
    // navigate to a user profile or registration screen
    print('WHO ARE YOU button pressed');
  }
}
