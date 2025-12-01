// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:zenify/models/types.dart';
import 'package:zenify/widgets/nutribot_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  OnboardingStep currentStep = OnboardingStep.welcome;
  UserData userData = UserData(
    weight: 60,
    height: 170,
    age: 25,
  );

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void nextStep() {
    if (currentStep.index < OnboardingStep.values.length - 1) {
      setState(() {
        currentStep = OnboardingStep.values[currentStep.index + 1];
      });
      _scrollToTop();
    }
  }

  void prevStep() {
    if (currentStep.index > 0) {
      setState(() {
        currentStep = OnboardingStep.values[currentStep.index - 1];
      });
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  NutriBotConfig get _robotConfig {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return NutriBotConfig(
          size: 280,
          expression: 'happy',
          position: RobotPosition.center,
        );
      case OnboardingStep.introChat:
        return NutriBotConfig(
          size: 120,
          expression: 'talking',
          position: RobotPosition.top,
        );
      case OnboardingStep.completion:
        return NutriBotConfig(
          size: 250,
          expression: 'cheers',
          position: RobotPosition.center,
        );
      default:
        return NutriBotConfig(
          size: 100,
          expression: 'neutral',
          position: RobotPosition.top,
        );
    }
  }

  double get _progress =>
      (currentStep.index) / (OnboardingStep.values.length - 2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation
            if (currentStep.index > 0 &&
                currentStep != OnboardingStep.completion)
              _buildTopNavigation(),

            // NutriBot
            _buildNutriBot(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: _buildStepContent(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF5F5F5).withOpacity(0.9),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: prevStep,
                icon: const Icon(Icons.arrow_back),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                ),
              ),
              Text(
                '${currentStep.index}/${OnboardingStep.values.length - 2}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFccff00)),
          ),
        ],
      ),
    );
  }

  Widget _buildNutriBot() {
    final config = _robotConfig;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: config.position == RobotPosition.center ? 300 : 120,
      child: NutriBot(
        expression: config.expression,
        size: config.size,
        showGlass: true,
      ).animate().scale(
            duration: 300.ms,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case OnboardingStep.welcome:
        return _buildWelcomeStep();
      case OnboardingStep.introChat:
        return _buildIntroChatStep();
      case OnboardingStep.basics:
        return _buildBasicsStep();
      case OnboardingStep.goal:
        return _buildGoalStep();
      case OnboardingStep.preference:
        return _buildPreferenceStep();
      case OnboardingStep.foodHabits:
        return _buildFoodHabitsStep();
      case OnboardingStep.allergies:
        return _buildAllergiesStep();
      case OnboardingStep.activity:
        return _buildActivityStep();
      case OnboardingStep.completion:
        return _buildCompletionStep();
    }
  }

  Widget _buildWelcomeStep() {
    return Column(
      children: [
        const SizedBox(height: 300), // Space for NutriBot

        Stack(
          alignment: Alignment.center,
          children: [
            Opacity(
              opacity: 0.1,
              child: const Text(
                'NUTRI',
                style: TextStyle(
                  fontSize: 120,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            Text(
              'NUTRI',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(
                  begin: 20,
                  end: 0,
                  duration: 300.ms,
                ),
            const Positioned(
              top: 60,
              right: 80,
              child: Text(
                'BOT',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 40),

        _buildBottomButton(
          text: "Let's start",
          onPressed: nextStep,
        ).animate().slideY(
              begin: 100,
              end: 0,
              duration: 300.ms,
              delay: 200.ms,
            ),

        const SizedBox(height: 16),

        Text.rich(
          TextSpan(
            children: [
              const TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              WidgetSpan(
                child: GestureDetector(
                  onTap: () {
                    // Navigate to registration
                  },
                  child: const Text(
                    'Register now',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFccff00),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 1000.ms),
      ],
    );
  }

  Widget _buildIntroChatStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChatBubble(
            "HI! I'm Nutribot, your personal nutrition guide.",
            delay: 200,
          ),
          _buildChatBubble(
            "A great many users trust us.",
            delay: 1000,
          ),

          // User avatars
          Container(
            margin: const EdgeInsets.only(top: 16, left: 16),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  children: [
                    for (int i = 0; i < 4; i++)
                      Positioned(
                        right: i * 16.0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://picsum.photos/seed/user$i/50/50.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                const Text(
                  '+1M',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ).animate().scale(
                duration: 300.ms,
                delay: 1200.ms,
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
              ),

          const SizedBox(height: 40),

          _buildBottomButton(
            text: "Continue",
            onPressed: nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildBasicsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChatBubble(
            "First, let's cover the basics. What's your gender and age?",
            delay: 0,
          ),

          const SizedBox(height: 24),

          // Gender selection
          _buildSectionHeader("👤", "Gender"),
          const SizedBox(height: 8),
          Row(
            children: ['Male', 'Female', 'Other'].map((gender) {
              final isSelected = userData.gender == gender.toLowerCase();
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        userData = userData.copyWith(
                          gender: gender.toLowerCase(),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSelected ? Colors.black : Colors.transparent,
                      foregroundColor:
                          isSelected ? Colors.white : Colors.grey[400],
                      elevation: isSelected ? 2 : 0,
                      side: BorderSide(
                        color:
                            isSelected ? Colors.transparent : Colors.grey[200]!,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      gender,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Weight and Height
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  icon: '⚖️',
                  label: 'Weight',
                  value: userData.weight.toString(),
                  unit: 'kg',
                  onChanged: (value) {
                    final weight = int.tryParse(value) ?? 0;
                    setState(() {
                      userData = userData.copyWith(weight: weight);
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  icon: '📏',
                  label: 'Height',
                  value: userData.height.toString(),
                  unit: 'cm',
                  onChanged: (value) {
                    final height = int.tryParse(value) ?? 0;
                    setState(() {
                      userData = userData.copyWith(height: height);
                    });
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Age
          _buildInputField(
            icon: '📅',
            label: 'Age',
            value: userData.age.toString(),
            unit: 'years',
            widthFactor: 0.5,
            onChanged: (value) {
              final age = int.tryParse(value) ?? 0;
              setState(() {
                userData = userData.copyWith(age: age);
              });
            },
          ),

          const SizedBox(height: 40),

          _buildBottomButton(
            text: "Continue",
            onPressed: userData.gender != null ? nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User summary
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFccff00).withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${userData.weight}kg, ${userData.height}cm',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a1a1a),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Goal question
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '🎯',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(width: 8),
                Text(
                  'The main goal is?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Goal options
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: goalOptions.length,
            itemBuilder: (context, index) {
              final goal = goalOptions[index];
              final isSelected = userData.goal == goal;

              return InkWell(
                onTap: () {
                  setState(() {
                    userData = userData.copyWith(goal: goal);
                  });
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFccff00)
                          : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: isSelected ? 8 : 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      goal,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isSelected ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Add more button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('💬'),
                      const SizedBox(width: 8),
                      Text(
                        'Add more',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFccff00),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward),
              ),
            ],
          ),

          const SizedBox(height: 40),

          _buildBottomButton(
            text: "Continue",
            onPressed: userData.goal != null ? nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPreferenceStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User summary
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFccff00).withOpacity(0.4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${userData.weight}kg, ${userData.height}cm',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (userData.goal != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFccff00).withOpacity(0.4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userData.goal!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a1a1a),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 24),

          _buildChatBubble(
            "Which do you prefer? 🥰",
            delay: 0,
          ),

          const SizedBox(height: 24),

          // Preference options
          Column(
            children: ['Quick weight loss', 'Build better habits'].map((pref) {
              final isSelected = userData.preference == pref;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      userData = userData.copyWith(preference: pref);
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFccff00)
                            : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      pref,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected ? Colors.black : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          _buildBottomButton(
            text: "Continue",
            onPressed: userData.preference != null ? nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildFoodHabitsStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChatBubble(
            "Which foods do you eat the most (in order)?",
            delay: 0,
          ),

          const SizedBox(height: 24),

          // Food selection cloud
          SizedBox(
            height: 400,
            child: Stack(
              children: foodOptions.asMap().entries.map((entry) {
                final index = entry.key;
                final food = entry.value;
                final selectedIndex = userData.foodHabits.indexOf(food.id);
                final isSelected = selectedIndex != -1;

                // Manual positioning based on screenshot approximation
                final positions = [
                  const Offset(0.35, 0.1), // Fish
                  const Offset(0.05, 0.2), // Eggs
                  const Offset(0.35, 0.35), // Meat
                  const Offset(0.8, 0.25), // Dairy
                  const Offset(0.1, 0.5), // Fruits
                  const Offset(0.8, 0.5), // Veggies
                  const Offset(0.3, 0.75), // Grains
                ];

                final position = index < positions.length
                    ? positions[index]
                    : const Offset(0.5, 0.5);

                return Positioned(
                  left: position.dx * MediaQuery.of(context).size.width - 50,
                  top: position.dy * 400 - 50,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          // Remove from list
                          final habits = List<String>.from(userData.foodHabits);
                          habits.remove(food.id);
                          userData = userData.copyWith(foodHabits: habits);
                        } else {
                          // Add to list
                          userData = userData.copyWith(
                            foodHabits: [...userData.foodHabits, food.id],
                          );
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                food.emoji,
                                style: const TextStyle(fontSize: 30),
                              ),
                              const SizedBox(height: 4),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  food.label,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          // Order number if selected
                          if (isSelected)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  border:
                                      Border.all(color: Colors.white, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    '${selectedIndex + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ).animate().scale(
                        duration: 300.ms,
                        delay: Duration(milliseconds: index * 100),
                        begin: const Offset(0, 0),
                        end: const Offset(1, 1),
                      ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 40),

          _buildBottomButton(
            text: userData.foodHabits.isNotEmpty ? "Continue" : "Skip",
            onPressed: nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildAllergiesStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChatBubble(
            "What foods are you allergic to? 😫",
            delay: 0,
          ),

          const SizedBox(height: 8),

          // Multiple choice label
          const Text(
            'MULTIPLE CHOICE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          // Allergy options
          Column(
            children: allergyOptions.map((allergy) {
              final isSelected = userData.allergies.contains(allergy);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        userData = userData.copyWith(
                          allergies: userData.allergies
                              .where((a) => a != allergy)
                              .toList(),
                        );
                      } else {
                        userData = userData.copyWith(
                          allergies: [...userData.allergies, allergy],
                        );
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color:
                          isSelected ? const Color(0xFFFFF5F5) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected ? Colors.red[200]! : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      allergy,
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                        color: isSelected ? Colors.red[600] : Colors.black87,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          _buildBottomButton(
            text: "Skip",
            secondary: userData.allergies.isEmpty,
            onPressed: nextStep,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityStep() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildChatBubble(
            "Which of the following best describes your activity level?",
            delay: 0,
          ),

          const SizedBox(height: 8),

          // Single choice label
          const Text(
            'SINGLE CHOICE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 16),

          // Activity options
          Column(
            children: activityOptions.map((activity) {
              final isSelected = userData.activityLevel == activity.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      userData = userData.copyWith(activityLevel: activity.id);
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: isSelected ? 8 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          activity.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          activity.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 40),

          _buildBottomButton(
            text: "Continue",
            onPressed: userData.activityLevel != null ? nextStep : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStep() {
    bool cheers = false;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100), // Space for NutriBot

          // Cheers bubble
          if (cheers)
            Positioned(
              top: 100,
              right: 20,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFccff00),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Cheers!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
              ),
            ),

          const Text(
            "You're All Set, Friend!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(duration: 300.ms).slideY(
                begin: 20,
                end: 0,
                duration: 300.ms,
                delay: 500.ms,
              ),

          const SizedBox(height: 16),

          const Text(
            "Your personalized nutrition journey is about to begin. Get ready to discover delicious meals tailored just for you!",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(
                duration: 300.ms,
                delay: 800.ms,
              ),

          const SizedBox(height: 40),

          if (!cheers)
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  cheers = true;
                });
              },
              icon: const Text('🍻'),
              label: const Text(
                'Cheers!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFccff00),
                foregroundColor: const Color(0xFF1a1a1a),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
            ).animate().scale(
                  duration: 200.ms,
                ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, {int delay = 0}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.85,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              topLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 300.ms,
          delay: Duration(milliseconds: delay),
        )
        .slideY(
          begin: 20,
          end: 0,
          duration: 300.ms,
          delay: Duration(milliseconds: delay),
        );
  }

  Widget _buildSectionHeader(String icon, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String icon,
    required String label,
    required String value,
    required String unit,
    double widthFactor = 1.0,
    required Function(String) onChanged,
  }) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * widthFactor - 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(icon, label),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: value,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: onChanged,
                  ),
                ),
                Text(
                  unit,
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton({
    required String text,
    required VoidCallback? onPressed,
    bool secondary = false,
  }) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: secondary
            ? const SizedBox.shrink()
            : const Icon(Icons.arrow_forward),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: secondary ? Colors.white : const Color(0xFFccff00),
          foregroundColor: secondary ? Colors.black : const Color(0xFF1a1a1a),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          side: secondary ? BorderSide(color: Colors.grey[200]!) : null,
          elevation: 8,
        ),
      ),
    );
  }
}

enum RobotPosition { top, center }

class NutriBotConfig {
  final double size;
  final String expression;
  final RobotPosition position;

  NutriBotConfig({
    required this.size,
    required this.expression,
    required this.position,
  });
}
