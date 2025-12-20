## GoalsPage - 健康目标推荐系统

### 系统概述

GoalsPage 是注册流程的第 3 步，根据用户在 Step 1 和 Step 2 中提供的信息自动生成个性化的健康目标推荐。

### 核心组件

#### 1. **HealthGoalModel** (`models/health_goal_model.dart`)

- 健康目标数据模型
- 包含字段：id, name, description, priority, category, icon, isSelected
- 优先级：HIGH(高), MEDIUM(中), LOW(低)

#### 2. **GoalRecommendationEngine** (`utils/goal_recommendation_engine.dart`)

核心推荐引擎，包含三个推荐维度：

**按年龄推荐:**

- 儿童 (≤12 岁): 身高增长, 挑食改善, 规律运动, 睡眠充足, 视力保护
- 青少年 (13-18 岁): 骨骼健康, 屏幕时间控制, 压力管理, 健康饮食, 运动参与
- 成年人 (19-45 岁):
  - 男性: 工作生活平衡, 健身习惯, 心血管健康, 营养均衡, 压力释放
  - 女性: 激素平衡, 规律健身, 皮肤护理, 工作平衡, 铁质摄入
- 中年人 (46-65 岁): 慢性病管理, 体重管理, 适度运动, 睡眠质量, 心理健康
- 老年人 (>65 岁): 慢性病控制, 骨强度维持, 跌倒预防, 社交活动, 营养充足

**性别特异性推荐:**

- 女性 40-55 岁: 更年期管理

**基于问卷增强:**

- 工作压力高 → 紧急压力管理
- 运动时间<3 小时 → 增加运动时间
- 睡眠异常(≤6h 或 ≥9h) → 规范睡眠
- 设备使用过度 → 减少设备使用
- 有慢性病 → 疾病管理
- 体重超标 → 健康减重
- 其他特定饮食/健康指标 → 针对性建议

#### 3. **GoalsPage** (`presentation/registration/goals_page.dart`)

主界面，包含：

**功能特性:**

- 动态加载推荐目标（基于步骤 1 和 2 的数据）
- 目标选择（复选框）
- 按类别筛选（营养, 运动, 健康）
- 快速操作（全选, 清空）
- 优先级指示（颜色编码）
- 实时数据保存到 Provider

**用户交互:**

- 点击目标卡片切换选择状态
- 类别筛选按钮快速选择同类目标
- 全选/清空按钮批量操作
- 上一步/下一步导航（下一步按钮在选择至少 1 个目标时启用）

#### 4. **GoalCardWidget** (`presentation/components/goal_card_widget.dart`)

可复用的目标卡片组件，用于在应用其他地方展示目标。

### 数据流

```
Step 1: BasicInfoPage
  ↓ (name, gender, birthDate)

Step 2: SmartQuestionnairePage
  ↓ (questionnaireData)

Step 3: GoalsPage
  → GoalRecommendationEngine.recommendGoals()
    - 基于年龄和性别确定基础目标
    - 根据问卷数据增强推荐
    - 去重并限制为5个目标
  ↓ 用户选择目标
  → RegistrationProvider.updateSelectedGoals()
  ↓ (selectedGoalIds)

Step 4: Review & Confirmation (待实现)
```

### 推荐算法示例

```dart
List<HealthGoalModel> recommendGoals({
  required DateTime birthDate,
  required String? gender,
  required Map<String, dynamic>? questionnaireData,
}) {
  final goals = <HealthGoalModel>[];
  final age = calculateAge(birthDate);

  // 1. 年龄基础推荐
  if (age <= 12) {
    goals.add(身高增长, 挑食改善, 运动, 睡眠, 视力);
  } else if (age <= 18) {
    goals.add(骨骼健康, 屏幕控制, 压力, 饮食, 运动);
  }
  // ... 更多年龄段

  // 2. 性别特异性增强
  if (gender == 'female' && age >= 40 && age <= 55) {
    goals.add(更年期管理);
  }

  // 3. 问卷基础增强
  if (questionnaireData['workStressLevel'] == '非常高') {
    goals.add(紧急压力管理);
  }
  if (exerciseHours < 3) {
    goals.add(增加运动时间);
  }
  // ... 更多增强逻辑

  // 去重并返回前5个
  return goals.take(5).toList();
}
```

### 状态管理

**RegistrationProvider 扩展:**

```dart
void updateSelectedGoals(List<String> goalIds) {
  _registrationData = _registrationData.copyWith(selectedGoalIds: goalIds);
  notifyListeners();
}
```

**UserRegistrationData 扩展:**

- 新增字段：`selectedGoalIds`
- 新增 getter：`isStep3Complete`（检查是否选择了目标）

### 目标优先级颜色编码

| 优先级 | 颜色 | 十六进制   |
| ------ | ---- | ---------- |
| 高     | 红色 | 0xFFE53935 |
| 中     | 橙色 | 0xFFFFA726 |
| 低     | 绿色 | 0xFF43A047 |

### 扩展点

1. **添加新目标类别**: 在`_addAgeBasedGoals()`或`_addQuestionnaireBasedGoals()`中添加
2. **自定义推荐逻辑**: 修改`determineCategory()`和各个添加函数
3. **数据持久化**: 在`completeRegistration()`中保存目标选择到数据库
4. **分析和追踪**: 跟踪用户选择的目标以优化推荐

### 相关文件清单

- ✅ `models/health_goal_model.dart` - 目标数据模型
- ✅ `models/user_health_goals.dart` - 用户目标集合模型
- ✅ `utils/goal_recommendation_engine.dart` - 推荐引擎
- ✅ `presentation/registration/goals_page.dart` - 主页面
- ✅ `presentation/components/goal_card_widget.dart` - 可复用卡片组件
- ✅ `models/registration_state.dart` - 扩展以支持目标
- ✅ `providers/registration_provider.dart` - 扩展以支持目标管理
- ✅ `presentation/registration/registration_flow.dart` - 集成 Step 3

### 编译状态

✅ **零错误** (108 个信息级别警告)
✅ **所有依赖已安装**
✅ **准备就绪可运行**
