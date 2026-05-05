import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/app_logger.dart';
import '../../core/app_export.dart';
import '../../services/mqtt_service.dart';
import '../../services/user_session.dart';
import '../../services/api.dart';
import '../../services/user_data_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../menu/menu_page.dart';
import 'home_history_coordinator.dart';
import '../../utils/toast_helper.dart';
import '../../utils/error_message_helper.dart';

class _RecommendationSource {
  static const String none = 'none';
  static const String manualAdjusted = 'manual_adjusted';
  static const String generatedFromProfile = 'generated_from_profile';
  static const String todayExistingPlan = 'today_existing_plan';
  static const String activePlan = 'active_plan';
}

class _RecommendationSourceStyle {
  final String label;
  final Color color;

  const _RecommendationSourceStyle({
    required this.label,
    required this.color,
  });
}

class _RecommendationFallbackTestMode {
  static const String off = 'off';
  static const String empty = 'empty';
  static const String fail = 'fail';
}

class IndexPage extends StatefulWidget {
  const IndexPage({
    super.key,
    this.initialTab,
    this.hostTabActive = true,
  });

  final String? initialTab;

  /// 为 false 时表示首页在主导航中处于隐藏层（如切到报告/我的），仅取消本页 MQTT 监听，不断开全局连接。
  final bool hostTabActive;

  // ignore: library_private_types_in_public_api
  static final GlobalKey<_IndexPageState> globalKey =
      GlobalKey<_IndexPageState>();

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  static const String _recommendationFallbackTestMode =
      String.fromEnvironment(
    'RECOMMENDATION_FALLBACK_TEST_MODE',
    defaultValue: _RecommendationFallbackTestMode.off,
  );
  late TabController _tabController;
  final List<String> _tabs = ['EAT', 'ATE'];
  int _selectedDay = DateTime.now().weekday; // 0-6 for Monday-Sunday

  // MY PLAN 数据
  final List<Map<String, dynamic>> _dietPlans = [
    // {
    //   'name': 'Paleo diet',
    //   'user': 'Alice',
    //   'score': 'B+',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'Keto diet',
    //   'user': 'Bob',
    //   'score': 'A-',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'Vegan diet',
    //   'user': 'Carol',
    //   'score': 'C+',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'Mediterranean',
    //   'user': 'David',
    //   'score': 'A',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'Low carb',
    //   'user': 'Eve',
    //   'score': 'B',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
    // {
    //   'name': 'High protein',
    //   'user': 'Frank',
    //   'score': 'A+',
    //   'image': 'assets/images/figma/plate_jimeng.png'
    // },
  ];

  String _selectedMealType = 'BREAKFAST';
  final List<String> _mealTypes = ['BREAKFAST', 'LUNCH', 'DINNER'];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchVisible = false;
  String _selectedPlanSourceFilter = 'all';
  static const String _myPlanSearchVisibleKey = 'home_my_plan_search_visible';
  static const String _myPlanSourceFilterKey = 'home_my_plan_source_filter';
  static const String _recommendSourceKey = 'home_recommend_source';
  static const String _recommendGeneratedTodayKey =
      'home_recommend_generated_today';
  static const String _recommendSourceOverrideKey =
      'home_recommend_source_override';
  static const String _recommendSourceDateKey = 'home_recommend_source_date';
  static const String _recommendSourceUserIdKey = 'home_recommend_source_user_id';

  // 当前用户食物数据
  List<dynamic> _currentUserFoods = [];
  bool _isLoadingFoods = false;
  bool _recommendationGeneratedToday = false;
  String _recommendationSource = _RecommendationSource.none;
  String? _recommendationSourceOverride;
  String? _recommendationSourceOverrideDate;
  int? _recommendationSourceOverrideUserId;
  String? _lastAutoGenerateAttemptKey;
  String? _recommendationFallbackError;
  bool _hasInjectedRecommendationFallbackFailure = false;

  // 收藏状态 - 按日期和餐食类型存储
  Map<String, bool> _collectedStatus = {};

  // 收藏的餐食列表
  List<Map<String, dynamic>> _collectedMeals = [];

  // 食物识别记录 - 按餐食类型分组
  Map<String, List<Map<String, dynamic>>> _ateFoods = {
    'BREAKFAST': [],
    'LUNCH': [],
    'DINNER': [],
    'OTHER': [],
  };

  // 是否正在加载数据
  bool _isLoadingHistory = false;
  bool _isPollingHistory = false;

  // StreamSubscription for MQTT
  StreamSubscription<RecognitionStatus>? _mqttSubscription;
  StreamSubscription<MQTTConnectionStatus>? _mqttConnectionSubscription;
  MQTTConnectionStatus? _mqttConnectionStatus;
  final HomeHistoryCoordinator _historyCoordinator = HomeHistoryCoordinator();
  final GlobalKey _recommendSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);

    // 根据初始参数设置 tab
    if (widget.initialTab != null) {
      final initialIndex = _tabs.indexOf(widget.initialTab!);
      if (initialIndex != -1) {
        _currentTabIndex = initialIndex;
      }
    }

    // 初始化 MQTT（隐藏 Tab 时由 didUpdateWidget 再挂载监听）
    if (widget.hostTabActive) {
      _initMQTT();
    }

    // 加载历史数据
    _loadHistoryData();

    // 加载当前用户食物数据
    _loadCurrentUserFoods();

    // 加载收藏餐食数据
    _loadCollectedMeals();

    // 加载收藏状态
    _loadCollectedStatus();
    _loadMyPlanViewPrefs();
    _loadRecommendViewPrefs();
  }

  @override
  void didUpdateWidget(IndexPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hostTabActive == widget.hostTabActive) return;
    if (widget.hostTabActive) {
      unawaited(_resumeHostTabMqtt());
    } else {
      _pauseHostTabMqtt();
    }
  }

  void _attachMqttListeners() {
    if (!mounted) return;
    if (_mqttSubscription != null) return;
    _mqttSubscription = MQTTService().statusStream.listen((status) {
      _handleRecognitionStatus(status);
    });
    _mqttConnectionSubscription =
        MQTTService().connectionStatusStream.listen((connectionStatus) {
      if (!mounted) return;
      // 避免在鼠标/指针设备更新过程中同步 setState，触发 mouse_tracker 重入断言（尤其 macOS）。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          _mqttConnectionStatus = connectionStatus;
        });
      });
    });
  }

  void _detachMqttListeners() {
    _mqttSubscription?.cancel();
    _mqttSubscription = null;
    _mqttConnectionSubscription?.cancel();
    _mqttConnectionSubscription = null;
  }

  void _pauseHostTabMqtt() {
    _detachMqttListeners();
    if (!mounted) return;
    setState(() {
      _mqttConnectionStatus = null;
    });
  }

  Future<void> _resumeHostTabMqtt() async {
    try {
      await MQTTService().connect();
      if (!mounted) return;
      _attachMqttListeners();
    } catch (e) {
      AppLogger.error('MQTT resume error: $e');
      if (mounted) {
        ToastHelper.error(context, ErrorMessageHelper.format(e));
      }
    }
  }

  Future<void> _loadMyPlanViewPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSearchVisible = prefs.getBool(_myPlanSearchVisibleKey);
      final savedFilter = prefs.getString(_myPlanSourceFilterKey);
      final allowed = _planSourceFilters.map((e) => e['key']).whereType<String>();
      if (!mounted) return;
      setState(() {
        if (savedSearchVisible != null) {
          _isSearchVisible = savedSearchVisible;
        }
        if (savedFilter != null && allowed.contains(savedFilter)) {
          _selectedPlanSourceFilter = savedFilter;
        }
      });
    } catch (e) {
      AppLogger.warning('加载 MY PLAN 视图偏好失败: $e');
    }
  }

  Future<void> _persistMyPlanViewPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_myPlanSearchVisibleKey, _isSearchVisible);
      await prefs.setString(_myPlanSourceFilterKey, _selectedPlanSourceFilter);
    } catch (e) {
      AppLogger.warning('保存 MY PLAN 视图偏好失败: $e');
    }
  }

  Future<void> _loadRecommendViewPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedSource = prefs.getString(_recommendSourceKey);
      final savedGenerated = prefs.getBool(_recommendGeneratedTodayKey);
      final savedOverride = prefs.getString(_recommendSourceOverrideKey);
      final savedOverrideDate = prefs.getString(_recommendSourceDateKey);
      final savedOverrideUserId = prefs.getInt(_recommendSourceUserIdKey);
      if (!mounted) return;
      setState(() {
        if (savedSource != null && savedSource.isNotEmpty) {
          _recommendationSource = savedSource;
        }
        if (savedGenerated != null) {
          _recommendationGeneratedToday = savedGenerated;
        }
        if (savedOverride != null && savedOverride.isNotEmpty) {
          _recommendationSourceOverride = savedOverride;
          _recommendationSourceOverrideDate = savedOverrideDate;
          _recommendationSourceOverrideUserId = savedOverrideUserId;
          _recommendationSource = savedOverride;
          _recommendationGeneratedToday = false;
        }
      });
    } catch (e) {
      AppLogger.warning('加载推荐来源偏好失败: $e');
    }
  }

  Future<void> _persistRecommendViewPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_recommendSourceKey, _recommendationSource);
      await prefs.setBool(
          _recommendGeneratedTodayKey, _recommendationGeneratedToday);
      final override = _recommendationSourceOverride;
      if (override == null || override.isEmpty) {
        await prefs.remove(_recommendSourceOverrideKey);
        await prefs.remove(_recommendSourceDateKey);
        await prefs.remove(_recommendSourceUserIdKey);
      } else {
        await prefs.setString(_recommendSourceOverrideKey, override);
        if (_recommendationSourceOverrideDate != null) {
          await prefs.setString(
              _recommendSourceDateKey, _recommendationSourceOverrideDate!);
        }
        if (_recommendationSourceOverrideUserId != null) {
          await prefs.setInt(
              _recommendSourceUserIdKey, _recommendationSourceOverrideUserId!);
        }
      }
    } catch (e) {
      AppLogger.warning('保存推荐来源偏好失败: $e');
    }
  }

  /// 加载历史识别数据
  Future<void> _loadHistoryData({bool silent = false}) async {
    if (_isLoadingHistory || _isPollingHistory) return;

    if (!mounted) return;

    if (silent) {
      _isPollingHistory = true;
    } else {
      setState(() {
        _isLoadingHistory = true;
      });
    }

    try {
      final userId = await UserSession.userId;
      if (userId == null || !mounted) return;
      final ateFoods = await _historyCoordinator.loadAteFoods(
        userId: userId.toString(),
        selectedDay: _selectedDay,
      );
      _ateFoods = ateFoods;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      AppLogger.error('加载历史数据失败: $e');
      AppLogger.warning('堆栈跟踪: ${StackTrace.current}');
      if (mounted && !silent) {
        ToastHelper.error(context, ErrorMessageHelper.format(e));
      }
    } finally {
      if (silent) {
        _isPollingHistory = false;
      } else if (mounted) {
        setState(() {
          _isLoadingHistory = false;
        });
      }
    }
  }

  /// 加载当前用户食物数据
  Future<void> _loadCurrentUserFoods({bool allowGenerateFallback = true}) async {
    if (_isLoadingFoods) return;
    if (!mounted) return;

    setState(() {
      _isLoadingFoods = true;
      _recommendationFallbackError = null;
    });

    try {
      final userId = await UserSession.userId;
      if (userId == null || !mounted) return;
      final today = DateTime.now().toIso8601String().split('T').first;
      final autoGenerateAttemptKey = '$userId:$today';
      final canUseOverride = _recommendationSourceOverride != null &&
          _recommendationSourceOverrideDate == today &&
          _recommendationSourceOverrideUserId == userId;
      if (!canUseOverride && _recommendationSourceOverride != null) {
        _recommendationSourceOverride = null;
        _recommendationSourceOverrideDate = null;
        _recommendationSourceOverrideUserId = null;
      }

      AppLogger.info('加载当前用户食物数据: userId=$userId');

      // 调用API获取当前用户食物数据
      var result = await Api.getCurrentUserFoods({'user_id': userId});
      var mealGroups = result['meal_groups'];
      var foods = mealGroups is List ? mealGroups : <dynamic>[];
      final shouldForceEmptyState =
          _recommendationFallbackTestMode ==
              _RecommendationFallbackTestMode.empty ||
          (_recommendationFallbackTestMode ==
                  _RecommendationFallbackTestMode.fail &&
              !_hasInjectedRecommendationFallbackFailure);
      if (shouldForceEmptyState) {
        AppLogger.warning(
            'Recommendation fallback test mode active: $_recommendationFallbackTestMode');
        result = {
          ...result,
          'meal_groups': <dynamic>[],
          'generated_today': false,
          'recommendation_source': _RecommendationSource.none,
        };
        foods = <dynamic>[];
      }
      final shouldAttemptAutoGenerate = allowGenerateFallback &&
          _lastAutoGenerateAttemptKey != autoGenerateAttemptKey;
      if (foods.isEmpty && shouldAttemptAutoGenerate) {
        _lastAutoGenerateAttemptKey = autoGenerateAttemptKey;
        AppLogger.info(
            'Auto-generate daily recommendation start: key=$autoGenerateAttemptKey');
        AppLogger.info('当前无推荐，尝试生成当日推荐');
        if (_recommendationFallbackTestMode ==
                _RecommendationFallbackTestMode.fail &&
            !_hasInjectedRecommendationFallbackFailure) {
          _hasInjectedRecommendationFallbackFailure = true;
          _recommendationFallbackError =
              'Recommendation fallback test mode forced a generation failure.';
          AppLogger.warning(
              'Recommendation fallback test mode forced failure: key=$autoGenerateAttemptKey');
          foods = <dynamic>[];
        } else {
          result = await Api.generateDailyRecommendation();
          mealGroups = result['meal_groups'];
          foods = mealGroups is List ? mealGroups : <dynamic>[];
          if (foods.isEmpty) {
            _recommendationFallbackError =
                'Recommendation generation returned no items.';
            AppLogger.warning(
                'Auto-generate daily recommendation returned no items: key=$autoGenerateAttemptKey');
          } else {
            AppLogger.info(
                'Auto-generate daily recommendation succeeded: key=$autoGenerateAttemptKey, mealGroups=${foods.length}');
          }
        }
      }
      AppLogger.info('API响应食物数据条目: ${foods.length}');

      if (mounted) {
        setState(() {
          _currentUserFoods = foods;
          if (foods.isNotEmpty &&
              _lastAutoGenerateAttemptKey == autoGenerateAttemptKey) {
            _lastAutoGenerateAttemptKey = null;
          }
          final backendGeneratedToday = result['generated_today'] == true;
          final backendSource =
              (result['recommendation_source'] ?? _RecommendationSource.none)
                  .toString();
          _recommendationGeneratedToday =
              _recommendationSourceOverride == null ? backendGeneratedToday : false;
          _recommendationSource =
              _recommendationSourceOverride ?? backendSource;
          _isLoadingFoods = false;
        });
        unawaited(_persistRecommendViewPrefs());
        // 加载收藏状态
        _loadCollectedStatus();
      }
    } catch (e) {
      AppLogger.error('加载当前用户食物数据失败: $e');
      if (mounted) {
        setState(() {
          _isLoadingFoods = false;
          _recommendationFallbackError = ErrorMessageHelper.format(e);
        });
      }
    }
  }

  /// 用户手动调整推荐后，将来源显式标记为 manual_adjusted。
  Future<void> _retryGenerateRecommendationFallback() async {
    AppLogger.info('Manual retry for daily recommendation fallback');
    _lastAutoGenerateAttemptKey = null;
    await _loadCurrentUserFoods();
  }

  void _markRecommendationAdjustedByUser() {
    if (!mounted) return;
    final today = DateTime.now().toIso8601String().split('T').first;
    setState(() {
      _recommendationGeneratedToday = false;
      _recommendationSourceOverride = _RecommendationSource.manualAdjusted;
      _recommendationSourceOverrideDate = today;
      _recommendationSource = _recommendationSourceOverride!;
    });
    unawaited(() async {
      _recommendationSourceOverrideUserId = await UserSession.userId;
      await _persistRecommendViewPrefs();
    }());
  }

  _RecommendationSourceStyle _recommendationSourceStyle(String source) {
    switch (source) {
      case _RecommendationSource.manualAdjusted:
        return const _RecommendationSourceStyle(
          label: '手动调整',
          color: Color(0xFFB86B00),
        );
      case _RecommendationSource.generatedFromProfile:
        return const _RecommendationSourceStyle(
          label: '画像生成',
          color: Color(0xFF2E7D32),
        );
      case _RecommendationSource.todayExistingPlan:
        return const _RecommendationSourceStyle(
          label: '今日已有计划',
          color: Color(0xFF1565C0),
        );
      case _RecommendationSource.activePlan:
        return const _RecommendationSourceStyle(
          label: '活跃计划',
          color: Color(0xFF6A1B9A),
        );
      case _RecommendationSource.none:
        return const _RecommendationSourceStyle(
          label: '无',
          color: Color(0xFF4C4C4C),
        );
      default:
        return _RecommendationSourceStyle(
          label: source,
          color: const Color(0xFF4C4C4C),
        );
    }
  }

  String _planSourceForDisplay(Map<String, dynamic> plan) {
    return (plan['recommendation_source'] ?? _RecommendationSource.none)
        .toString();
  }

  List<Map<String, String>> get _planSourceFilters => const [
        {'key': 'all', 'label': '全部'},
        {'key': _RecommendationSource.manualAdjusted, 'label': '手动调整'},
        {
          'key': _RecommendationSource.generatedFromProfile,
          'label': '画像生成'
        },
        {
          'key': _RecommendationSource.todayExistingPlan,
          'label': '今日已有计划'
        },
        {'key': _RecommendationSource.activePlan, 'label': '活跃计划'},
      ];

  /// 加载收藏的餐食数据
  Future<void> _loadCollectedMeals() async {
    try {
      final meals = await UserDataCache.getCollectedMeals();
      if (mounted) {
        setState(() {
          _collectedMeals = meals;
        });
      }
    } catch (e) {
      AppLogger.error('加载收藏餐食失败: $e');
    }
  }

  /// 切换收藏状态
  Future<void> _toggleCollect() async {
    final selectedDate = _getSelectedDate();
    final dateStr = selectedDate.toIso8601String().split('T')[0];
    final mealType = _selectedMealType;

    try {
      if (_collectedStatus[dateStr] ?? false) {
        // 取消收藏
        await UserDataCache.removeCollectedMeal(dateStr, mealType);
        if (mounted) {
          setState(() {
            _collectedStatus[dateStr] = false;
          });
        }
      } else {
        // 添加收藏 - 收藏当前餐食类型的所有食物
        final selectedMealData = _findSelectedMealData();

        if (selectedMealData != null) {
          final foods = selectedMealData['foods'] as List?;
          if (foods != null && foods.isNotEmpty) {
            // 为每个食物创建收藏
            for (var foodItem in foods) {
              final food = foodItem['food'] as Map?;
              if (food != null) {
                await UserDataCache.saveCollectedMeal({
                  'date': dateStr,
                  'meal_type': mealType,
                  'food_id': food['id'],
                  'name_en': food['name_en'],
                  'name': food['name'],
                  'image_url': food['image_url'],
                  'category': food['category'],
                  'quantity': foodItem['quantity'],
                  'unit': foodItem['unit'],
                  'recommendation_source': _recommendationSource,
                  'generated_today': _recommendationGeneratedToday,
                });
              }
            }
          }
          if (mounted) {
            setState(() {
              _collectedStatus[dateStr] = true;
            });
          }
        }
      }

      // 刷新My Plan模块数据
      await _loadCollectedMeals();
    } catch (e) {
      AppLogger.error('切换收藏状态失败: $e');
    }
  }

  /// 获取选中日期
  DateTime _getSelectedDate() {
    final now = DateTime.now();
    final daysUntilSelectedDay = _selectedDay - now.weekday;
    return now.add(Duration(days: daysUntilSelectedDay));
  }

  /// 加载收藏状态
  Future<void> _loadCollectedStatus() async {
    final selectedDate = _getSelectedDate();
    final dateStr = selectedDate.toIso8601String().split('T')[0];
    final mealType = _selectedMealType;

    final isCollected = await UserDataCache.isMealCollected(dateStr, mealType);
    if (mounted) {
      setState(() {
        _collectedStatus[dateStr] = isCollected;
      });
    }
  }

  /// 初始化MQTT
  Future<void> _initMQTT() async {
    try {
      await MQTTService().connect();
      if (!mounted) return;
      _attachMqttListeners();
    } catch (e) {
      AppLogger.error('MQTT init error: $e');
      if (mounted) {
        ToastHelper.error(context, ErrorMessageHelper.format(e));
      }
    }
  }

  /// 处理识别状态变化
  void _handleRecognitionStatus(RecognitionStatus status) async {
    if (!mounted) return;

    if (status.status == RecognitionStatusType.analyzing) {
      switchToATETab(refreshHistory: false);
      if (!_hasAnalyzingCards()) {
        await _loadHistoryData(silent: true);
      }
    } else if (status.status == RecognitionStatusType.completed) {
      await _loadHistoryData(silent: true);
    }
  }

  /// 切换到 ATE tab
  void switchToATETab({bool refreshHistory = true}) {
    if (!mounted) return;
    setState(() {
      _currentTabIndex = 1; // ATE tab 的索引是 1
    });
    if (refreshHistory) {
      _loadHistoryData(silent: true);
    }
  }

  void handleCameraUploadResult(Map<String, dynamic> result) {
    if (!mounted) return;

    final recognitionData = result['recognitionData'];
    final hasRecognitionData = recognitionData is Map;

    setState(() {
      _currentTabIndex = 1;
      _selectedDay = DateTime.now().weekday;
    });

    if (hasRecognitionData) {
      _insertPendingRecognitionCard(
        Map<String, dynamic>.from(recognitionData as Map),
      );
      return;
    }

    _loadHistoryData(silent: true);
  }

  void _insertPendingRecognitionCard(Map<String, dynamic> recognitionData) {
    final normalizedRecord = {
      'id': recognitionData['id'],
      'image_url': recognitionData['image_url'],
      'status': recognitionData['status'] ?? 'pending',
      'session_id': recognitionData['meal_session_id'],
      'created_at': recognitionData['requested_at'] ?? recognitionData['completed_at'],
      'foods': const <dynamic>[],
    };
    final mealType =
        _historyCoordinator.resolveMealTypeByTimeOfDay(normalizedRecord['created_at']);
    final pendingCard = _historyCoordinator.buildFoodCard(normalizedRecord);

    for (final foods in _ateFoods.values) {
      foods.removeWhere((item) => item['id'] == pendingCard['id']);
    }

    final targetList = _ateFoods.putIfAbsent(mealType, () => <Map<String, dynamic>>[]);
    targetList.insert(0, pendingCard);
    setState(() {});
  }

  bool _hasAnalyzingCards() {
    for (final foods in _ateFoods.values) {
      for (final item in foods) {
        if (item['isAnalyzing'] == true) {
          return true;
        }
      }
    }
    return false;
  }

  Map<String, dynamic>? _findSelectedMealData() {
    for (final item in _currentUserFoods) {
      if (item is Map<String, dynamic> &&
          item['meal_type']?.toString().toLowerCase() ==
              _selectedMealType.toLowerCase()) {
        return item;
      }
    }
    return null;
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _detachMqttListeners();
    super.dispose();
  }

  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFCFC),
      body: Column(
        children: [
          // 顶部区域：左边tab切换、中间logo、右边菜单
          _buildTopHeader(),
          _buildMqttConnectionBanner(),

          // 周日期选择器 - 只在 ATE tab 显示
          if (_currentTabIndex == 1) _buildWeekSelector(),

          // 内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: IndexedStack(
                index: _currentTabIndex,
                children: _tabs.map((tab) {
                  if (tab == 'EAT') {
                    return SingleChildScrollView(
                      child: _buildDietTab(),
                    );
                  } else {
                    return SingleChildScrollView(
                      child: _buildAteTab(),
                    );
                  }
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMqttConnectionBanner() {
    final status = _mqttConnectionStatus;
    if (status == null || status.state == MQTTConnectionStateView.connected) {
      return const SizedBox.shrink();
    }

    Color bgColor;
    if (status.state == MQTTConnectionStateView.failed) {
      bgColor = const Color(0xFFFFE5E5);
    } else {
      bgColor = const Color(0xFFFFF6E5);
    }

    final textColor = status.state == MQTTConnectionStateView.failed
        ? const Color(0xFF8B0000)
        : const Color(0xFF8A5A00);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              status.message,
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (status.state == MQTTConnectionStateView.failed ||
              status.state == MQTTConnectionStateView.disconnected)
            TextButton(
              onPressed: () => MQTTService().connect(isReconnect: true),
              child: Text(
                '立即重试',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // 顶部区域
  Widget _buildTopHeader() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFCFCFC),
            Color(0x9EFFFFFF),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 左边：EAT/ATE tab 切换
          Positioned(
            left: 20.h,
            top: 0,
            bottom: 0,
            child: Row(
              children: _tabs.asMap().entries.map((entry) {
                final index = entry.key;
                final tab = entry.value;
                return GestureDetector(
                  onTap: () => setState(() => _currentTabIndex = index),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.h, vertical: 4.h),
                    margin: EdgeInsets.symmetric(horizontal: 4.h),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: _currentTabIndex == index
                              ? Colors.black
                              : Colors.transparent,
                          width: 2.h,
                        ),
                      ),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                          color: _currentTabIndex == index
                              ? Colors.black
                              : Colors.grey,
                          fontWeight: FontWeight.w600,
                          fontSize: 18.fSize),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // 中间：头像 - 绝对居中
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  // 头像功能
                },
                child: Container(
                  width: 40.h,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.h),
                    border: Border.all(color: Colors.white, width: 2.h),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        offset: Offset(0, 2.h),
                        blurRadius: 4.h,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18.h),
                    child: Image.asset(
                      'assets/images/figma/avatar_center.png',
                      width: 36.h,
                      height: 36.h,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade300,
                        width: 36.h,
                        height: 36.h,
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          // 右边：菜单按钮
          Positioned(
            right: 20.h,
            top: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: () {
                // 菜单功能
              },
              child: SizedBox(
                width: 32.h,
                height: 32.h,
                child: Icon(
                  Icons.menu,
                  color: Colors.black,
                  size: 20.h,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 周日期选择器
  Widget _buildWeekSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) {
          final isSelected = index == _selectedDay;
          final isFuture = index > DateTime.now().weekday % 7;
          return GestureDetector(
            onTap: isFuture
                ? null
                : () async {
                    setState(() => _selectedDay = index);
                    await _loadHistoryData();
                  },
            child: Opacity(
              opacity: isFuture ? 0.3 : 1.0,
              child: Container(
                width: 30.h,
                height: 30.h,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    ['S', 'M', 'T', 'W', 'T', 'F', 'S'][index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 12.fSize,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDietTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // COLLECT 收集统计区域
          _buildCollectSection(),

          SizedBox(height: 24.h),

          // RECOMMEND 推荐区域
          _buildRecommendSection(),

          SizedBox(height: 24.h),

          // MY PLAN 我的计划区域
          _buildMyPlanSection(),

          SizedBox(height: 80.h), // 底部导航栏空间
        ],
      ),
    );
  }

  // ATE tab内容
  Widget _buildAteTab() {
    if (_isLoadingHistory) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistoryData,
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // 早餐组 - 使用动态数据
            _buildMealSection('BREAKFAST', _ateFoods['BREAKFAST'] ?? []),

            // SizedBox(height: 24.h),

            // 中餐组 - 使用动态数据
            _buildMealSection('LUNCH', _ateFoods['LUNCH'] ?? []),

            // SizedBox(height: 24.h),

            // 晚餐组 - 使用动态数据
            _buildMealSection('DINNER', _ateFoods['DINNER'] ?? []),

            // SizedBox(height: 24.h),

            // 加餐组 - 使用动态数据
            _buildMealSection('OTHER', _ateFoods['OTHER'] ?? []),

            SizedBox(height: 80.h), // 底部导航栏空间
          ],
        ),
      ),
    );
  }

  // 餐食分组组件
  Widget _buildMealSection(String title, List<Map<String, dynamic>> foods) {
    if (foods.isEmpty) {
      return SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF0B0B0B),
            fontSize: 24.fSize,
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: 10.h),

        // 食物卡片列表
        Column(
          children: foods.asMap().entries.map((entry) {
            final index = entry.key;
            final food = entry.value;
            return Padding(
              padding:
                  EdgeInsets.only(bottom: index < foods.length - 1 ? 16.h : 0),
              child: _buildFoodCard(
                imageUrl: food['imageUrl'],
                title: food['title'],
                isLiked: food['isLiked'] ?? false,
                isAnalyzing: food['isAnalyzing'] ?? false,
                data: food['data'],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // 食物卡片组件
  Widget _buildFoodCard({
    String? imageUrl,
    required String title,
    required bool isLiked,
    bool isAnalyzing = false,
    Map<String, dynamic>? data,
  }) {
    // 计算卡路里
    String caloriesText = '';
    if (data != null && !isAnalyzing) {
      final foods = data['foods'] as List? ?? [];
      double totalCalories = 0;
      for (var food in foods) {
        final quantity = (food['quantity'] ?? 300) as double;
        final foodInfo = food['food'] as Map? ?? {};
        final caloriesPer100g = (foodInfo['calories_per_100g'] ?? 0) as double;
        totalCalories += (quantity / 100) * caloriesPer100g;
      }
      caloriesText = '${totalCalories.toStringAsFixed(0)} kcal';
    }

    return GestureDetector(
      onTap: () {
        if (!isAnalyzing) {
          AppRoutes.navigateToMealAnalysisReport(
            context,
            image: imageUrl ?? '',
            title: title,
            tag: 'Balanced',
            foods: data?['foods'] ?? [],
            recordData: data,
          );
        }
      },
      child: Container(
        height: 114.h, // 114px高度
        decoration: BoxDecoration(
          color: Color(0xFFF6F6F6),
          borderRadius: BorderRadius.circular(12.h),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              offset: Offset(0, 2.h),
              blurRadius: 8.h,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.h),
          child: Row(
            children: [
              // 左边正方形图片或加载动画
              Container(
                width: 90.h,
                height: 90.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.h),
                  color: Colors.grey[200],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.h),
                  child: isAnalyzing
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 30.h,
                                height: 30.h,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF747474),
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Recognizing',
                                style: TextStyle(
                                  color: Color(0xFF747474),
                                  fontSize: 12.fSize,
                                ),
                              ),
                            ],
                          ),
                        )
                      : imageUrl != null && imageUrl.isNotEmpty
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.restaurant,
                                  color: Colors.grey[600],
                                  size: 32.h,
                                ),
                              ),
                            )
                          : Icon(
                              Icons.restaurant,
                              color: Colors.grey[600],
                              size: 32.h,
                            ),
                ),
              ),

              SizedBox(width: 10.h), // 距离右边10px

              // 右边剩余区域
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 第一行：收藏按钮、标签、卡路里、编辑按钮
                    Row(
                      children: [
                        // 收藏爱心按钮
                        Opacity(
                          opacity: isAnalyzing ? 0.35 : 1,
                          child: SizedBox(
                            width: 32.h,
                            height: 32.h,
                            child: IgnorePointer(
                              ignoring: isAnalyzing,
                              child: GestureDetector(
                            onTap: () {
                              setState(() {
                                // 这里可以切换收藏状态
                              });
                            },
                                child: Icon(
                                  isLiked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: isLiked
                                      ? Color.fromARGB(255, 214, 37, 37)
                                      : Color(0xFF747474),
                                  size: 20.h,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(width: 6.h),

                        // Balanced diet 标签 - 使用 Flexible 避免溢出
                        Flexible(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 5.h, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: isAnalyzing
                                  ? const Color(0xFFFFE8A3)
                                  : const Color(0xFFE1EC7C),
                              borderRadius: BorderRadius.circular(90),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                isAnalyzing ? 'Recognizing' : 'Balanced',
                                style: TextStyle(
                                  color: Color(0xFF747474),
                                  fontSize: 16.fSize,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Spacer(),

                        // 卡路里显示
                        if (caloriesText.isNotEmpty) ...[
                          SizedBox(width: 6.h),
                          Flexible(
                            child: Text(
                              caloriesText,
                              style: TextStyle(
                                color: Color(0xFF747474),
                                fontSize: 11.fSize,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // 第二行：文案内容
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: Color(0xFF646464),
                          fontSize: 16.fSize,
                          fontWeight: FontWeight.w500,
                          height: 22.0 / 16.0,
                          letterSpacing: 0.121,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // COLLECT 收集统计区域
  Widget _buildCollectSection() {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 20.h),
      padding: EdgeInsets.only(top: 20.h, bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶部行：COLLECT标题和Weekly update提示
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'COLLECT',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20.fSize,
                  fontFamily: 'PressStart2P',
                  fontWeight: FontWeight.normal,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(45.h),
                  border: Border.all(
                    color: Color(0xFF4C4C4C),
                    width: 1.h,
                  ),
                ),
                child: Center(
                  child: Text(
                    'Weekly Update',
                    style: TextStyle(
                      color: Color(0xFF4C4C4C),
                      fontSize: 14.fSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // 食物收集统计卡片
          SizedBox(
            child: Column(
              children: [
                // 三种食物统计
                Row(
                  children: [
                    // 蔬菜
                    Expanded(
                      child: _buildFoodCollectCard(
                        icon: '🥬',
                        name: '蔬菜',
                        current: 6,
                        target: 9,
                        color: Color(0xFF52D1C6),
                        bgColor: Color(0xFFE8F8F7),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    // 主食
                    Expanded(
                      child: _buildFoodCollectCard(
                        icon: '🌾',
                        name: '主食',
                        current: 5,
                        target: 8,
                        color: Color(0xFF779600),
                        bgColor: Color(0xFFF0F7E8),
                      ),
                    ),
                    SizedBox(width: 12.h),
                    // 肉食
                    Expanded(
                      child: _buildFoodCollectCard(
                        icon: '🥩',
                        name: '肉食',
                        current: 4,
                        target: 8,
                        color: Color(0xFFFF6B6B),
                        bgColor: Color(0xFFFFF0F0),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Tips 文字
          Container(
            padding: EdgeInsets.all(10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(45.h), // 90px的一半
              color: Color(0x33000000), // rgba(0, 0, 0, 0.20)
            ),
            child: Center(
              child: Text(
                'Tips: The more diverse types of food, more comprehensive nutrition.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF707070),
                  fontSize: 17.fSize,
                  fontWeight: FontWeight.w400,
                  height: 22.0 / 17.0, // line-height 22px / font-size 17px
                  letterSpacing: -0.08,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 食物收集卡片 - 黑色像素风格
  Widget _buildFoodCollectCard({
    required String icon,
    required String name,
    required int current,
    required int target,
    required Color color,
    required Color bgColor,
  }) {
    String imagePath;

    // 根据名称设置显示名称和图片路径
    switch (name) {
      case '蔬菜':
        imagePath = 'assets/images/211cai.png';
        break;
      case '主食':
        imagePath = 'assets/images/211mianbao.png';
        break;
      case '肉食':
        imagePath = 'assets/images/211rou.png';
        break;
      default:
        imagePath = 'assets/images/211cai.png';
    }

    return Container(
      width: 113,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A8C8C8C), // rgba(140, 140, 140, 0.10)
            offset: Offset(6, 6),
            blurRadius: 15,
            spreadRadius: -3,
          ),
        ],
      ),
      child: Stack(
        children: [
          // 整个卡片的背景图片
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey.shade600,
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
          // 底部半透明背景，用于显示分数
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 35, // 底部分数区域高度
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(26),
                  bottomRight: Radius.circular(26),
                ),
                color: Colors.black.withValues(alpha: 0.7), // 半透明黑色背景
              ),
              child: Center(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '$current ',
                        style: TextStyle(color: Color(0xFFC8FD00)),
                      ),
                      TextSpan(text: '/ $target'),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // RECOMMEND 推荐区域
  Widget _buildRecommendSection() {
    return SizedBox(
      key: _recommendSectionKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RECOMMEND',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20.fSize,
              fontFamily: 'PressStart2P',
              fontWeight: FontWeight.normal,
            ),
          ),
          if (_recommendationSource != _RecommendationSource.none) ...[
            SizedBox(height: 6.h),
            Text(
              _recommendationGeneratedToday
                  ? '今日已根据画像生成推荐'
                  : '推荐来源：${_recommendationSourceStyle(_recommendationSource).label}',
              style: TextStyle(
                color: const Color(0xFF666666),
                fontSize: 12.fSize,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
          SizedBox(height: 16.h),

          // 餐食类型切换
          _buildMealTypeSelector(),
          SizedBox(height: 16.h),

          // 黑色大卡片
          _buildRecommendCard(),
        ],
      ),
    );
  }

  // 餐食类型选择器
  Widget _buildMealTypeSelector() {
    return SizedBox(
      height: 45.h,
      child: Row(
        children: _mealTypes.map((mealType) {
          final isSelected = mealType == _selectedMealType;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedMealType = mealType;
              });
              _loadCollectedStatus(); // 切换餐食类型时刷新收藏状态
            },
            child: Container(
              margin: EdgeInsets.all(4.h),
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(90),
                border: isSelected
                    ? Border.all(color: Color(0xFF000000), width: 1)
                    : Border.all(color: Colors.transparent, width: 1),
              ),
              child: Center(
                child: Text(
                  mealType,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Color(0xFFA9A9A9),
                    fontSize: 14.fSize,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // 推荐卡片
  Widget _buildRecommendCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 获取可用宽度，确保是正方形
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.of(context).size.width - 40; // 减去左右padding

        final cardSize = maxWidth;

        return Container(
          width: cardSize,
          height: cardSize,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20.h),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                offset: Offset(0, 4.h),
                blurRadius: 12.h,
              ),
            ],
          ),
          child: Stack(
            children: [
              // 上部分内容（占 cardSize - 90.h 高度）- 新布局：三行列表
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 90.h,
                child: _buildFoodList(),
              ),

              // 下部分内容（90.h高度）
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 90.h,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 左侧 Collect 按钮
                      GestureDetector(
                        onTap: _toggleCollect,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 40.h,
                              height: 40.h,
                              child: Icon(
                                (_collectedStatus[_getSelectedDate()
                                            .toIso8601String()
                                            .split('T')[0]] ??
                                        false)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: (_collectedStatus[_getSelectedDate()
                                            .toIso8601String()
                                            .split('T')[0]] ??
                                        false)
                                    ? Color(0xFFFF0000)
                                    : Color(0xFF908070),
                                size: 28.h,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Collect',
                              style: TextStyle(
                                color: (_collectedStatus[_getSelectedDate()
                                            .toIso8601String()
                                            .split('T')[0]] ??
                                        false)
                                    ? Color(0xFFFF0000)
                                    : Color(0xFF908070),
                                fontSize: 14.fSize,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      // 中间显示餐食热量和食材英文名
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10.h),
                          child: _buildMealInfo(),
                        ),
                      ),
                      // 右侧 Change 按钮
                      // Column(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     SizedBox(
                      //       width: 40.h,
                      //       height: 40.h,
                      //       child: Image.asset(
                      //         'assets/images/change.png',
                      //         width: 40.h,
                      //         height: 40.h,
                      //         fit: BoxFit.contain,
                      //         errorBuilder: (context, error, stackTrace) =>
                      //             Container(
                      //           width: 40.h,
                      //           height: 40.h,
                      //           color: Colors.grey.shade600,
                      //           child: Icon(
                      //             Icons.refresh,
                      //             color: Colors.white,
                      //             size: 20.h,
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     SizedBox(height: 4.h),
                      //     Text(
                      //       'Change',
                      //       style: TextStyle(
                      //         color: Color(0xFF908070),
                      //         fontSize: 14.fSize,
                      //         fontWeight: FontWeight.w400,
                      //       ),
                      //       textAlign: TextAlign.center,
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              ),

              // 分数【85】显示在左上角14:14位置
              // Positioned(
              //   right: 14.h,
              //   top: 14.h,
              //   child: Container(
              //     width: 48.h,
              //     height: 48.h,
              //     decoration: BoxDecoration(
              //       color: Color(0xFFC8FD00),
              //       shape: BoxShape.circle,
              //       boxShadow: [
              //         BoxShadow(
              //           color: Colors.black.withValues(alpha: 0.12),
              //           blurRadius: 6.h,
              //           offset: Offset(0, 2.h),
              //         ),
              //       ],
              //     ),
              //     child: Center(
              //       child: Text(
              //         'A',
              //         style: TextStyle(
              //           color: Colors.black,
              //           fontSize: 20.fSize,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),

              // 虚线分割线
              Positioned(
                left: 20.h,
                right: 20.h,
                top: cardSize - 90.h,
                child: CustomPaint(
                  size: Size(cardSize - 40.h, 1),
                  painter: DashedLinePainter(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建餐食信息（热量和食材英文名）
  Widget _buildMealInfo() {
    if (_isLoadingFoods) {
      return Center(
        child: CircularProgressIndicator(color: Color(0xFFC8FD00)),
      );
    }

    // 获取当前选择的餐食类型对应的食物数据
    final selectedMealData = _findSelectedMealData();

    if (selectedMealData == null) {
      final hasFallbackError = _recommendationFallbackError != null &&
          _recommendationFallbackError!.isNotEmpty;
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.h, vertical: 8.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasFallbackError
                          ? 'Unable to generate recommendation'
                          : 'No recommendation yet',
                      style: TextStyle(
                        color: Color(0xFF908070),
                        fontSize: 14.fSize,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (hasFallbackError) ...[
                      SizedBox(height: 6.h),
                      Text(
                        _recommendationFallbackError!,
                        style: TextStyle(
                          color: const Color(0xFFB0B0B0),
                          fontSize: 11.fSize,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: _retryGenerateRecommendationFallback,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.h, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFC8FD00),
                          borderRadius: BorderRadius.circular(999.h),
                        ),
                        child: Text(
                          hasFallbackError ? 'Retry' : 'Generate',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12.fSize,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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

    final calories = selectedMealData['calories'] ?? 0;
    final foods = selectedMealData['foods'] as List? ?? [];
    final foodNames = foods.map((f) {
      final foodInfo = f['food'] as Map?;
      return foodInfo?['name_en'] as String? ?? 'Unknown';
    }).join(', ');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$calories kcal',
          style: TextStyle(
            color: Color(0xFF908070),
            fontSize: 16.fSize,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          foodNames,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.fSize,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // 构建食材列表 - 三行布局
  Widget _buildFoodList() {
    // 获取当前选择的餐食类型对应的食物数据
    final selectedMealData =
        _currentUserFoods.isNotEmpty ? _findSelectedMealData() : null;

    // 收集所有食物信息，按类别分组
    Map<String, Map<String, dynamic>> categorizedFoods = {
      'vegetable': {'names': <String>[], 'id': null},
      'carbohydrate': {'names': <String>[], 'id': null},
      'protein': {'names': <String>[], 'id': null},
    };

    if (selectedMealData != null) {
      final foods = selectedMealData['foods'] as List? ?? [];
      for (var foodItem in foods) {
        final foodInfo = foodItem['food'] as Map?;
        if (foodInfo != null) {
          final category = foodInfo['category'] as String?;
          final nameEn = foodInfo['name_en'] as String?;
          if (category != null && nameEn != null) {
            final categoryLower = category.toLowerCase();
            if (categorizedFoods.containsKey(categoryLower)) {
              // 如果还没有设置 id，设置第一个食物的 id
              if (categorizedFoods[categoryLower]!['id'] == null) {
                categorizedFoods[categoryLower]!['id'] = foodItem['id'];
              }
              categorizedFoods[categoryLower]!['names'].add(nameEn);
            }
          }
        }
      }
    }

    // 定义三行的固定配置
    final foodRows = [
      {
        'category': 'vegetable',
        'image': 'assets/images/211cai.png',
        'name': categorizedFoods['vegetable']!['names'].isNotEmpty
            ? categorizedFoods['vegetable']!['names'].join(', ')
            : 'No vegetable',
        'id': categorizedFoods['vegetable']!['id'],
      },
      {
        'category': 'carbohydrate',
        'image': 'assets/images/211mianbao.png',
        'name': categorizedFoods['carbohydrate']!['names'].isNotEmpty
            ? categorizedFoods['carbohydrate']!['names'].join(', ')
            : 'No carbohydrate',
        'id': categorizedFoods['carbohydrate']!['id'],
      },
      {
        'category': 'protein',
        'image': 'assets/images/211rou.png',
        'name': categorizedFoods['protein']!['names'].isNotEmpty
            ? categorizedFoods['protein']!['names'].join(', ')
            : 'No protein',
        'id': categorizedFoods['protein']!['id'],
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.h, vertical: 30.h),
      child: Column(
        children: foodRows.asMap().entries.map((entry) {
          final index = entry.key;
          final rowData = entry.value;
          final category = rowData['category'] as String;
          final imagePath = rowData['image'] as String;
          final foodName = rowData['name'] as String;
          final foodId = rowData['id'] as int?;

          return Expanded(
            child: index < foodRows.length - 1
                ? Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildFoodRow(
                      imagePath: imagePath,
                      foodName: foodName,
                      category: category,
                      foodId: foodId,
                    ),
                  )
                : _buildFoodRow(
                    imagePath: imagePath,
                    foodName: foodName,
                    category: category,
                    foodId: foodId,
                  ),
          );
        }).toList(),
      ),
    );
  }

  // 构建单行食材
  Widget _buildFoodRow({
    required String imagePath,
    required String foodName,
    required String category,
    int? foodId,
  }) {
    return GestureDetector(
      onTap: () async {
        // 点击整行跳转到 MenuPage
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MenuPage(
              category: category,
              recipeFoodId: foodId ?? 0,
            ),
          ),
        );
        if (result == true) {
                    _markRecommendationAdjustedByUser();
          _loadCurrentUserFoods();
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12.h),
        ),
        child: Row(
          children: [
            // 左侧图片
            Container(
              width: 60.h,
              height: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.h),
                  bottomLeft: Radius.circular(12.h),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.h),
                  bottomLeft: Radius.circular(12.h),
                ),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Color(0xFF454A30),
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 24.h,
                    ),
                  ),
                ),
              ),
            ),
            // 中间食材名称
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.h),
                child: Text(
                  foodName,
                  style: TextStyle(
                    color: Color(0xFFDEC1A4),
                    fontSize: 16.fSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            // 右侧切换按钮
            Padding(
              padding: EdgeInsets.only(right: 12.h),
              child: Icon(
                Icons.refresh_rounded,
                color: Color(0xFF908070),
                size: 20.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 保留原有的 _buildFoodTypeLabels 方法（如果其他地方调用）
  // 构建食材类型标签和引导线（兼容旧代码）
  // ignore: unused_element
  Widget _buildFoodTypeLabels(double cardSize) {
    // 获取当前选择的餐食类型对应的食物数据
    final selectedMealData = _findSelectedMealData();

    // 收集所有食物信息（最多4个），按类别分组
    Map<String, List<String>> categorizedFoods = {
      'vegetable': [],
      'carbohydrate': [],
      'protein': [],
      'fruit': [],
      'fat': [],
    };

    if (selectedMealData != null) {
      final foods = selectedMealData['foods'] as List? ?? [];
      for (var foodItem in foods) {
        final foodInfo = foodItem['food'] as Map?;
        if (foodInfo != null) {
          final category = foodInfo['category'] as String?;
          final nameEn = foodInfo['name_en'] as String?;
          if (category != null && nameEn != null) {
            final categoryLower = category.toLowerCase();
            if (categorizedFoods.containsKey(categoryLower)) {
              categorizedFoods[categoryLower]!.add(nameEn);
            }
          }
        }
      }
    }

    final containerWidth = cardSize; // 使用卡片总宽度
    final containerHeight = cardSize - 90.h; // 上半部分高度
    final iconSize = 24.h; // 图标大小

    // 构建要显示的食材类型标签列表 - 使用实际的菜品数据
    final foodTypes = <Map<String, dynamic>>[];

    // 位置1: 左上角 - vegetable
    int? vegetableId;
    if (categorizedFoods['vegetable']!.isNotEmpty) {
      // 找到第一个 vegetable 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null &&
              (foodInfo['category'] as String?) == 'vegetable') {
            vegetableId = foodItem['id'] as int?;
            break;
          }
        }
      }
      foodTypes.add({
        'name': categorizedFoods['vegetable']!.join(', '),
        'textPosition': Offset(18.h, containerHeight * 0.3 - 40),
        'isVegetables': true, // 标记这是左上角位置
        'id': vegetableId,
        'category': 'vegetable', // 添加食物的category属性
      });
    }

    // 位置2: 左下角 - carbohydrate
    int? carbohydrateId;
    if (categorizedFoods['carbohydrate']!.isNotEmpty) {
      // 找到第一个 carbohydrate 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null &&
              (foodInfo['category'] as String?) == 'carbohydrate') {
            carbohydrateId = foodItem['id'] as int?;
            break;
          }
        }
      }
      foodTypes.add({
        'name': categorizedFoods['carbohydrate']!.join(', '),
        'textPosition': Offset(18.h, containerHeight * 0.7 + 50),
        'isVegetables': false,
        'isHighProtein': false,
        'id': carbohydrateId,
        'category': 'carbohydrate', // 添加食物的category属性
      });
    }

    // 位置3: 右下角 - protein
    int? proteinId;
    if (categorizedFoods['protein']!.isNotEmpty) {
      // 找到第一个 protein 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null &&
              (foodInfo['category'] as String?) == 'protein') {
            proteinId = foodItem['id'] as int?;
            break;
          }
        }
      }
      foodTypes.add({
        'name': categorizedFoods['protein']!.join(', '),
        'textPosition':
            Offset(containerWidth - 180.h, containerHeight * 0.7 + 50),
        'isVegetables': false,
        'isHighProtein': true, // 标记这是右下角位置
        'id': proteinId,
        'category': 'protein', // 添加食物的category属性
      });
    }

    // 位置4: 右上角 - fruit或fat（如果有第4个菜）
    String? fourthFoodName;
    int? fourthId;
    String? fourthCategory;
    if (categorizedFoods['fruit']!.isNotEmpty) {
      fourthFoodName = categorizedFoods['fruit']!.join(', ');
      fourthCategory = 'fruit';
      // 找到第一个 fruit 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null &&
              (foodInfo['category'] as String?) == 'fruit') {
            fourthId = foodItem['id'] as int?;
            break;
          }
        }
      }
    } else if (categorizedFoods['fat']!.isNotEmpty) {
      fourthFoodName = categorizedFoods['fat']!.join(', ');
      fourthCategory = 'fat';
      // 找到第一个 fat 食物的 plan_id
      if (selectedMealData != null) {
        final foods = selectedMealData['foods'] as List? ?? [];
        for (var foodItem in foods) {
          final foodInfo = foodItem['food'] as Map?;
          if (foodInfo != null && (foodInfo['category'] as String?) == 'fat') {
            fourthId = foodItem['id'] as int?;
            break;
          }
        }
      }
    }
    // 如果第四个位置已经有其他类别，继续查找
    if (fourthFoodName == null) {
      for (var key in categorizedFoods.keys) {
        if (key != 'vegetable' &&
            key != 'carbohydrate' &&
            key != 'protein' &&
            categorizedFoods[key]!.isNotEmpty) {
          fourthFoodName = categorizedFoods[key]!.join(', ');
          fourthCategory = key;
          if (selectedMealData != null) {
            final foods = selectedMealData['foods'] as List? ?? [];
            for (var foodItem in foods) {
              final foodInfo = foodItem['food'] as Map?;
              if (foodInfo != null &&
                  (foodInfo['category'] as String?) == key) {
                fourthId = foodItem['id'] as int?;
                break;
              }
            }
          }
          break;
        }
      }
    }
    if (fourthFoodName != null) {
      foodTypes.add({
        'name': fourthFoodName,
        'textPosition':
            Offset(containerWidth - 180.h, containerHeight * 0.3 - 50),
        'isVegetables': false,
        'isHighProtein': false,
        'isFourth': true, // 标记这是第四个菜（右上角）
        'id': fourthId,
        'category': fourthCategory, // 添加食物的category属性
      });
    }

    return Stack(
      children: foodTypes.map((foodType) {
        final textPosition = foodType['textPosition'] as Offset;
        final isVegetables = foodType['isVegetables'] as bool;
        final isHighProtein = foodType['isHighProtein'] as bool? ?? false;
        final isFourth = foodType['isFourth'] as bool? ?? false;
        final id = foodType['id'] as int?;
        final foodCategory = foodType['category'];

        return Stack(
          children: [
            // 食材类型文字
            Positioned(
              left: (isHighProtein || isFourth)
                  ? null
                  : textPosition.dx, // 右下角和右上角右对齐，其他左对齐
              right: (isHighProtein || isFourth)
                  ? 18.h
                  : (containerWidth / 2 - 18.h), // 左侧文字限制在半宽度
              top: textPosition.dy,
              child: Text(
                foodType['name'] as String,
                style: TextStyle(
                  color: Color(0xFFDEC1A4),
                  fontSize: 18.fSize,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: (isHighProtein || isFourth)
                    ? TextAlign.right
                    : TextAlign.left,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Change图标按钮
            Positioned(
              left: (isHighProtein || isFourth)
                  ? null
                  : textPosition.dx, // 右侧右对齐，左侧左对齐
              right: (isHighProtein || isFourth) ? 18.h : null,
              top: isVegetables
                  ? textPosition.dy - iconSize // 左上角图标在文字下方
                  : textPosition.dy - iconSize - 4.h, // 其他位置图标在文字上方
              child: GestureDetector(
                onTap: () async {
                  // 跳转到 MenuPage 子页面，传递对应食物的 plan_id 和 category
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuPage(
                        category: foodCategory,
                        recipeFoodId: id ?? 0,
                      ),
                    ),
                  );
                  // 如果返回结果为 true，表示需要刷新数据
                  if (result == true) {
                    _markRecommendationAdjustedByUser();
                    _loadCurrentUserFoods(); // 刷新用户数据
                  }
                },
                child: SizedBox(
                  width: 24.h,
                  height: 24.h,
                  child: Icon(
                    Icons.refresh_rounded,
                    color: Color(0xFF908070),
                    size: 20.h,
                  ),
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // MY PLAN 我的计划区域
  Widget _buildMyPlanSection() {
    final filteredPlans = _getFilteredPlans();
    return SizedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY PLAN',
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'PressStart2P',
              fontSize: 24.fSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // 2x3 网格包装在边框容器中
          Container(
            padding: EdgeInsets.all(20.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(33.h),
              border: Border.all(
                color: Color(0xFFFFFFFF),
                width: 2.h,
              ),
              gradient: LinearGradient(
                begin: Alignment(0.83, -0.55), // 131deg
                colors: [
                  Color(0xFFFFF9F6), // 16.08%
                  Color(0xFFF2F5F6), // 83.14%
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x26000000), // rgba(0, 0, 0, 0.15)
                  offset: Offset(2, 2),
                  blurRadius: 15,
                  spreadRadius: -3,
                ),
              ],
            ),
            child: Column(
              children: [
                // 搜索行
                if (_isSearchVisible)
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search name/source...',
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFF666666)),
                        suffixIcon: GestureDetector(
                          onTap: () async {
                            setState(() {
                              _isSearchVisible = false;
                              _searchController.clear();
                            });
                            await _persistMyPlanViewPrefs();
                          },
                          child: Icon(Icons.close, color: Color(0xFF666666)),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.h),
                          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.h),
                          borderSide: BorderSide(color: Color(0xFF4C4C4C)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.h,
                          vertical: 12.h,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  )
                else
                  Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // 搜索放大镜按钮
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              _isSearchVisible = true;
                            });
                            await _persistMyPlanViewPrefs();
                          },
                          child: Container(
                            width: 40.h,
                            height: 40.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.h),
                              border: Border.all(
                                color: Color(0xFFE0E0E0),
                                width: 1.h,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x0D000000),
                                  offset: Offset(0, 2.h),
                                  blurRadius: 4.h,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.search,
                              color: Color(0xFF666666),
                              size: 20.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_collectedMeals.isNotEmpty) ...[
                  SizedBox(
                    height: 30.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _planSourceFilters.length,
                      separatorBuilder: (_, __) => SizedBox(width: 8.h),
                      itemBuilder: (context, index) {
                        final item = _planSourceFilters[index];
                        final key = item['key']!;
                        final label = item['label']!;
                        final selected = _selectedPlanSourceFilter == key;
                        return GestureDetector(
                          onTap: () async {
                            setState(() {
                              _selectedPlanSourceFilter = key;
                            });
                            await _persistMyPlanViewPrefs();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.h, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: selected
                                  ? const Color(0xFF4C4C4C)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16.h),
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFF4C4C4C)
                                    : const Color(0xFFE0E0E0),
                                width: 1.h,
                              ),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: selected
                                    ? Colors.white
                                    : const Color(0xFF666666),
                                fontSize: 11.fSize,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
                // 网格内容
                if (filteredPlans.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 28.h),
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '暂无收藏餐食 / No collected meals yet',
                          style: TextStyle(
                            color: const Color(0xFF8A8A8A),
                            fontSize: 12.fSize,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10.h),
                        GestureDetector(
                          onTap: () async {
                            final targetContext = _recommendSectionKey.currentContext;
                            if (targetContext != null) {
                              await Scrollable.ensureVisible(
                                targetContext,
                                duration: const Duration(milliseconds: 350),
                                curve: Curves.easeInOut,
                                alignment: 0.05,
                              );
                              return;
                            }
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('请在上方 RECOMMEND 区点击 Collect 收藏后再查看 MY PLAN'),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.h, vertical: 6.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4C4C4C),
                              borderRadius: BorderRadius.circular(14.h),
                            ),
                            child: Text(
                              'Go to RECOMMEND',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.fSize,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.h,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filteredPlans.length,
                    itemBuilder: (context, index) {
                      final filteredPlan = filteredPlans[index];
                      return _buildPlanCard(filteredPlan);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 计划卡片
  Widget _buildPlanCard(Map<String, dynamic> plan) {
    // 判断是否为收藏的食物（有name_en字段）
    final isCollectedFood = plan['name_en'] != null;
    final recommendationSource = _planSourceForDisplay(plan);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.h),
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            offset: Offset(0, 2.h),
            blurRadius: 8.h,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFF5F5F5),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.h),
                  topRight: Radius.circular(16.h),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16.h),
                  topRight: Radius.circular(16.h),
                ),
                child: isCollectedFood
                    ? Image.network(
                        plan['image_url'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(0xFF454A30),
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 40.h,
                            ),
                          );
                        },
                      )
                    : Image.asset(
                        plan['image'] ?? '',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(0xFF454A30),
                            child: Icon(
                              Icons.restaurant,
                              color: Colors.white,
                              size: 40.h,
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
          // 文字信息区域
          Expanded(
            flex: 2,
            child: Padding(
              padding: EdgeInsets.all(10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isCollectedFood
                        ? (plan['name_en']?.toString() ?? '')
                        : (plan['name']?.toString() ?? ''),
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12.fSize,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  // Text(
                  //   'by ${plan['user']}',
                  //   style: TextStyle(
                  //     color: Color(0xFF666666),
                  //     fontSize: 10.fSize,
                  //   ),
                  // ),
                  // Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (!isCollectedFood)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.h, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: _getGradeColor(plan['score'] ?? '')
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6.h),
                          ),
                          child: Text(
                            plan['score'] ?? '',
                            style: TextStyle(
                              color: _getGradeColor(plan['score'] ?? ''),
                              fontSize: 10.fSize,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      if (isCollectedFood &&
                          recommendationSource != _RecommendationSource.none)
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.h, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: _recommendationSourceStyle(
                                      recommendationSource)
                                  .color
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6.h),
                            ),
                            child: Text(
                              _recommendationSourceStyle(recommendationSource)
                                  .label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _recommendationSourceStyle(
                                        recommendationSource)
                                    .color,
                                fontSize: 10.fSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      Icon(
                        Icons.favorite_border,
                        color: Color(0xFF666666),
                        size: 14.h,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 获取筛选后的计划列表
  List<Map<String, dynamic>> _getFilteredPlans() {
    // 如果有收藏的餐食，优先显示收藏的餐食
    if (_collectedMeals.isNotEmpty) {
      // 搜索过滤
      if (_searchController.text.isNotEmpty) {
        final searchTerm = _searchController.text.toLowerCase();
        return _collectedMeals.where((meal) {
          final nameEn = meal['name_en']?.toString().toLowerCase() ?? '';
          final name = meal['name']?.toString().toLowerCase() ?? '';
          final source = _planSourceForDisplay(meal);
          final sourceRaw = source.toLowerCase();
          final sourceLabel =
              _recommendationSourceStyle(source).label.toLowerCase();
          final matchesSourceFilter = _selectedPlanSourceFilter == 'all' ||
              source == _selectedPlanSourceFilter;
          return matchesSourceFilter &&
              (nameEn.contains(searchTerm) ||
              name.contains(searchTerm) ||
              sourceRaw.contains(searchTerm) ||
              sourceLabel.contains(searchTerm));
        }).toList();
      }
      if (_selectedPlanSourceFilter == 'all') {
        return _collectedMeals;
      }
      return _collectedMeals
          .where((meal) => _planSourceForDisplay(meal) == _selectedPlanSourceFilter)
          .toList();
    }

    // 如果没有收藏的餐食，显示默认的diet plans
    if (_searchController.text.isEmpty) {
      return _dietPlans.asMap().entries.map((entry) {
        final plan = Map<String, dynamic>.from(entry.value);
        plan['originalIndex'] = entry.key;
        return plan;
      }).toList();
    }

    final searchTerm = _searchController.text.toLowerCase();
    return _dietPlans.asMap().entries.where((entry) {
      return entry.value['name'].toString().toLowerCase().contains(searchTerm);
    }).map((entry) {
      final plan = Map<String, dynamic>.from(entry.value);
      plan['originalIndex'] = entry.key;
      return plan;
    }).toList();
  }

  // 获取等级颜色
  Color _getGradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
      case 'A-':
        return Color(0xFF52D1C6);
      case 'B+':
      case 'B':
      case 'B-':
        return Color(0xFF779600);
      case 'C+':
      case 'C':
      case 'C-':
        return Color(0xFFFFA500);
      default:
        return Color(0xFF666666);
    }
  }
}

// 虚线绘制器
class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF666666)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final dashWidth = 5.0;
    final dashSpace = 5.0;
    double startX = 0;
    final endX = size.width;

    while (startX < endX) {
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(startX + dashWidth < endX ? startX + dashWidth : endX,
            size.height / 2),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
