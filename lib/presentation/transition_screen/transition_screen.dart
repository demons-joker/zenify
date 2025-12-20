import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../core/app_export.dart';
import '../user_profile_setup_screen/user_profile_setup_screen.dart';

class TransitionScreen extends StatefulWidget {
  const TransitionScreen({super.key});

  @override
  State<TransitionScreen> createState() => _TransitionScreenState();
}

class _TransitionScreenState extends State<TransitionScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  late final AnimationController _progressController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Fade controller for entrance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Scale controller for pulsing mascot
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Progress controller for loading
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start with fade in
    _fadeController.forward();
    _progressController.forward();

    // Auto navigate after animation completes
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              FadeTransition(
            opacity: animation,
            child: UserProfileSetupScreen(),
          ),
        ));
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xFFFCFCFC),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(-0.8, -0.6),
                end: Alignment(0.6, 0.8),
                colors: [Color(0xFFFDF8F5), Color(0xFFF2F5F6)],
              ),
            ),
            child: Stack(
              children: [
                // Floating cards in background
                _buildFloatingCards(),

                // Main content
                _buildMainContent(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingCards() {
    return Stack(
      children: [
        // Top left card - Super Tasty System
        Positioned(
          top: 60.h,
          left: 20.h,
          right: 20.h,
          child: Transform.rotate(
            angle: -2 * math.pi / 180,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFDF8F5),
                    Color(0xFFF2F5F6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.h),
                border: Border.all(color: Colors.white, width: 2.h),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10.h,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Super Tasty Menu',
                            style: TextStyle(
                              color: Color(0xFF929292),
                              fontSize: 16.fSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Recommendation System',
                            style: TextStyle(
                              color: Color(0xFF929292),
                              fontSize: 14.fSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Menu icons
                    Row(
                      children: [
                        Container(
                          width: 50.h,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.h),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4.h,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Icon(Icons.restaurant_menu,
                              color: Color(0xFF232323), size: 24.h),
                        ),
                        SizedBox(width: 12.h),
                        Container(
                          width: 50.h,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.h),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4.h,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Icon(Icons.fastfood,
                              color: Color(0xFF232323), size: 24.h),
                        ),
                        SizedBox(width: 12.h),
                        Container(
                          width: 50.h,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.h),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4.h,
                                offset: Offset(0, 2.h),
                              ),
                            ],
                          ),
                          child: Icon(Icons.local_cafe,
                              color: Color(0xFF232323), size: 24.h),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Right side card - User Stats
        Positioned(
          top: 200.h,
          right: 10.h,
          child: Transform.rotate(
            angle: 2 * math.pi / 180,
            child: Container(
              width: 320.h,
              height: 100.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFDF8F5),
                    Color(0xFFF2F5F6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20.h),
                border: Border.all(color: Colors.white, width: 2.h),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10.h,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16.h),
                child: Row(
                  children: [
                    Container(
                      width: 60.h,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(30.h),
                      ),
                      child: Icon(Icons.watch, color: Colors.white, size: 30.h),
                    ),
                    SizedBox(width: 16.h),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12.h, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(16.h),
                            ),
                            child: Text(
                              '+1K Users',
                              style: TextStyle(
                                color: Color(0xFF232323),
                                fontSize: 12.fSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Trust our nutrition guide',
                            style: TextStyle(
                              color: Color(0xFF929292),
                              fontSize: 12.fSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Progress card
        Positioned(
          top: 320.h,
          left: 20.h,
          right: 20.h,
          child: AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: -2 * math.pi / 180,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: double.infinity,
                    height: 110.h,
                    decoration: BoxDecoration(
                      color: Color(0xFF232323),
                      borderRadius: BorderRadius.circular(20.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 12.h,
                          offset: Offset(0, 6.h),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Health Level Progress',
                            style: TextStyle(
                              color: Color(0xFFA4A4A4),
                              fontSize: 14.fSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Text(
                                '80%',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.fSize,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Spacer(),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12.h, vertical: 6.h),
                                decoration: BoxDecoration(
                                  color: Color(0xFF454A30),
                                  borderRadius: BorderRadius.circular(16.h),
                                ),
                                child: Text(
                                  'Level A',
                                  style: TextStyle(
                                    color: Color(0xFFD7EC9C),
                                    fontSize: 8.fSize,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMainContent() {
    return Stack(
      children: [
        Column(
          children: [
            // Top spacing for background elements
            SizedBox(height: 380.h),

            // Character and greeting
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 80.h),

                    // Greeting message
                    Transform.rotate(
                      angle: 2 * math.pi / 180,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 80.h),
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.h, vertical: 12.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFFFDF8F5),
                              Color(0xFFF2F5F6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.h),
                          border: Border.all(
                            color: Color(0xFFC8FD00),
                            width: 2.h,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 8.h,
                              offset: Offset(0, 4.h),
                            ),
                          ],
                        ),
                        child: Text(
                          "HI! I'm Nutribot,\nyour personal nutrition guide~",
                          style: TextStyle(
                            color: Color(0xFF162716),
                            fontSize: 14.fSize,
                            fontWeight: FontWeight.w600,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // CTA Button - NOT ROTATED
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.h),
                      height: 50.h,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFC8FD00), Color(0xFFC8FD00)],
                        ),
                        borderRadius: BorderRadius.circular(25.h),
                        border: Border.all(
                          color: Color(0xFFC8FD00),
                          width: 2.h,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 12.h,
                            offset: Offset(0, 4.h),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () => _onWhoAreYouPressed(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.h),
                          ),
                        ),
                        child: Text(
                          'WHO ARE YOU？',
                          style: TextStyle(
                            color: Color(0xFF779600),
                            fontSize: 18.fSize,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Mascot with Hero animation - positioned at top right of black card
        Positioned(
          top: 310.h,
          right: 20.h,
          child: Hero(
            tag: 'mascotHero',
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 55.h,
                    height: 55.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.h),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8.h,
                          offset: Offset(0, 4.h),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      ImageConstant.imgGood,
                      height: 30.h,
                      width: 30.h,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _onWhoAreYouPressed(BuildContext context) {
    // Navigate to user profile setup screen
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => FadeTransition(
        opacity: animation,
        child: UserProfileSetupScreen(),
      ),
    ));
  }
}
