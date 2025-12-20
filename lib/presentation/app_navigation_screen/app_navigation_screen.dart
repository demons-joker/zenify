import 'package:flutter/material.dart';

import '../../core/app_export.dart';
// custom_button not needed for new design
import '../../widgets/custom_image_view.dart';
import '../transition_screen/transition_screen.dart';

class AppNavigationScreen extends StatefulWidget {
  const AppNavigationScreen({Key? key}) : super(key: key);

  @override
  State<AppNavigationScreen> createState() => _AppNavigationScreenState();
}

class _AppNavigationScreenState extends State<AppNavigationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // start the entrance animation
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _offsetAnimation,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.8, -0.6),
                  end: Alignment(0.6, 0.8),
                  colors: [Color(0xFFFDF8F5), Color(0xFFF6FDFF)],
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // decorative background patterns removed as not required

                  // Center content
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 60.h),
                      // Mascot with lime ring (mascot is primary visual)
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // outer lime ring
                          Container(
                            height: 240.h,
                            width: 240.h,
                            decoration: BoxDecoration(
                              color: appTheme.lime_A100.withOpacity(0.95),
                              shape: BoxShape.circle,
                            ),
                          ),
                          // inner circle that holds the mascot SVG
                          Container(
                            height: 200.h,
                            width: 200.h,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Hero(
                                tag: 'mascotHero',
                                child: CustomImageView(
                                  imagePath: ImageConstant.figmaMascot,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 18.h),
                      // Under mascot, show logo image (text as image)
                      CustomImageView(
                        imagePath: ImageConstant.figmaLogo3,
                        height: 48.h,
                        width: 230.h,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 40.h),
                    ],
                  ),

                  // CTA area at bottom
                  Positioned(
                    left: 20.h,
                    right: 20.h,
                    bottom: 80.h,
                    child: Column(
                      children: [
                        // layered pill buttons (outer rings)
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 128.h,
                              decoration: BoxDecoration(
                                color: appTheme.lime_A100.withOpacity(0.11),
                                borderRadius: BorderRadius.circular(80.h),
                                border: Border.all(color: appTheme.white_A700),
                              ),
                            ),
                            Container(
                              height: 142.h,
                              decoration: BoxDecoration(
                                color: appTheme.lime_A100.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(90.h),
                              ),
                            ),
                            Container(
                              height: 112.h,
                              child: ElevatedButton(
                                onPressed: () => _onLetsStartPressed(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: appTheme.lime_A400,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(80.h),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 40.h, vertical: 20.h),
                                  elevation: 6.h,
                                  shadowColor: Color(0x198C8C8C),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Let's start",
                                      style: TextStyleHelper
                                          .instance.title20SemiBoldPingFangSC
                                          .copyWith(
                                              color: Colors.white,
                                              fontSize: 28.fSize),
                                    ),
                                    SizedBox(width: 12.h),
                                    Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 26.h,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        // SizedBox(height: 18.h),
                        // Text(
                        //   "Don't have an account?",
                        //   style: TextStyleHelper
                        //       .instance.body12SemiBoldPingFangSC
                        //       .copyWith(color: appTheme.gray_500),
                        // ),
                        // SizedBox(height: 6.h),
                        // GestureDetector(
                        //   onTap: () => Navigator.pushNamed(
                        //       context, AppRoutes.registration),
                        //   child: Text(
                        //     'Register now',
                        //     style: TextStyleHelper
                        //         .instance.title18SemiBoldPingFangSC
                        //         .copyWith(color: Color(0xFF7ED321)),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Common click event
  void onTapScreenTitle(BuildContext context, String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  /// Common click event for bottomsheet
  void onTapBottomSheetTitle(BuildContext context, Widget className) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return className;
      },
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Common click event for dialog
  void onTapDialogTitle(BuildContext context, Widget className) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: className,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
        );
      },
    );
  }

  void _onLetsStartPressed(BuildContext context) {
    // Navigate to the transition screen first
    Navigator.of(context).push(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          FadeTransition(opacity: animation, child: TransitionScreen()),
    ));
  }
}
